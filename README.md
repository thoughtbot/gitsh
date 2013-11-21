# gitsh

The `gitsh` program is an interactive shell for git. From within `gitsh` you can
issue any git command, even using your local aliases and configuration.

## Developers

If you want to install from the repository (perhaps to try out some
modifications) or build a new distribution, you will need to:

1. Clone the repository
2. Build the configuration files

        ./autogen.sh

3. Configure the project

        ./configure

    Configuration may fail if it can't find Ruby 2.0 or later. If you have
    multiple Ruby versions installed you can explicitly provide a path to the
    correct version in the `$RUBY` environment variable.

        RUBY=/example/bin/ruby ./configure

4. If you make changes to the `bin/gitsh.in` you can regenerate `bin/gitsh`
   using make.

        make

## License

gitsh is Copyright © 2013 Mike Burns, George Brocklehurst, and thoughtbot. It is
free software, and may be redistributed under the terms specified in the
[LICENSE](https://github.com/thoughtbot/gitsh/blob/master/LICENSE) file.
