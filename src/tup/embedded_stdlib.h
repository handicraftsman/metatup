#ifndef TUP_EMBEDDED_STDLIB_H
#define TUP_EMBEDDED_STDLIB_H

struct metatup_embedded_file {
	const char *path;
	const unsigned char *data;
	unsigned int len;
};

extern const struct metatup_embedded_file metatup_stdlib_files[];
extern const unsigned int metatup_stdlib_files_count;

#endif
