#include "tupbuild.h"
#include <yaml.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct tupbuild_parser {
	yaml_parser_t parser;
	yaml_event_t event;
	const char *filename;
	char **err;
};

static void tupbuild_free_kvs(struct tupbuild_kv *kvs, int count)
{
	int x;
	for(x=0; x<count; x++) {
		free(kvs[x].key);
		free(kvs[x].value);
	}
	free(kvs);
}

static void tupbuild_free_deps(struct tupbuild_dep *deps, int count)
{
	int x;
	for(x=0; x<count; x++) {
		free(deps[x].build);
		free(deps[x].as);
	}
	free(deps);
}

static void tupbuild_free_dists(struct tupbuild_dist *dists, int count)
{
	int x;
	for(x=0; x<count; x++) {
		free(dists[x].from_return);
		free(dists[x].path);
	}
	free(dists);
}

void tupbuild_free(struct tupbuild_file *tf)
{
	int x;

	if(!tf)
		return;
	tupbuild_free_kvs(tf->global_args, tf->num_global_args);
	for(x=0; x<tf->num_builds; x++) {
		struct tupbuild_build *build = &tf->builds[x];
		free(build->name);
		free(build->tupfile);
		free(build->function);
		free(build->builddir);
		free(build->profile);
		tupbuild_free_kvs(build->args, build->num_args);
		tupbuild_free_deps(build->depends, build->num_depends);
		tupbuild_free_dists(build->dists, build->num_dists);
	}
	free(tf->builds);
	memset(tf, 0, sizeof *tf);
}

static int tupbuild_error(struct tupbuild_parser *tp, const char *msg)
{
	char buf[512];
	int line = tp->event.start_mark.line + 1;
	int col = tp->event.start_mark.column + 1;

	snprintf(buf, sizeof(buf), "%s:%i:%i: %s", tp->filename, line, col, msg);
	*tp->err = strdup(buf);
	if(!*tp->err) {
		perror("strdup");
		return -1;
	}
	return -1;
}

static void tupbuild_warn_unknown(struct tupbuild_parser *tp, const char *what, const char *key)
{
	fprintf(stderr, "tup warning: %s:%lu:%lu: ignoring unknown %s '%s'.\n",
		tp->filename,
		(unsigned long)tp->event.start_mark.line + 1,
		(unsigned long)tp->event.start_mark.column + 1,
		what,
		key);
}

static int tupbuild_parser_next(struct tupbuild_parser *tp)
{
	yaml_event_delete(&tp->event);
	if(!yaml_parser_parse(&tp->parser, &tp->event)) {
		char buf[512];

		snprintf(buf, sizeof(buf), "%s:%lu:%lu: %s",
			 tp->filename,
			 (unsigned long)tp->parser.problem_mark.line + 1,
			 (unsigned long)tp->parser.problem_mark.column + 1,
			 tp->parser.problem ? tp->parser.problem : "yaml parse error");
		*tp->err = strdup(buf);
		if(!*tp->err) {
			perror("strdup");
			return -1;
		}
		return -1;
	}
	return 0;
}

static int tupbuild_skip(struct tupbuild_parser *tp)
{
	if(tp->event.type == YAML_SCALAR_EVENT || tp->event.type == YAML_ALIAS_EVENT)
		return tupbuild_parser_next(tp);
	if(tp->event.type == YAML_SEQUENCE_START_EVENT) {
		if(tupbuild_parser_next(tp) < 0)
			return -1;
		while(tp->event.type != YAML_SEQUENCE_END_EVENT) {
			if(tupbuild_skip(tp) < 0)
				return -1;
		}
		return tupbuild_parser_next(tp);
	}
	if(tp->event.type == YAML_MAPPING_START_EVENT) {
		if(tupbuild_parser_next(tp) < 0)
			return -1;
		while(tp->event.type != YAML_MAPPING_END_EVENT) {
			if(tupbuild_skip(tp) < 0)
				return -1;
			if(tupbuild_skip(tp) < 0)
				return -1;
		}
		return tupbuild_parser_next(tp);
	}
	return tupbuild_error(tp, "unable to skip yaml node");
}

static int tupbuild_expect(struct tupbuild_parser *tp, yaml_event_type_t type, const char *msg)
{
	if(tp->event.type != type)
		return tupbuild_error(tp, msg);
	return 0;
}

static int tupbuild_strdup_scalar(struct tupbuild_parser *tp, char **out)
{
	if(tupbuild_expect(tp, YAML_SCALAR_EVENT, "expected scalar value") < 0)
		return -1;
	*out = strdup((const char*)tp->event.data.scalar.value);
	if(!*out) {
		perror("strdup");
		return -1;
	}
	return 0;
}

static int tupbuild_add_kv(struct tupbuild_kv **kvs, int *count, char *key, char *value)
{
	struct tupbuild_kv *tmp;

	tmp = realloc(*kvs, sizeof(**kvs) * (*count + 1));
	if(!tmp) {
		perror("realloc");
		return -1;
	}
	*kvs = tmp;
	(*kvs)[*count].key = key;
	(*kvs)[*count].value = value;
	(*count)++;
	return 0;
}

static int tupbuild_add_dep(struct tupbuild_dep **deps, int *count, char *build, char *as)
{
	struct tupbuild_dep *tmp;

	tmp = realloc(*deps, sizeof(**deps) * (*count + 1));
	if(!tmp) {
		perror("realloc");
		return -1;
	}
	*deps = tmp;
	(*deps)[*count].build = build;
	(*deps)[*count].as = as;
	(*count)++;
	return 0;
}

static int tupbuild_add_build(struct tupbuild_build **builds, int *count, struct tupbuild_build *build)
{
	struct tupbuild_build *tmp;

	tmp = realloc(*builds, sizeof(**builds) * (*count + 1));
	if(!tmp) {
		perror("realloc");
		return -1;
	}
	*builds = tmp;
	(*builds)[*count] = *build;
	(*count)++;
	memset(build, 0, sizeof *build);
	return 0;
}

static int tupbuild_add_dist(struct tupbuild_dist **dists, int *count, char *from_return, char *path)
{
	struct tupbuild_dist *tmp;

	tmp = realloc(*dists, sizeof(**dists) * (*count + 1));
	if(!tmp) {
		perror("realloc");
		return -1;
	}
	*dists = tmp;
	(*dists)[*count].from_return = from_return;
	(*dists)[*count].path = path;
	(*count)++;
	return 0;
}

static int tupbuild_parse_string_map(struct tupbuild_parser *tp, struct tupbuild_kv **kvs, int *count)
{
	if(tupbuild_expect(tp, YAML_MAPPING_START_EVENT, "expected mapping") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_MAPPING_END_EVENT) {
		char *key = NULL;
		char *value = NULL;
		int x;

		if(tupbuild_strdup_scalar(tp, &key) < 0)
			return -1;
		for(x=0; x<*count; x++) {
			if(strcmp((*kvs)[x].key, key) == 0) {
				free(key);
				return tupbuild_error(tp, "duplicate key in mapping");
			}
		}
		if(tupbuild_parser_next(tp) < 0) {
			free(key);
			return -1;
		}
		if(tupbuild_strdup_scalar(tp, &value) < 0) {
			free(key);
			return -1;
		}
		if(tupbuild_add_kv(kvs, count, key, value) < 0) {
			free(key);
			free(value);
			return -1;
		}
		if(tupbuild_parser_next(tp) < 0)
			return -1;
	}
	return tupbuild_parser_next(tp);
}

static int tupbuild_parse_dep(struct tupbuild_parser *tp, struct tupbuild_dep **deps, int *count)
{
	char *build = NULL;
	char *as = NULL;

	if(tupbuild_expect(tp, YAML_MAPPING_START_EVENT, "expected dependency mapping") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_MAPPING_END_EVENT) {
		char *key = NULL;
		char *value = NULL;

		if(tupbuild_strdup_scalar(tp, &key) < 0)
			return -1;
		if(tupbuild_parser_next(tp) < 0) {
			free(key);
			return -1;
		}
		if(strcmp(key, "build") == 0) {
			if(tupbuild_strdup_scalar(tp, &value) < 0) {
				free(key);
				return -1;
			}
			if(build) {
				free(key);
				free(value);
				return tupbuild_error(tp, "duplicate dependency build key");
			}
			build = value;
		} else if(strcmp(key, "as") == 0) {
			if(tupbuild_strdup_scalar(tp, &value) < 0) {
				free(key);
				return -1;
			}
			if(as) {
				free(key);
				free(value);
				return tupbuild_error(tp, "duplicate dependency alias key");
			}
			as = value;
		} else {
			tupbuild_warn_unknown(tp, "dependency key", key);
			free(key);
			free(value);
			if(tupbuild_parser_next(tp) < 0)
				return -1;
			continue;
		}
		free(key);
		if(tupbuild_parser_next(tp) < 0)
			return -1;
	}
	if(!build || !as) {
		free(build);
		free(as);
		return tupbuild_error(tp, "dependency requires both build and as");
	}
	if(tupbuild_add_dep(deps, count, build, as) < 0) {
		free(build);
		free(as);
		return -1;
	}
	return tupbuild_parser_next(tp);
}

static int tupbuild_parse_dep_seq(struct tupbuild_parser *tp, struct tupbuild_dep **deps, int *count)
{
	if(tupbuild_expect(tp, YAML_SEQUENCE_START_EVENT, "expected dependency sequence") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_SEQUENCE_END_EVENT) {
		if(tupbuild_parse_dep(tp, deps, count) < 0)
			return -1;
	}
	return tupbuild_parser_next(tp);
}

static int tupbuild_parse_dist(struct tupbuild_parser *tp, struct tupbuild_dist **dists, int *count)
{
	char *from_return = NULL;
	char *path = NULL;

	if(tupbuild_expect(tp, YAML_MAPPING_START_EVENT, "expected dist mapping") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_MAPPING_END_EVENT) {
		char *key = NULL;
		char *value = NULL;

		if(tupbuild_strdup_scalar(tp, &key) < 0)
			return -1;
		if(tupbuild_parser_next(tp) < 0) {
			free(key);
			return -1;
		}
		if(strcmp(key, "from_return") == 0) {
			if(tupbuild_strdup_scalar(tp, &value) < 0) {
				free(key);
				return -1;
			}
			if(from_return) {
				free(key);
				free(value);
				return tupbuild_error(tp, "duplicate dist from_return key");
			}
			from_return = value;
		} else if(strcmp(key, "path") == 0) {
			if(tupbuild_strdup_scalar(tp, &value) < 0) {
				free(key);
				return -1;
			}
			if(path) {
				free(key);
				free(value);
				return tupbuild_error(tp, "duplicate dist path key");
			}
			path = value;
		} else {
			tupbuild_warn_unknown(tp, "dist key", key);
			free(key);
			free(value);
			if(tupbuild_parser_next(tp) < 0)
				return -1;
			continue;
		}
		free(key);
		if(tupbuild_parser_next(tp) < 0)
			return -1;
	}
	if(!from_return || !path) {
		free(from_return);
		free(path);
		return tupbuild_error(tp, "dist requires both from_return and path");
	}
	if(tupbuild_add_dist(dists, count, from_return, path) < 0) {
		free(from_return);
		free(path);
		return -1;
	}
	return tupbuild_parser_next(tp);
}

static int tupbuild_parse_dist_seq(struct tupbuild_parser *tp, struct tupbuild_dist **dists, int *count)
{
	if(tupbuild_expect(tp, YAML_SEQUENCE_START_EVENT, "expected dist sequence") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_SEQUENCE_END_EVENT) {
		if(tupbuild_parse_dist(tp, dists, count) < 0)
			return -1;
	}
	return tupbuild_parser_next(tp);
}

static int tupbuild_parse_build(struct tupbuild_parser *tp, struct tupbuild_build *build)
{
	if(tupbuild_expect(tp, YAML_MAPPING_START_EVENT, "expected build mapping") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_MAPPING_END_EVENT) {
		char *key = NULL;
		char *value = NULL;

		if(tupbuild_strdup_scalar(tp, &key) < 0)
			return -1;
		if(tupbuild_parser_next(tp) < 0) {
			free(key);
			return -1;
		}
		if(strcmp(key, "args") == 0) {
			if(build->args) {
				free(key);
				return tupbuild_error(tp, "duplicate args key");
			}
			if(tupbuild_parse_string_map(tp, &build->args, &build->num_args) < 0) {
				free(key);
				return -1;
			}
		} else if(strcmp(key, "depends") == 0) {
			if(build->depends) {
				free(key);
				return tupbuild_error(tp, "duplicate depends key");
			}
			if(tupbuild_parse_dep_seq(tp, &build->depends, &build->num_depends) < 0) {
				free(key);
				return -1;
			}
		} else if(strcmp(key, "dists") == 0) {
			if(build->dists) {
				free(key);
				return tupbuild_error(tp, "duplicate dists key");
			}
			if(tupbuild_parse_dist_seq(tp, &build->dists, &build->num_dists) < 0) {
				free(key);
				return -1;
			}
		} else if(strcmp(key, "name") == 0 ||
			  strcmp(key, "tupfile") == 0 ||
			  strcmp(key, "function") == 0 ||
			  strcmp(key, "builddir") == 0 ||
			  strcmp(key, "profile") == 0) {
			if(tupbuild_strdup_scalar(tp, &value) < 0) {
				free(key);
				return -1;
			}
			if(strcmp(key, "name") == 0) {
				if(build->name) {
					free(key);
					free(value);
					return tupbuild_error(tp, "duplicate build name");
				}
				build->name = value;
			} else if(strcmp(key, "tupfile") == 0) {
				if(build->tupfile) {
					free(key);
					free(value);
					return tupbuild_error(tp, "duplicate tupfile key");
				}
				build->tupfile = value;
			} else if(strcmp(key, "function") == 0) {
				if(build->function) {
					free(key);
					free(value);
					return tupbuild_error(tp, "duplicate function key");
				}
				build->function = value;
			} else if(strcmp(key, "builddir") == 0) {
				if(build->builddir) {
					free(key);
					free(value);
					return tupbuild_error(tp, "duplicate builddir key");
				}
				build->builddir = value;
			} else {
				if(build->profile) {
					free(key);
					free(value);
					return tupbuild_error(tp, "duplicate profile key");
				}
				build->profile = value;
			}
			if(tupbuild_parser_next(tp) < 0) {
				free(key);
				return -1;
			}
		} else {
			tupbuild_warn_unknown(tp, "build key", key);
			free(key);
			if(tupbuild_skip(tp) < 0)
				return -1;
			continue;
		}
		free(key);
	}
	if(!build->name || !build->builddir)
		return tupbuild_error(tp, "build requires name and builddir");
	if((build->tupfile && !build->function) || (!build->tupfile && build->function))
		return tupbuild_error(tp, "build must specify both tupfile and function, or neither");
	if(!build->tupfile && build->num_dists > 0)
		return tupbuild_error(tp, "dependency-only build cannot declare dists");
	return tupbuild_parser_next(tp);
}

static int tupbuild_parse_builds(struct tupbuild_parser *tp, struct tupbuild_file *tf)
{
	if(tupbuild_expect(tp, YAML_SEQUENCE_START_EVENT, "expected builds sequence") < 0)
		return -1;
	if(tupbuild_parser_next(tp) < 0)
		return -1;
	while(tp->event.type != YAML_SEQUENCE_END_EVENT) {
		struct tupbuild_build build;

		memset(&build, 0, sizeof build);
		if(tupbuild_parse_build(tp, &build) < 0) {
			tupbuild_free_kvs(build.args, build.num_args);
			tupbuild_free_deps(build.depends, build.num_depends);
			tupbuild_free_dists(build.dists, build.num_dists);
			free(build.name);
			free(build.tupfile);
			free(build.function);
			free(build.builddir);
			return -1;
		}
		if(tupbuild_add_build(&tf->builds, &tf->num_builds, &build) < 0) {
			tupbuild_free_kvs(build.args, build.num_args);
			tupbuild_free_deps(build.depends, build.num_depends);
			tupbuild_free_dists(build.dists, build.num_dists);
			free(build.name);
			free(build.tupfile);
			free(build.function);
			free(build.builddir);
			return -1;
		}
	}
	return tupbuild_parser_next(tp);
}

int tupbuild_parse(const char *filename, const char *data, int len,
		   struct tupbuild_file *tf, char **err)
{
	struct tupbuild_parser tp;
	char *key = NULL;
	int rc = -1;

	memset(tf, 0, sizeof *tf);
	*err = NULL;
	memset(&tp, 0, sizeof tp);
	tp.filename = filename;
	tp.err = err;

	if(!yaml_parser_initialize(&tp.parser)) {
		*err = strdup("unable to initialize yaml parser");
		if(!*err) {
			perror("strdup");
			return -1;
		}
		return -1;
	}
	yaml_parser_set_input_string(&tp.parser, (const unsigned char*)data, len);
	memset(&tp.event, 0, sizeof tp.event);

	if(tupbuild_parser_next(&tp) < 0)
		goto out;
	if(tupbuild_expect(&tp, YAML_STREAM_START_EVENT, "expected stream start") < 0)
		goto out;
	if(tupbuild_parser_next(&tp) < 0)
		goto out;
	if(tupbuild_expect(&tp, YAML_DOCUMENT_START_EVENT, "expected document start") < 0)
		goto out;
	if(tupbuild_parser_next(&tp) < 0)
		goto out;
	if(tupbuild_expect(&tp, YAML_MAPPING_START_EVENT, "expected top-level mapping") < 0)
		goto out;
	if(tupbuild_parser_next(&tp) < 0)
		goto out;
	while(tp.event.type != YAML_MAPPING_END_EVENT) {
		if(tupbuild_strdup_scalar(&tp, &key) < 0)
			goto out;
		if(tupbuild_parser_next(&tp) < 0) {
			free(key);
			goto out;
		}
		if(strcmp(key, "strict") == 0) {
			char *value = NULL;
			if(tupbuild_strdup_scalar(&tp, &value) < 0) {
				free(key);
				goto out;
			}
			if(strcmp(value, "true") == 0) {
				tf->strict = 1;
			} else if(strcmp(value, "false") == 0) {
				tf->strict = 0;
			} else {
				free(key);
				free(value);
				tupbuild_error(&tp, "strict must be true or false");
				goto out;
			}
			free(value);
			if(tupbuild_parser_next(&tp) < 0) {
				free(key);
				goto out;
			}
		} else if(strcmp(key, "auto_compiledb") == 0) {
			char *value = NULL;
			if(tupbuild_strdup_scalar(&tp, &value) < 0) {
				free(key);
				goto out;
			}
			if(strcmp(value, "true") == 0) {
				tf->auto_compiledb = 1;
			} else if(strcmp(value, "false") == 0) {
				tf->auto_compiledb = 0;
			} else {
				free(key);
				free(value);
				tupbuild_error(&tp, "auto_compiledb must be true or false");
				goto out;
			}
			free(value);
			if(tupbuild_parser_next(&tp) < 0) {
				free(key);
				goto out;
			}
		} else if(strcmp(key, "globalArgs") == 0) {
			if(tf->global_args) {
				free(key);
				tupbuild_error(&tp, "duplicate globalArgs key");
				goto out;
			}
			if(tupbuild_parse_string_map(&tp, &tf->global_args, &tf->num_global_args) < 0) {
				free(key);
				goto out;
			}
		} else if(strcmp(key, "builds") == 0) {
			if(tf->builds) {
				free(key);
				tupbuild_error(&tp, "duplicate builds key");
				goto out;
			}
			if(tupbuild_parse_builds(&tp, tf) < 0) {
				free(key);
				goto out;
			}
		} else {
			tupbuild_warn_unknown(&tp, "top-level key", key);
			free(key);
			key = NULL;
			if(tupbuild_skip(&tp) < 0)
				goto out;
			continue;
		}
		free(key);
		key = NULL;
	}
	if(tf->num_builds == 0) {
		tupbuild_error(&tp, "TupBuild.yaml requires at least one build");
		goto out;
	}
	if(tupbuild_parser_next(&tp) < 0)
		goto out;
	if(tupbuild_expect(&tp, YAML_DOCUMENT_END_EVENT, "expected document end") < 0)
		goto out;
	if(tupbuild_parser_next(&tp) < 0)
		goto out;
	if(tupbuild_expect(&tp, YAML_STREAM_END_EVENT, "expected stream end") < 0)
		goto out;
	rc = 0;
out:
	free(key);
	yaml_event_delete(&tp.event);
	yaml_parser_delete(&tp.parser);
	if(rc < 0)
		tupbuild_free(tf);
	return rc;
}
