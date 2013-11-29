# gitsh

The `gitsh` program is an interactive shell for git. From within `gitsh` you can
issue any git command, even using your local aliases and configuration.

## Installing gitsh

* On Mac OS X, via homebrew:

        brew tap thoughtbot/gitsh
        brew install gitsh

* On Arch Linux: https://github.com/thoughtbot/gitsh/blob/master/arch/PKGBUILD

* On other operating systems:

        curl -o http://thoughtbot.github.io/gitsh/gitsh-0.2.tar.gz
        tar -zxf gitsh-0.2.tar.gz
        cd gitsh-0.2
        ./configure
        make
        make install

## Releasing a new version

1. If you haven't used the project's Makefile before you'll need to do a little
bit of setup first:

        ./autogen.sh
        ./configure

2. Update the version number in `configure.ac`.

3. Build and publish the release:

        make release_build
        make release_push
        make release_clean

    Alternatively, you can use a single command that will run them for you. If
    anything goes wrong, this will be harder to debug:

        make release

## License

gitsh is Copyright © 2013 Mike Burns, George Brocklehurst, and thoughtbot. It is
free software, and may be redistributed under the terms specified in the
[LICENSE](https://github.com/thoughtbot/gitsh/blob/master/LICENSE) file.
