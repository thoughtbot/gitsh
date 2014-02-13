#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT(gitsh, 0.4, hello@thoughtbot.com)
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
  [1.9.3],
  [],
  AC_MSG_ERROR(Ruby 1.9.3 or later is required to install gitsh)
)

newer=$(ls -t $srcdir/Gemfile.lock $srcdir/vendor/gems/setup.rb 2>/dev/null | (read n; echo $n))
if test "$newer" == "$srcdir/Gemfile.lock"; then
    rm -rf vendor/gems
    $srcdir/vendor/vendorize vendor/gems || AC_MSG_ERROR([Vendorizing gems failed])
fi

rubydir=$datadir/$PACKAGE/ruby
pkgrubydir=$rubydir/$PACKAGE
libfiles="$(cd "$(dirname "$0")/lib/gitsh"; echo *.rb)"
vendorfiles="$(cd "$(dirname "$0")/vendor"; echo $(find gems -type f))"
gemsetuppath=$datadir/$PACKAGE/gems/setup.rb

AC_SUBST([RUBY])
AC_SUBST([rubydir])
AC_SUBST([pkgrubydir])
AC_SUBST([libfiles])
AC_SUBST([vendorfiles])
AC_SUBST([gemsetuppath])

AC_CONFIG_FILES([Makefile src/Makefile lib/gitsh/Makefile man/Makefile vendor/Makefile])
AC_OUTPUT
