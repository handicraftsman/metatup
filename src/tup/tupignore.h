#ifndef TUP_TUPIGNORE_H
#define TUP_TUPIGNORE_H

struct tup_entry;

int tupignore_matches_path(const char *path);
int tupignore_matches_tent(struct tup_entry *tent);
int tupignore_matches_part(struct tup_entry *dtent, const char *name, int len);

#endif
