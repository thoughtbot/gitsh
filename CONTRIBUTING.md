# Contributing to gitsh

## Contributing a feature

We love pull requests. Here's a quick guide:

1. Clone the repo:

        git clone https://github.com/thoughtbot/gitsh.git

2. Run the tests. We only take pull requests with passing tests, and it's great
   to know that you have a clean slate:

        cd gitsh
        bundle
        ./autogen.sh
        ./configure
        make
        rspec

3. Add a test for your change. Only refactoring and documentation changes
   require no new tests. If you are adding functionality or fixing a bug, we
   need a test!

4. Make the test pass.

5. Fork the repo, push to your fork, and submit a pull request.


At this point you're waiting on us. We like to at least comment on, if not
accept, pull requests within three business days. We may suggest some changes or
improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Include tests that fail without your code, and pass with it.
* Update the documentation, especially the man page, whatever is affected by
  your contribution.
* Follow the [thoughtbot style guide][style-guide].

And in case we didn't emphasize it enough: we love tests!

## Releasing a new version

gitsh is packaged and installed using GNU autotools.

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

[style-guide]: https://github.com/thoughtbot/guides/tree/master/style#ruby
