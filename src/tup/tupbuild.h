#ifndef tup_tupbuild_h
#define tup_tupbuild_h

struct tupbuild_kv {
	char *key;
	char *value;
};

struct tupbuild_dep {
	char *build;
	char *as;
};

struct tupbuild_dist {
	char *from_return;
	char *path;
};

struct tupbuild_build {
	char *name;
	char *tupfile;
	char *function;
	char *builddir;
	char *profile;
	struct tupbuild_kv *args;
	int num_args;
	struct tupbuild_dep *depends;
	int num_depends;
	struct tupbuild_dist *dists;
	int num_dists;
};

struct tupbuild_file {
	int strict;
	int auto_compiledb;
	struct tupbuild_kv *global_args;
	int num_global_args;
	struct tupbuild_build *builds;
	int num_builds;
};

int tupbuild_parse(const char *filename, const char *data, int len,
		   struct tupbuild_file *tf, char **err);
void tupbuild_free(struct tupbuild_file *tf);

#endif
