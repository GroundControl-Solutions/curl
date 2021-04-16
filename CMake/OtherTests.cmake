#***************************************************************************
#                                  _   _ ____  _
#  Project                     ___| | | |  _ \| |
#                             / __| | | | |_) | |
#                            | (__| |_| |  _ <| |___
#                             \___|\___/|_| \_\_____|
#
# Copyright (C) 1998 - 2020, Daniel Stenberg, <daniel@haxx.se>, et al.
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
include(CheckCSourceCompiles)
# The begin of the sources (macros and includes)
set(_source_epilogue "#undef inline")

macro(add_header_include check header)
  if(${check})
    set(_source_epilogue "${_source_epilogue}\n#include <${header}>")
  endif()
endmacro()

set(signature_call_conv)
set(linkage )
if(HAVE_WINDOWS_H)
  add_header_include(HAVE_WINSOCK2_H "winsock2.h")
  add_header_include(HAVE_WINDOWS_H "windows.h")
  add_header_include(HAVE_WINSOCK_H "winsock.h")
  set(_source_epilogue
      "${_source_epilogue}\n#ifndef WIN32_LEAN_AND_MEAN\n#define WIN32_LEAN_AND_MEAN\n#endif")
  set(signature_call_conv "PASCAL")
  set(linkage "WINSOCK_API_LINKAGE")
  if(HAVE_LIBWS2_32)
    set(CMAKE_REQUIRED_LIBRARIES ws2_32)
  endif()
else()
  add_header_include(HAVE_SYS_TYPES_H "sys/types.h")
  add_header_include(HAVE_SYS_SOCKET_H "sys/socket.h")
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

check_cxx_source_compiles("${_source_epilogue}
int main(void) {
    recv(0, 0, 0, 0);
    return 0;
}" curl_cv_recv)
if(curl_cv_recv)
  if(NOT DEFINED curl_cv_func_recv_args OR "${curl_cv_func_recv_args}" STREQUAL "unknown")
    set(curl_recv_test_head
    "${_source_epilogue}
    //C++ includes don't work properly with curl, so define is_same ourselves
    template<class,class>struct is_same{static constexpr bool value=false;};
    template<class T>struct is_same<T,T>{static constexpr bool value=true;};
    template <class Ret, class Arg1, class Arg2, class Arg3, class Arg4>
    void check_args(Ret(${signature_call_conv} *r)(Arg1,Arg2,Arg3,Arg4)) {
      static_assert(is_same<")
    set(curl_recv_test_tail
    ">::value,\"\");
      r(0,0,0,0);
    }
    int main() {
      check_args(&recv);
    }")

    foreach(recv_retv "int" "ssize_t" )
      unset(curl_cv_func_recv_test CACHE)
      check_cxx_source_compiles("${curl_recv_test_head} Ret,${recv_retv} ${curl_recv_test_tail}" curl_cv_func_recv_test)
      message(STATUS "Tested recv return type == ${recv_retv}")
      if(curl_cv_func_recv_test)
        set(RECV_TYPE_RETV "${recv_retv}")
        break()
      endif(curl_cv_func_recv_test)
    endforeach(recv_retv)
    if(NOT DEFINED RECV_TYPE_RETV)
      message(FATAL_ERROR "Cannot determine recv return type")
    endif()

    foreach(recv_arg1 "SOCKET" "int")
      unset(curl_cv_func_recv_test CACHE)
      check_cxx_source_compiles("${curl_recv_test_head} Arg1,${recv_arg1} ${curl_recv_test_tail}" curl_cv_func_recv_test)
      message(STATUS "Tested recv socket type == ${recv_arg1}")
      if(curl_cv_func_recv_test)
        set(RECV_TYPE_ARG1 "${recv_arg1}")
        break()
      endif(curl_cv_func_recv_test)
    endforeach(recv_arg1)
    if(NOT DEFINED RECV_TYPE_ARG1)
      message(FATAL_ERROR "Cannot determine recv socket type")
    endif()

    foreach(recv_arg2 "void *" "char *")
      unset(curl_cv_func_recv_test CACHE)
      check_cxx_source_compiles("${curl_recv_test_head} Arg2,${recv_arg2} ${curl_recv_test_tail}" curl_cv_func_recv_test)
      message(STATUS "Tested recv buffer type == ${recv_arg2}")
      if(curl_cv_func_recv_test)
        set(RECV_TYPE_ARG2 "${recv_arg2}")
        break()
      endif(curl_cv_func_recv_test)
    endforeach(recv_arg2)
    if(NOT DEFINED RECV_TYPE_ARG2)
      message(FATAL_ERROR "Cannot determine recv buffer type")
    endif()

    foreach(recv_arg3 "size_t" "int" "socklen_t" "unsigned int")
      unset(curl_cv_func_recv_test CACHE)
      check_cxx_source_compiles("${curl_recv_test_head} Arg3,${recv_arg3} ${curl_recv_test_tail}" curl_cv_func_recv_test)
      message(STATUS "Tested recv length type == ${recv_arg3}")
      if(curl_cv_func_recv_test)
        set(RECV_TYPE_ARG3 "${recv_arg3}")
        break()
      endif(curl_cv_func_recv_test)
    endforeach(recv_arg3)
    if(NOT DEFINED RECV_TYPE_ARG3)
      message(FATAL_ERROR "Cannot determine recv length type")
    endif()

    foreach(recv_arg4 "int" "unsigned int")
      unset(curl_cv_func_recv_test CACHE)
      check_cxx_source_compiles("${curl_recv_test_head} Arg4,${recv_arg4} ${curl_recv_test_tail}" curl_cv_func_recv_test)
      message(STATUS "Tested recv flags type == ${recv_arg4}")
      if(curl_cv_func_recv_test)
        set(RECV_TYPE_ARG4 "${recv_arg4}")
        break()
      endif(curl_cv_func_recv_test)
    endforeach(recv_arg4)
    if(NOT DEFINED RECV_TYPE_ARG4)
      message(FATAL_ERROR "Cannot determine recv flags type")
    endif()
    set(curl_cv_func_recv_args
            "${RECV_TYPE_ARG1},${RECV_TYPE_ARG2},${RECV_TYPE_ARG3},${RECV_TYPE_ARG4},${RECV_TYPE_RETV}")
    set(HAVE_RECV 1)
    set(curl_cv_func_recv_done 1)
  endif()

  if(NOT DEFINED curl_cv_func_recv_args OR curl_cv_func_recv_args STREQUAL "unknown")
    foreach(recv_retv "int" "ssize_t" )
      foreach(recv_arg1 "SOCKET" "int" )
        foreach(recv_arg2 "char *" "void *" )
          foreach(recv_arg3 "int" "size_t" "socklen_t" "unsigned int")
            foreach(recv_arg4 "int" "unsigned int")
              if(NOT curl_cv_func_recv_done)
                unset(curl_cv_func_recv_test CACHE)
                check_c_source_compiles("
                  ${_source_epilogue}
                  #ifdef WINSOCK_API_LINKAGE
                  WINSOCK_API_LINKAGE
                  #endif
                  extern ${recv_retv} ${signature_call_conv}
                  recv(${recv_arg1}, ${recv_arg2}, ${recv_arg3}, ${recv_arg4});
                  int main(void) {
                    ${recv_arg1} s=0;
                    ${recv_arg2} buf=0;
                    ${recv_arg3} len=0;
                    ${recv_arg4} flags=0;
                    ${recv_retv} res = recv(s, buf, len, flags);
                    (void) res;
                    return 0;
                  }"
                  curl_cv_func_recv_test)
                message(STATUS
                  "Tested: ${recv_retv} recv(${recv_arg1}, ${recv_arg2}, ${recv_arg3}, ${recv_arg4})")
                if(curl_cv_func_recv_test)
                  set(curl_cv_func_recv_args
                    "${recv_arg1},${recv_arg2},${recv_arg3},${recv_arg4},${recv_retv}")
                  set(RECV_TYPE_ARG1 "${recv_arg1}")
                  set(RECV_TYPE_ARG2 "${recv_arg2}")
                  set(RECV_TYPE_ARG3 "${recv_arg3}")
                  set(RECV_TYPE_ARG4 "${recv_arg4}")
                  set(RECV_TYPE_RETV "${recv_retv}")
                  set(HAVE_RECV 1)
                  set(curl_cv_func_recv_done 1)
                endif()
              endif()
            endforeach()
          endforeach()
        endforeach()
      endforeach()
    endforeach()
  else()
    string(REGEX REPLACE "^([^,]*),[^,]*,[^,]*,[^,]*,[^,]*$" "\\1" RECV_TYPE_ARG1 "${curl_cv_func_recv_args}")
    string(REGEX REPLACE "^[^,]*,([^,]*),[^,]*,[^,]*,[^,]*$" "\\1" RECV_TYPE_ARG2 "${curl_cv_func_recv_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,([^,]*),[^,]*,[^,]*$" "\\1" RECV_TYPE_ARG3 "${curl_cv_func_recv_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,[^,]*,([^,]*),[^,]*$" "\\1" RECV_TYPE_ARG4 "${curl_cv_func_recv_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,[^,]*,[^,]*,([^,]*)$" "\\1" RECV_TYPE_RETV "${curl_cv_func_recv_args}")
  endif()

  if(curl_cv_func_recv_args STREQUAL "unknown")
    message(FATAL_ERROR "Cannot find proper types to use for recv args")
  endif()
else()
  message(FATAL_ERROR "Unable to link function recv")
endif()
set(curl_cv_func_recv_args "${curl_cv_func_recv_args}" CACHE INTERNAL "Arguments for recv")
set(HAVE_RECV 1)

check_cxx_source_compiles("${_source_epilogue}
int main(void) {
    send(0, 0, 0, 0);
    return 0;
}" curl_cv_send)
if(curl_cv_send)
  if(NOT DEFINED curl_cv_func_send_args OR "${curl_cv_func_send_args}" STREQUAL "unknown")
    set(curl_send_test_head
            "${_source_epilogue}
            template <class T, class U>struct is_same{static constexpr bool value=false;};
            template<class T>struct is_same<T,T>{static constexpr bool value=true;};
            template <class Ret, class Arg1, class Arg2, class Arg3, class Arg4>
            void check_args(Ret(${signature_call_conv} *r)(Arg1,Arg2,Arg3,Arg4)) {
              static_assert(is_same<")
    set(curl_send_test_tail
            ">::value,\"\");
              r(0,0,0,0);
            }
            int main() {
              check_args(&send);
            }")

    foreach(send_retv "int" "ssize_t" )
      unset(curl_cv_func_send_test CACHE)
      check_cxx_source_compiles("${curl_send_test_head} Ret,${send_retv} ${curl_send_test_tail}" curl_cv_func_send_test)
      message(STATUS "Tested send return type == ${send_retv}")
      if(curl_cv_func_send_test)
        set(SEND_TYPE_RETV "${send_retv}")
        break()
      endif(curl_cv_func_send_test)
    endforeach(send_retv)
    if(NOT DEFINED SEND_TYPE_RETV)
      message(FATAL_ERROR "Cannot determine send return type")
    endif()

    foreach(send_arg1 "int" "ssize_t" "SOCKET")
      unset(curl_cv_func_send_test CACHE)
      check_cxx_source_compiles("${curl_send_test_head} Arg1,${send_arg1} ${curl_send_test_tail}" curl_cv_func_send_test)
      message(STATUS "Tested send socket type == ${send_arg1}")
      if(curl_cv_func_send_test)
        set(SEND_TYPE_ARG1 "${send_arg1}")
        break()
      endif(curl_cv_func_send_test)
    endforeach(send_arg1)
    if(NOT DEFINED SEND_TYPE_ARG1)
      message(FATAL_ERROR "Cannot determine send socket type")
    endif()

    foreach(send_arg2 "const void *" "void *" "char *" "const char *")
      unset(curl_cv_func_send_test CACHE)
      check_cxx_source_compiles("${curl_send_test_head} Arg2,${send_arg2} ${curl_send_test_tail}" curl_cv_func_send_test)
      message(STATUS "Tested send buffer type == ${send_arg2}")
      if(curl_cv_func_send_test)
        set(SEND_TYPE_ARG2 "${send_arg2}")
        break()
      endif(curl_cv_func_send_test)
    endforeach(send_arg2)
    if(NOT DEFINED SEND_TYPE_ARG2)
      message(FATAL_ERROR "Cannot determine send buffer type")
    endif()
    string(REGEX REPLACE "(const) .*" "\\1" send_qual_arg2 "${SEND_TYPE_ARG2}")
    string(REGEX REPLACE "const (.*)" "\\1" SEND_TYPE_ARG2 "${SEND_TYPE_ARG2}")

    foreach(send_arg3 "size_t" "int" "socklen_t" "unsigned int")
      unset(curl_cv_func_send_test CACHE)
      check_cxx_source_compiles("${curl_send_test_head} Arg3,${send_arg3} ${curl_send_test_tail}" curl_cv_func_send_test)
      message(STATUS "Tested send length type == ${send_arg3}")
      if(curl_cv_func_send_test)
        set(SEND_TYPE_ARG3 "${send_arg3}")
        break()
      endif(curl_cv_func_send_test)
    endforeach(send_arg3)
    if(NOT DEFINED SEND_TYPE_ARG3)
      message(FATAL_ERROR "Cannot determine send length type")
    endif()

    foreach(send_arg4 "int" "unsigned int")
      unset(curl_cv_func_send_test CACHE)
      check_cxx_source_compiles("${curl_send_test_head} Arg4,${send_arg4} ${curl_send_test_tail}" curl_cv_func_send_test)
      message(STATUS "Tested send flags type == ${send_arg4}")
      if(curl_cv_func_send_test)
        set(SEND_TYPE_ARG4 "${send_arg4}")
        break()
      endif(curl_cv_func_send_test)
    endforeach(send_arg4)
    if(NOT DEFINED SEND_TYPE_ARG4)
      message(FATAL_ERROR "Cannot determine send flags type")
    endif()

    set(curl_cv_func_send_args
            "${SEND_TYPE_ARG1},${SEND_TYPE_ARG2},${SEND_TYPE_ARG3},${SEND_TYPE_ARG4},${SEND_TYPE_RETV},${send_qual_arg2}")
    set(HAVE_SEND 1)
    set(curl_cv_func_send_done 1)

  else()
    string(REGEX REPLACE "^([^,]*),[^,]*,[^,]*,[^,]*,[^,]*,[^,]*$" "\\1" SEND_TYPE_ARG1 "${curl_cv_func_send_args}")
    string(REGEX REPLACE "^[^,]*,([^,]*),[^,]*,[^,]*,[^,]*,[^,]*$" "\\1" SEND_TYPE_ARG2 "${curl_cv_func_send_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,([^,]*),[^,]*,[^,]*,[^,]*$" "\\1" SEND_TYPE_ARG3 "${curl_cv_func_send_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,[^,]*,([^,]*),[^,]*,[^,]*$" "\\1" SEND_TYPE_ARG4 "${curl_cv_func_send_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,[^,]*,[^,]*,([^,]*),[^,]*$" "\\1" SEND_TYPE_RETV "${curl_cv_func_send_args}")
    string(REGEX REPLACE "^[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,([^,]*)$" "\\1" SEND_QUAL_ARG2 "${curl_cv_func_send_args}")
  endif()

  if("${curl_cv_func_send_args}" STREQUAL "unknown")
    message(FATAL_ERROR "Cannot find proper types to use for send args")
  endif()
  set(SEND_QUAL_ARG2 "const")
else()
  message(FATAL_ERROR "Unable to link function send")
endif()
set(curl_cv_func_send_args "${curl_cv_func_send_args}" CACHE INTERNAL "Arguments for send")
set(HAVE_SEND 1)

check_cxx_source_compiles("${_source_epilogue}
  int main(void) {
    int flag = MSG_NOSIGNAL;
    (void)flag;
    return 0;
  }" HAVE_MSG_NOSIGNAL)

if(NOT HAVE_WINDOWS_H)
  add_header_include(HAVE_SYS_TIME_H "sys/time.h")
  add_header_include(TIME_WITH_SYS_TIME "time.h")
  add_header_include(HAVE_TIME_H "time.h")
endif()
check_cxx_source_compiles("${_source_epilogue}
int main(void) {
  struct timeval ts;
  ts.tv_sec  = 0;
  ts.tv_usec = 0;
  (void)ts;
  return 0;
}" HAVE_STRUCT_TIMEVAL)

set(HAVE_SIG_ATOMIC_T 1)
set(CMAKE_REQUIRED_FLAGS)
if(HAVE_SIGNAL_H)
  set(CMAKE_REQUIRED_FLAGS "-DHAVE_SIGNAL_H")
  set(CMAKE_EXTRA_INCLUDE_FILES "signal.h")
endif()
check_type_size("sig_atomic_t" SIZEOF_SIG_ATOMIC_T)
if(HAVE_SIZEOF_SIG_ATOMIC_T)
  check_cxx_source_compiles("
    #ifdef HAVE_SIGNAL_H
    #  include <signal.h>
    #endif
    int main(void) {
      static volatile sig_atomic_t dummy = 0;
      (void)dummy;
      return 0;
    }" HAVE_SIG_ATOMIC_T_NOT_VOLATILE)
  if(NOT HAVE_SIG_ATOMIC_T_NOT_VOLATILE)
    set(HAVE_SIG_ATOMIC_T_VOLATILE 1)
  endif()
endif()

if(HAVE_WINDOWS_H)
  set(CMAKE_EXTRA_INCLUDE_FILES winsock2.h)
else()
  set(CMAKE_EXTRA_INCLUDE_FILES)
  if(HAVE_SYS_SOCKET_H)
    set(CMAKE_EXTRA_INCLUDE_FILES sys/socket.h)
  endif()
endif()

check_type_size("struct sockaddr_storage" SIZEOF_STRUCT_SOCKADDR_STORAGE)
if(HAVE_SIZEOF_STRUCT_SOCKADDR_STORAGE)
  set(HAVE_STRUCT_SOCKADDR_STORAGE 1)
endif()

check_type_size("struct pollfd" SIZEOF_STRUCT_POLLFD)
if(HAVE_SIZEOF_STRUCT_POLLFD)
	set(HAVE_STRUCT_POLLFD 1)
endif()
unset(CMAKE_TRY_COMPILE_TARGET_TYPE)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  # if not cross-compilation...
  include(CheckCSourceRuns)
  set(CMAKE_REQUIRED_FLAGS "")
  if(HAVE_SYS_POLL_H)
    set(CMAKE_REQUIRED_FLAGS "-DHAVE_SYS_POLL_H")
  elseif(HAVE_POLL_H)
    set(CMAKE_REQUIRED_FLAGS "-DHAVE_POLL_H")
  endif()
  check_c_source_runs("
    #include <stdlib.h>
    #include <sys/time.h>

    #ifdef HAVE_SYS_POLL_H
    #  include <sys/poll.h>
    #elif  HAVE_POLL_H
    #  include <poll.h>
    #endif

    int main(void)
    {
        if(0 != poll(0, 0, 10)) {
          return 1; /* fail */
        }
        else {
          /* detect the 10.12 poll() breakage */
          struct timeval before, after;
          int rc;
          size_t us;

          gettimeofday(&before, NULL);
          rc = poll(NULL, 0, 500);
          gettimeofday(&after, NULL);

          us = (after.tv_sec - before.tv_sec) * 1000000 +
            (after.tv_usec - before.tv_usec);

          if(us < 400000) {
            return 1;
          }
        }
        return 0;
    }" HAVE_POLL_FINE)
endif()

