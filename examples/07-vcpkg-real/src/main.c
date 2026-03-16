#include <sqlite3.h>
#include <stdio.h>

int main(void)
{
  sqlite3 *db = NULL;

  if(sqlite3_open(":memory:", &db) != SQLITE_OK) {
    fprintf(stderr, "sqlite3_open failed\n");
    sqlite3_close(db);
    return 1;
  }

  printf("sqlite3 %s\n", sqlite3_libversion());
  sqlite3_close(db);
  return 0;
}
