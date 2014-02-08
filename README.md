# <img src="http://thoughtbot.github.io/gitsh/images/gitsh-logo.png" alt="gitsh" width="150" height="178">

The `gitsh` program is an interactive shell for git. From within `gitsh` you can
issue any git command, even using your local aliases and configuration.

## Why should you use gitsh?

* Git commands tend to come in groups. Avoid typing `git` over and over and over
  by running them in a dedicated git shell:

        sh$ gitsh
        gitsh% status
        gitsh% add .
        gitsh% commit -m "Ship it!"
        gitsh% push
        gitsh% :exit
        sh$

* Hit <kbd>return</kbd> with no command to run `git status`, saving even more
  typing:

        gitsh% ⏎
        # On branch master
        nothing to commit, working directory clean
        gitsh% 

* Make temporary modifications to your git configuration with gitsh config
  variables. These changes only effect git commands issues in this gitsh
  session and are forgotten when you exit, just like shell environment
  variables.

        gitsh% :set user.name 'George Brocklehurst and Mike Burns'
        gitsh% :set user.email support+george+mike@thoughtbot.com
        gitsh% commit -m 'We are pair programming'

* Tab completion for git commands, aliases, and branches without modifying your
  shell settings, and without any extra setup for aliases and third party
  git commands.

* Information about the state of your git repository in the prompt, without
  modifying your shell settings. This includes the name of the current HEAD, and
  a colour and sigil to indicate the status.

* It works with [`hub`][hub]:

        sh$ gitsh --git $(which hub)
        gitsh% pull-request

## Installing gitsh

* On Mac OS X, via homebrew:

        brew tap thoughtbot/formulae
        brew install gitsh

* On Arch Linux: https://github.com/thoughtbot/gitsh/blob/master/arch/PKGBUILD

* On other operating systems:

        curl -O http://thoughtbot.github.io/gitsh/gitsh-0.3.tar.gz
        tar -zxf gitsh-0.3.tar.gz
        cd gitsh-0.3
        ./configure
        make
        make install

## Contributing to gitsh

Pull requests are very welcome. See the [contributing guide][CONTRIBUTING] for
more details.

## License

gitsh is Copyright © 2014 Mike Burns, George Brocklehurst, and thoughtbot. It is
free software, and may be redistributed under the terms specified in the
[LICENSE][LICENSE] file.

[hub]: http://hub.github.com/
[CONTRIBUTING]: https://github.com/thoughtbot/gitsh/blob/master/CONTRIBUTING.md
[LICENSE]: https://github.com/thoughtbot/gitsh/blob/master/LICENSE
