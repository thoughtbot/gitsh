#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT(gitsh, 0.1, hello@thoughtbot.com)
AM_INIT_AUTOMAKE

AC_ARG_VAR([RUBY],[The path of the Ruby binary to use])

AC_CONFIG_MACRO_DIR([m4])

# Check for Ruby 2.0
default_system_path=$(env -i sh -c 'echo $PATH')
AC_PATH_PROGS([RUBY], [ruby ruby20], [], [$default_system_path])
AX_PROG_RUBY_VERSION(
  [2.0],
  [],
  AC_MSG_ERROR(Ruby 2.0 or later is required to install gitsh)
)

rubydir=$datadir/$PACKAGE/ruby
pkgrubydir=$rubydir/$PACKAGE
libfiles="$(cd `dirname $0`/lib/gitsh; echo *.rb)"

AC_SUBST([RUBY])
AC_SUBST([rubydir])
AC_SUBST([pkgrubydir])
AC_SUBST([libfiles])

AC_CONFIG_FILES([Makefile src/Makefile lib/gitsh/Makefile man/Makefile])
AC_OUTPUT
