# Tab Completion in gitsh

This document describes how gitsh generates possible completions when the user
presses the tab key. The UI itself is handled by GNU Readline, so we're only
concerned with producing a relevant set of completions based on what the user
has typed so far.

## Overview

The basis of gitsh's tab completion system is a slightly extended
Non-deterministic Finite Automaton (NFA).

Completing variable names doesn't use the NFA, but all other types of completion
do.

### Finite Automata

In a typical NFA, the automaton consists of a set of states joined by
transitions. The automaton is initialised in a particular state. As input is fed
to the automaton it moves from the current state(s) into new state(s) by
following transitions that match the input.

An NFA is often used to implement regular expressions. For example, here's how
the regular expression `ab+` could be implemented:

    ---> (0) --- a ---> (1) --- b --> ((2)) ------,
                                        ^         |
                                        '--- b ---'

The automaton starts in state `0`. If it's given an `a` it moves to state `1`.
From state `1`, if it's given a `b` it'll move to state `2`. State `2` is an end
state, so we can say it matches the input.

If the automaton sees input it's not expecting, for example if it's in state `0`
and it is given a `b`, or it's in state `2` and it sees an `a`, it doesn't match
the input.

So far, this is deterministic. The non-determinism arrives when we add _free
moves_--transitions that can be made without consuming any input. For example,
this automaton matches `ab?a`:

                         ,----- b ------,
                         |              |
    ---> (0) --- a ---> (1)            (2) --- a ---> ((3))
                         |              ^
                         '--------------'

This automaton has two ways of getting from state `1` to state `2`: it can be
given a `b`, or it can make a free move.

Here, we start in state `0`, then if we're given an `a` we move to state `1` and
state `2` simultaneously. Now that the automaton's in two states, we have to
consider the transitions from both of those states when we see the next input.

### gitsh's implementation

The implementation in gitsh is slightly different from the NFAs used by regular
expressions. We're not interested in just matching things, we're interested in
what should come next after the input we've seen so far. That means our
implementation has two differences:

1. There are no end states. We just run the automaton until we run out of input,
   and then use the current states the automaton is in to understand what might
   come next.

2. The transitions have two roles: they both _match_ input, and _generate_
   completions. The matching behaviour is usually more permissive than the
   generating behaviour, e.g. if we're expecting a file system path we'd match
   on any input, but only generate valid paths to files that really exist.

Before we run it through the NFA, the user's input gets split into a series of
tokens. We're interested in matching everything before the word we're trying to
complete, and then using the final part of the input to filter down the possible
matches: if the user had typed `"add --patch my/f"`, we'd want to pass the
tokens `["add", "--patch"]` through the automaton, and then use `"my/f"` to
filter the possible completions.

Here's an example of a simple NFA that gitsh could use for completions:

    ---> (0) --- stash ---> (1) --- pop -----> (2)
          |                  |
          |                  '----- apply ---> (3)
          |
          '----- add -----> (4) --- $path ---> (5)

The automaton starts in state `0`. If the user has entered nothing, i.e. they're
just pressing <kbd>tab</kbd> at the beginning of an empty line, there's no input
to process, so the automaton stays in state `0`.

We look at the transitions from state `0`, and see that we were expecting the
word `stash` or the word `add`, so we offer those to the user as possible
completions.

If the user has entered the word `ad` and then hit <kbd>tab</kbd>, we just have
the word the user's trying to complete, so there's still nothing to run through
the automaton. It stays in state `0`, but this time we have some input to
compare `stash` and `add` to. `add` is the only completion that matches `ad`, so
we only return that one.

Finally, the user might have entered the word `add` followed by a space, and
then hit <kbd>tab</kbd>. In this case, we'd pass `add` to the automaton and move
from state `0` to state `4`. From state `4` the next thing we expect is a path,
so we'd offer file paths from the current directory as completions.

## Major components

- `Gitsh::TabCompletion::Facade` provides a single interface to the rest of
  gitsh. It's the only class inside the `TabCompletion` module that should be
  referenced elsewhere. Its `#call` method is the entry point for generating
  completions. It also decides if the `CommandCompleter` or `VariableCompleter`
  should be invoked.

- `Gitsh::TabCompletion::Context` uses the `Gitsh::Lexer` to break up the user's
  input into a series of words, so we know what to pass to the automaton, or if
  the input ends with a variable name.

- `Gitsh::TabCompletion::Automaton` implements the Non-deterministic Finite
  Automaton (NFA).

- The various classes under `Gitsh::TabCompletion::Matchers` implement the
  matching and generating behaviour for transitions in the automaton.

- `Gitsh::TabCompletion::AutomatonFactory` builds the automaton's various
  states and transitions.

- `Gitsh::TabCompletion::Escaper` handles unescaping input to the completer,
  and re-escaping the possible completions.

- `Gitsh::TabCompletion::CommandCompleter` orchestrates the interaction of the
  various other parts.

- `Gitsh::TabCompletion::VariableCompleter` provides an alternative to
  `CommandCompleter`. This doesn't use the automaton, and only completes
  variable names.
