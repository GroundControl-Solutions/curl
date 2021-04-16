#***************************************************************************
#                                  _   _ ____  _
#  Project                     ___| | | |  _ \| |
#                             / __| | | | |_) | |
#                            | (__| |_| |  _ <| |___
#                             \___|\___/|_| \_\_____|
#
# Copyright (C) 1998 - 2021, Daniel Stenberg, <daniel@haxx.se>, et al.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at https://curl.se/docs/copyright.html.
#
# You may opt to use, copy, modify, merge, publish, distribute and/or sell
# copies of the Software, and permit persons to whom the Software is
# furnished to do so, under the terms of the COPYING file.
#
# This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
# KIND, either express or implied.
#
###########################################################################
# files used only in some libcurl test programs
TESTUTIL = testutil.c testutil.h

# files used only in some libcurl test programs
TSTTRACE = testtrace.c testtrace.h

# files used only in some libcurl test programs
WARNLESS = ../../lib/warnless.c ../../lib/warnless.h

# files used only in some libcurl test programs
MULTIBYTE = ../../lib/curl_multibyte.c ../../lib/curl_multibyte.h

# these files are used in every single test program below
SUPPORTFILES = first.c test.h

# These are all libcurl test programs
noinst_PROGRAMS = chkhostname libauthretry libntlmconnect

chkdecimalpoint_SOURCES = chkdecimalpoint.c ../../lib/mprintf.c \
 ../../lib/curl_ctype.c  ../../lib/dynbuf.c ../../lib/strdup.c
chkdecimalpoint_LDADD =
chkdecimalpoint_CPPFLAGS = $(AM_CPPFLAGS) -DCURL_STATICLIB \
 -DCURLX_NO_MEMORY_CALLBACKS -DBUILDING_LIBCURL

chkhostname_SOURCES = chkhostname.c ../../lib/curl_gethostname.c
chkhostname_LDADD = @CURL_NETWORK_LIBS@
chkhostname_DEPENDENCIES =
chkhostname_CPPFLAGS = $(AM_CPPFLAGS)

libntlmconnect_SOURCES = libntlmconnect.c $(SUPPORTFILES) $(TESTUTIL) $(WARNLESS)
libntlmconnect_LDADD = $(TESTUTIL_LIBS)
libntlmconnect_CPPFLAGS = $(AM_CPPFLAGS)

libauthretry_SOURCES = libauthretry.c $(SUPPORTFILES)
libauthretry_CPPFLAGS = $(AM_CPPFLAGS)
