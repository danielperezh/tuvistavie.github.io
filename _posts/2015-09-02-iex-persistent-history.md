---
title:  "Persistent history in Elixir repl IEx"
date:   2015-09-02
tags: [Elixir]
---

Recently I am starting to use Elixir a bit more seriously, and a small issue I had was that Elixir repl, IEx, history does not persist between sessions.
Being used to repl like `ipython` or `pry` which do that out of the box, I wanted to have this functionality, which is in my opinion very convenient.

It seems that the problem is more directly related to Erlang than to Elixir itself, and therefore, the workarounds that are used to get persistent history for the Erlang repl can also be used for Elixir.

The [erlang-history](https://github.com/ferd/erlang-history) project worked perfectly for me

```sh
git clone https://github.com/ferd/erlang-history.git
cd erlang-history
make install
```

and I was able to get a history persistent across sessions. Note that `make install` needs sudo if you do not have write permissions in the Erlang install directory.
