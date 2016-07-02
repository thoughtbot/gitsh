gitsh installation
==================

The ideal way to install gitsh is via your operating system's package manager.
Currently gitsh packages are available for:

* OS X (via homebrew)
* Arch Linux
* OpenBSD (-current)

On other operating systems you should install using the tarball, following the
instructions in this guide.


Prerequisites
-------------

* Ruby version 1.9.3 or later
* gcc or a similar C compiler


gitsh and Ruby version managers
-------------------------------

The gitsh configuration script will attempt to find a system wide version of
Ruby 1.9.3 or later. Rubies installed by Ruby version managers will usually be
ignored to avoid problems when those binaries are moved or deleted.

To force gitsh to use a specific Ruby binary, set the $RUBY environment variable
when running the configuration script. For example, this will use the first ruby
binary on the $PATH:

        RUBY=$(which ruby) ./configure


libedit vs. GNU Readline
------------------------

Ruby can use two different line editors: GNU Readline, which has more features
but a more restrictive license; and libedit, which has fewer features and more
bugs but a more permissive license. Since gitsh involves a lot of line editing,
it may be preferable to use GNU Readline where possible.

You can determine which line editor your version of Ruby is compiled against
using the following command:

        path/to/ruby -r readline -e Readline.vi_editing_mode?

If the command exits silently, then your Ruby is built with GNU Readline. If it
outputs a "NotImplementedError" message, then it is built with libedit. Note
that gitsh will try to use a system-wide Ruby version, so you should make sure
you're not running this line editor version check against a Ruby installed by a
Ruby version manager.

Once gitsh is installed, it will indicate which line editor is in used when
executed with the --version option:

        $ gitsh --version
        0.10 (using GNU Readline)


Installation
------------

1. Download and extract the latest release:

        curl -OL https://github.com/thoughtbot/gitsh/releases/download/v0.10/gitsh-0.10.tar.gz
        tar -zxvf gitsh-0.10.tar.gz
        cd gitsh-0.10

2. Configure the distribution. This step will determine which version of Ruby
   should be used, which has important implications; see the notes on "gitsh and
   Ruby version managers" and "libedit vs. GNU Readline" above.

        ./configure

3. Build and install gitsh:

        make
        sudo make install
