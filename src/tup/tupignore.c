#include "tupignore.h"
#include "compat.h"
#include "config.h"
#include "entry.h"
#include "variant.h"
#include <errno.h>
#include <fnmatch.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct tupignore_state {
	char **patterns;
	int num_patterns;
	int loaded;
};

static struct tupignore_state state;

static int add_pattern(char *pattern)
{
	char **tmp = realloc(state.patterns, sizeof(*tmp) * (state.num_patterns + 1));
	if(!tmp) {
		perror("realloc");
		return -1;
	}
	state.patterns = tmp;
	state.patterns[state.num_patterns++] = pattern;
	return 0;
}

static void trim_line(char *line)
{
	char *start = line;
	char *end;

	while(*start == ' ' || *start == '\t')
		start++;
	if(start != line)
		memmove(line, start, strlen(start) + 1);
	end = line + strlen(line);
	while(end > line && (end[-1] == '\n' || end[-1] == '\r' || end[-1] == ' ' || end[-1] == '\t'))
		end--;
	*end = 0;
}

static int load_patterns(void)
{
	char path[PATH_MAX];
	FILE *f;
	char *line = NULL;
	size_t cap = 0;

	if(state.loaded)
		return 0;
	state.loaded = 1;

	if(snprintf(path, sizeof(path), "%s/.tupignore", get_tup_top()) >= (int)sizeof(path)) {
		fprintf(stderr, "tup error: .tupignore path is too long.\n");
		return -1;
	}
	f = fopen(path, "r");
	if(!f) {
		if(errno == ENOENT)
			return 0;
		perror(path);
		return -1;
	}
	while(getline(&line, &cap, f) >= 0) {
		char *copy;

		trim_line(line);
		if(line[0] == 0 || line[0] == '#')
			continue;
		copy = strdup(line);
		if(!copy) {
			perror("strdup");
			free(line);
			fclose(f);
			return -1;
		}
		if(add_pattern(copy) < 0) {
			free(copy);
			free(line);
			fclose(f);
			return -1;
		}
	}
	free(line);
	if(fclose(f) != 0) {
		perror(path);
		return -1;
	}
	return 0;
}

static const char *normalize_path(const char *path)
{
	while(path[0] == '.' && path[1] == '/')
		path += 2;
	while(path[0] == '/')
		path++;
	return path;
}

static int pattern_matches_any_ancestor(const char *pattern, const char *path)
{
	const char *slash;
	size_t len;
	char *copy;
	int rc = 0;

	if(fnmatch(pattern, path, 0) == 0)
		return 1;
	copy = strdup(path);
	if(!copy) {
		perror("strdup");
		return -1;
	}
	len = strlen(copy);
	while(len > 0) {
		slash = strrchr(copy, '/');
		if(!slash)
			break;
		copy[slash - copy] = 0;
		if(fnmatch(pattern, copy, 0) == 0) {
			rc = 1;
			break;
		}
		len = strlen(copy);
	}
	free(copy);
	return rc;
}

int tupignore_matches_path(const char *path)
{
	int x;
	const char *normalized = normalize_path(path);

	if(normalized[0] == 0 || strcmp(normalized, ".") == 0)
		return 0;
	if(load_patterns() < 0)
		return -1;
	for(x=0; x<state.num_patterns; x++) {
		int rc = pattern_matches_any_ancestor(state.patterns[x], normalized);
		if(rc < 0)
			return -1;
		if(rc)
			return 1;
	}
	return 0;
}

int tupignore_matches_tent(struct tup_entry *tent)
{
	char path[PATH_MAX];
	struct tup_entry *srctent = variant_tent_to_srctent(tent);
	int rc;

	if(!srctent)
		srctent = tent;
	rc = snprint_tup_entry(path, sizeof(path), srctent);
	if(rc < 0 || rc >= (int)sizeof(path)) {
		fprintf(stderr, "tup error: Path is too long for .tupignore matching.\n");
		return -1;
	}
	return tupignore_matches_path(path);
}

int tupignore_matches_part(struct tup_entry *dtent, const char *name, int len)
{
	char path[PATH_MAX];
	char base[PATH_MAX];
	struct tup_entry *srctent = variant_tent_to_srctent(dtent);
	int rc;

	if(!srctent)
		srctent = dtent;
	rc = snprint_tup_entry(base, sizeof(base), srctent);
	if(rc < 0 || rc >= (int)sizeof(base)) {
		fprintf(stderr, "tup error: Path is too long for .tupignore matching.\n");
		return -1;
	}
	if(strcmp(base, ".") == 0) {
		if(snprintf(path, sizeof(path), "%.*s", len, name) >= (int)sizeof(path)) {
			fprintf(stderr, "tup error: Path is too long for .tupignore matching.\n");
			return -1;
		}
	} else {
		if(snprintf(path, sizeof(path), "%s/%.*s", base, len, name) >= (int)sizeof(path)) {
			fprintf(stderr, "tup error: Path is too long for .tupignore matching.\n");
			return -1;
		}
	}
	return tupignore_matches_path(path);
}
