#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT(gitsh, 0.7, hello@thoughtbot.com)
AM_INIT_AUTOMAKE

AC_ARG_VAR([RUBY],[The path of the Ruby binary to use])

AC_CONFIG_MACRO_DIR([m4])

AC_PROG_CC
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

VENDOR_DIRECTORY="vendor/gems"

test -d $VENDOR_DIRECTORY || mkdir -p $VENDOR_DIRECTORY
newer=$(ls -t $srcdir/Gemfile.lock $VENDOR_DIRECTORY/setup.rb 2>/dev/null | (read n; echo $n))
if test "$newer" == "$srcdir/Gemfile.lock"; then
    rm -rf $VENDOR_DIRECTORY
    $srcdir/vendor/vendorize $VENDOR_DIRECTORY || AC_MSG_ERROR([Vendorizing gems failed])
fi

rubydir=$datadir/$PACKAGE/ruby
pkgrubydir=$rubydir/$PACKAGE
libfiles="$(cd "$(dirname "$0")/lib/gitsh"; echo *.rb)"
vendorfiles="$(cd "$(dirname "$0")/vendor"; echo $(find gems -type f))"
testfiles="$(cd "$(dirname "$0")/spec"; echo $(find integration units -type f -name \*rb))"
gemsetuppath=$datadir/$PACKAGE/gems/setup.rb

AC_SUBST([RUBY])
AC_SUBST([rubydir])
AC_SUBST([pkgrubydir])
AC_SUBST([libfiles])
AC_SUBST([vendorfiles])
AC_SUBST([testfiles])
AC_SUBST([gemsetuppath])

AC_CONFIG_FILES([Makefile src/Makefile lib/gitsh/Makefile man/Makefile vendor/Makefile spec/Makefile])
AC_OUTPUT
