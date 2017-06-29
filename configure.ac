#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT(gitsh, 0.12, hello@thoughtbot.com)
AM_INIT_AUTOMAKE([subdir-objects])

AC_ARG_VAR([RUBY],[The path of the Ruby binary to use])
AC_ARG_VAR(
  [READLINE_LIB],
  [The name of the readline library on your system, e.g. ereadline on OpenBSD]
)
AC_ARG_VAR(
  [READLINE_ARCH],
  [The architecture of the readline library on your system, e.g. x86_64]
)

AC_CONFIG_MACRO_DIR([m4])

AC_PROG_CC
AC_PATH_PROGS([RUBY], [ruby ruby20 ruby21 ruby22 ruby23 ruby24], [], $(getconf PATH))
AC_PATH_PROGS([RUBY], [ruby ruby20 ruby21 ruby22 ruby23 ruby24])

if test -n $RUBY; then
  case $RUBY in $HOME/*)
    AC_MSG_WARN([Using a non-system Ruby. Disable rvm, rbenv, etc. or set \$RUBY])
  esac
fi

AX_PROG_RUBY_VERSION(
  [2.0.0],
  [],
  AC_MSG_ERROR(Ruby 2.0.0 or later is required to install gitsh)
)

VENDOR_DIRECTORY="vendor/gems"

test -d $VENDOR_DIRECTORY || mkdir -p $VENDOR_DIRECTORY
newer=$(ls -t $srcdir/Gemfile.lock $VENDOR_DIRECTORY/setup.rb 2>/dev/null | (read n; echo $n))
if test "$newer" == "$srcdir/Gemfile.lock"; then
    rm -rf $VENDOR_DIRECTORY
    $srcdir/vendor/vendorize $VENDOR_DIRECTORY || AC_MSG_ERROR([Vendorizing gems failed])
fi

AS_IF([test "x$READLINE_LIB" = x], [READLINE_LIB="readline"])
AS_IF(
    [test "x$READLINE_ARCH" = x],
    [readline_arch_arg=""],
    [readline_arch_arg="--with-arch-flag=\"-arch $READLINE_ARCH\""]
)
current_dir="$PWD"
cd "$srcdir/ext/gitsh"
AS_IF(
    [$RUBY extconf.rb --with-ldflags="$LDFLAGS" --with-cppflags="$CPPFLAGS" \
      --with-readlinelib="$READLINE_LIB" "$readline_arch_arg"],
    [],
    AC_MSG_ERROR(Failed to configure Ruby extension)
)
cd "$current_dir"

rubydir=$datadir/$PACKAGE/ruby
rubylibdir=$rubydir/lib
pkgrubylibdir=$rubylibdir/gitsh
pkgsysconfdir=$sysconfdir/gitsh
libfiles="$(echo $(find "$srcdir/lib/gitsh" -name \*.rb))"
vendorfiles="$(echo $(find "$srcdir/vendor/gems" -type f))"
testfiles="$(echo $(find "$srcdir/spec/integration" "$srcdir/spec/units" -type f -name \*rb))"
gemsetuppath=$datadir/$PACKAGE/vendor/gems/setup.rb

AC_SUBST([RUBY])
AC_SUBST([rubydir])
AC_SUBST([rubylibdir])
AC_SUBST([pkgrubylibdir])
AC_SUBST([pkgsysconfdir])
AC_SUBST([libfiles])
AC_SUBST([vendorfiles])
AC_SUBST([testfiles])
AC_SUBST([gemsetuppath])

AC_CONFIG_FILES([Makefile INSTALL])
AC_OUTPUT
