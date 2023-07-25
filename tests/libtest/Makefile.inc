#***************************************************************************
#                                  _   _ ____  _
#  Project                     ___| | | |  _ \| |
#                             / __| | | | |_) | |
#                            | (__| |_| |  _ <| |___
#                             \___|\___/|_| \_\_____|
#
# Copyright (C) Daniel Stenberg, <daniel@haxx.se>, et al.
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
# SPDX-License-Identifier: curl
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
TIMEDIFF = ../../lib/timediff.c ../../lib/timediff.h
SUPPORTFILES = $(TIMEDIFF) first.c test.h
