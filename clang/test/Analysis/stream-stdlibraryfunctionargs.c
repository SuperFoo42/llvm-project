// RUN: %clang_analyze_cc1 -analyzer-checker=core,alpha.unix.Stream,alpha.unix.StdCLibraryFunctions,debug.ExprInspection \
// RUN:   -analyzer-config alpha.unix.StdCLibraryFunctions:ModelPOSIX=true -verify=stream,any %s

// RUN: %clang_analyze_cc1 -analyzer-checker=core,alpha.unix.Stream,debug.ExprInspection \
// RUN:   -analyzer-config alpha.unix.StdCLibraryFunctions:ModelPOSIX=true -verify=stream,any %s

// RUN: %clang_analyze_cc1 -analyzer-checker=core,alpha.unix.StdCLibraryFunctions,debug.ExprInspection \
// RUN:   -analyzer-config alpha.unix.StdCLibraryFunctions:ModelPOSIX=true -verify=stdfunc,any %s

#include "Inputs/system-header-simulator.h"

extern void clang_analyzer_eval(int);

void *buf;
size_t size;
size_t n;

void test_fopen(void) {
  FILE *fp = fopen("path", "r");
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}} any-warning{{FALSE}}
  fclose(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
}

void test_fdopen(int fd) {
  FILE *fp = fdopen(fd, "r");
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}} any-warning{{FALSE}}
  fclose(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
}

void test_tmpfile(void) {
  FILE *fp = tmpfile();
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}} any-warning{{FALSE}}
  fclose(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
}

void test_fclose(void) {
  FILE *fp = tmpfile();
  fclose(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
}

void test_freopen(void) {
  FILE *fp = tmpfile();
  fp = freopen("file", "w", fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  fclose(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
}

void test_fread(void) {
  FILE *fp = tmpfile();
  size_t ret = fread(buf, size, n, fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{The 4th argument to 'fread' is NULL but should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  clang_analyzer_eval(ret <= n); // any-warning{{TRUE}}
  clang_analyzer_eval(ret == n); // any-warning{{TRUE}} any-warning{{FALSE}}

  fclose(fp);
}

void test_fwrite(void) {
  FILE *fp = tmpfile();
  size_t ret = fwrite(buf, size, n, fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{The 4th argument to 'fwrite' is NULL but should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  clang_analyzer_eval(ret <= n); // any-warning{{TRUE}}
  clang_analyzer_eval(ret == n); // any-warning{{TRUE}} any-warning{{FALSE}}

  fclose(fp);
}

void test_fseek(void) {
  FILE *fp = tmpfile();
  fseek(fp, 0, 0); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_ftell(void) {
  FILE *fp = tmpfile();
  ftell(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_rewind(void) {
  FILE *fp = tmpfile();
  rewind(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_fgetpos(void) {
  FILE *fp = tmpfile();
  fpos_t pos;
  fgetpos(fp, &pos); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_fsetpos(void) {
  FILE *fp = tmpfile();
  fpos_t pos;
  fsetpos(fp, &pos); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_clearerr(void) {
  FILE *fp = tmpfile();
  clearerr(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_feof(void) {
  FILE *fp = tmpfile();
  feof(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_ferror(void) {
  FILE *fp = tmpfile();
  ferror(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}

void test_fileno(void) {
  FILE *fp = tmpfile();
  fileno(fp); // \
  // stream-warning{{Stream pointer might be NULL}} \
  // stdfunc-warning{{should not be NULL}}
  clang_analyzer_eval(fp != NULL); // any-warning{{TRUE}}
  fclose(fp);
}
