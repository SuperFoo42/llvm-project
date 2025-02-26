.. _libc_gpu_support:

===================
Supported Functions
===================

.. include:: ../check.rst

.. contents:: Table of Contents
  :depth: 4
  :local:

The following functions and headers are supported at least partially on the
device. Some functions are implemented fully on the GPU, while others require a
`remote procedure call <libc_gpu_rpc>`_.

ctype.h
-------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
isalnum        |check|
isalpha        |check|
isascii        |check|
isblank        |check|
iscntrl        |check|
isdigit        |check|
isgraph        |check|
islower        |check|
isprint        |check|
ispunct        |check|
isspace        |check|
isupper        |check|
isxdigit       |check|
toascii        |check|
tolower        |check|
toupper        |check|
=============  =========  ============

string.h
--------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
bcmp           |check|
bcopy          |check|
bzero          |check|
index          |check|
memccpy        |check|
memchr         |check|
memcmp         |check|
memcpy         |check|
memmem         |check|
memmove        |check|
mempcpy        |check|
memrchr        |check|
memset         |check|
rindex         |check|
stpcpy         |check|
stpncpy        |check|
strcasecmp     |check|
strcasestr     |check|
strcat         |check|
strchr         |check|
strchrnul      |check|
strcmp         |check|
strcoll        |check|
strcpy         |check|
strcspn        |check|
strdup         |check|
strlcat        |check|
strlcpy        |check|
strlen         |check|
strncasecmp    |check|
strncat        |check|
strncmp        |check|
strncpy        |check|
strndup        |check|
strnlen        |check|
strpbrk        |check|
strrchr        |check|
strsep         |check|
strspn         |check|
strstr         |check|
strtok         |check|
strtok_r       |check|
strxfrm        |check|
=============  =========  ============

stdlib.h
--------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
abs            |check|
atoi           |check|
atof           |check|
atol           |check|
atoll          |check|
exit           |check|    |check|
abort          |check|    |check|
labs           |check|
llabs          |check|
div            |check|
ldiv           |check|
lldiv          |check|
bsearch        |check|
qsort          |check|
qsort_r        |check|
strtod         |check|
strtof         |check|
strtol         |check|
strtold        |check|
strtoll        |check|
strtoul        |check|
strtoull       |check|
=============  =========  ============

inttypes.h
----------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
imaxabs        |check|
imaxdiv        |check|
strtoimax      |check|
strtoumax      |check|
=============  =========  ============

stdio.h
-------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
puts           |check|    |check|
fputs          |check|    |check|
fputc          |check|    |check|
fwrite         |check|    |check|
putc           |check|    |check|
putchar        |check|    |check|
fclose         |check|    |check|
fopen          |check|    |check|
fread          |check|    |check|
=============  =========  ============

time.h
------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
clock          |check|
nanosleep      |check|
=============  =========  ============

assert.h
--------

=============  =========  ============
Function Name  Available  RPC Required
=============  =========  ============
assert         |check|    |check|
__assert_fail  |check|    |check|
=============  =========  ============
