#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT(gitsh, 0.1, hello@thoughtbot.com)
AM_INIT_AUTOMAKE

AC_ARG_VAR([RUBY],[The path of the Ruby binary to use])
AC_ARG_VAR([RUBY_LIB],[A directory on Ruby's LOAD_PATH to install to])

AC_CONFIG_MACRO_DIR([m4])

# Check for Ruby 2.0
AC_PATH_PROGS([RUBY], [ruby ruby20])
AX_PROG_RUBY_VERSION(
  [2.0],
  [],
  AC_MSG_ERROR(Ruby 2.0 or later is required to install gitsh)
)
AC_SUBST([RUBY])

# Find a directory on Ruby's load path
test $RUBY_LIB || RUBY_LIB=`$RUBY -e 'puts RbConfig::CONFIG[["sitelibdir"]]'`
AC_SUBST([RUBY_LIB])

AC_CONFIG_FILES([Makefile bin/Makefile lib/Makefile man/Makefile])
AC_OUTPUT([bin/gitsh])
