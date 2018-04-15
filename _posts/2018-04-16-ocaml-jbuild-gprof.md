---
layout: post
title: Profiling OCaml with gprof and jbuilder
tags: [ocaml, profiling]
---

I am currently using OCaml for part of my research and ran into more trouble
than expected when trying to profile my program. This post details step by step
how to compile an OCaml program using [dune(jbuilder)][1] to profile the binary
using gprof.

As an example program to profile, I will use a short code implementing
the [tak function][2] of dear [prof. Takeuchi][3].

```ocaml
(* tak.ml *)
let rec tak x y z =
  if x <= y then y
  else
    tak (tak (x-1) y z)
        (tak (y-1) z x)
        (tak (z-1) x y)

let () = print_endline (string_of_int (tak 18 12 6))
```

First, we will compile with the `-p` option of `ocamlopt` to turn on profiling
and run the program.

```shell
ocamlopt -p tak.ml -o tak
./tak
```

This should hopefully output `18` and create a file called `gmon.out`.
The next step is, as usual with `gprof`, to generate the profile from `gmon.out`

```shell
gprof tak gmon.out > profile.txt
```

If the profile looks good, then you can skip the next step. If, as on my
computer, you get an empty profile, then you probably have a [buggy version of
gcc][4]. A workaround seems to be to disable position independent code with the
`-no-pie` option, although I am not sure exactly why. The compile command then
becomes

```shell
ocamlopt -p tak.ml -o tak -ccopt -no-pie
```

and by re-running the program and `gprof`, `profile.txt` should now actually
contain the program profile.

The last step is to get this working with `jbuilder` by telling it to pass
the above options to `ocamlopt`. This can be done with the `ocamlopt_flags`,
and the `jbuild` file can therefore be defined as follow.

```scheme
(jbuild_version 1)

(executable (
  (name tak)
  (ocamlopt_flags (:standard -p -ccopt -no-pie))
))
```

Note that you can remove the `-ccopt -no-pie` part if you did not need it when
compiling with `ocamlopt` directly. We can now compile our program with
`jbuilder`.

```shell
rm tak tak.cm* tak.o gmon.out profile.txt # cleanup first
jbuilder build tak.exe
```

and we should be able to generate a profile.

```shell
./_build/default/tak.exe
gprof _build/default/tak.exe gmon.out > profile.txt
```

Although I did not try it, it seems that it should be possible to
[change the flags used by `jbuilder`][5] using command line arguments, so it
could also be worth trying in combination with the steps described above.

[1]: https://github.com/ocaml/dune
[2]: http://mathworld.wolfram.com/TAKFunction.html
[3]: https://www.linkedin.com/in/ikuo-takeuchi-4b145694/
[4]: https://bugs.launchpad.net/ubuntu/+source/gcc-6/+bug/1678510
[5]: https://github.com/ocaml/dune/issues/398
