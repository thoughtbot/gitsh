# gitsh

The `gitsh` program is an interactive shell for git. From within `gitsh` you can
issue any git command, even using your local aliases and configuration.

## Why should you use gitsh?

* Avoid typing `git` over and over and over:

        sh$ gitsh
        gitsh% status
        gitsh% add .
        gitsh% commit -m "Ship it!"

* Hit <kbd>return</kbd> with no command to run `git status`, saving even more
  typing.
* Make temporary modifications to your git configuration with gitsh config
  variables. These changes only last as long as the gitsh session.

        gitsh% :set user.name 'George Brocklehurst and Mike Burns'
        gitsh% :set user.email support+george+mike@thoughtbot.com
        gitsh% commit -m 'We are pairing'

* Tab completion for git commands, aliases, and branches without modifying your
  shell settings, and without any extra setup for aliases and third party
  git commands.
* Information about the state of your git repository in the prompt, without
  modifying your shell settings.

## Installing gitsh

* On Mac OS X, via homebrew:

        brew tap thoughtbot/gitsh
        brew install gitsh

* On Arch Linux: https://github.com/thoughtbot/gitsh/blob/master/arch/PKGBUILD

* On other operating systems:

        curl -O http://thoughtbot.github.io/gitsh/gitsh-0.2.tar.gz
        tar -zxf gitsh-0.2.tar.gz
        cd gitsh-0.2
        ./configure
        make
        make install

## Releasing a new version

1. Update the version number in `configure.ac`.

2. Update the `configure` script, `Makefile`, and other dependencies:

        ./autogen.sh
        ./configure

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
