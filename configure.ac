#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT(gitsh, 0.2, hello@thoughtbot.com)
AM_INIT_AUTOMAKE

AC_ARG_VAR([RUBY],[The path of the Ruby binary to use])

AC_CONFIG_MACRO_DIR([m4])

AC_PATH_PROGS([RUBY], [ruby ruby20], [], $(getconf PATH))
AC_PATH_PROGS([RUBY], [ruby ruby20])

if test -n $RUBY; then
  case $RUBY in $HOME/*)
    AC_MSG_WARN([Using a non-system Ruby. Disable rvm, rbenv, etc. or set \$RUBY])
  esac
fi

AX_PROG_RUBY_VERSION(
  [2.0],
  [],
  AC_MSG_ERROR(Ruby 2.0 or later is required to install gitsh)
)

rubydir=$datadir/$PACKAGE/ruby
pkgrubydir=$rubydir/$PACKAGE
libfiles="$(cd `dirname $0`/lib/gitsh; echo *.rb)"
gemsetuppath=$datadir/$PACKAGE/gems/setup.rb

AC_SUBST([RUBY])
AC_SUBST([rubydir])
AC_SUBST([pkgrubydir])
AC_SUBST([libfiles])
AC_SUBST([gemsetuppath])

AC_CONFIG_FILES([Makefile src/Makefile lib/gitsh/Makefile man/Makefile vendor/Makefile])
AC_OUTPUT
