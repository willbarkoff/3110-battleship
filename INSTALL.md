# Installation

First, make sure you have `make` installed. You can do this by running `make --version`:

```shell
$ make --version
GNU Make 3.81
Copyright (C) 2006  Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
```

Next, install the required dependencies using `opam`:

```
$ opam install ANSITerminal ounit2 dune core async ppx_let ocamlsdl2
```

Finally, to run the program, run `make`. This will launch a local game, so that several users can play on the same computer.

To start a server, run `make serve`. This will launch a battleship server, to host games for many people to play together on different computers.

To play using a server, run `make multiplayer`. This will allow you to connect to a server and play a game.

---

To generate documentation for the packages provided by this software, run `make docs`. This will generate HTML documentation in `./_build/default/_doc/_html`. To start a documentation server, simply run `make docs-serve`. This will serve documentation on your local machine's port 5000. You can then navigate to [127.0.0.1:5000](http://127.0.0.1:5000) in a web browser to view the documentation.

To launch an interactive REPL (Read, Evaluate, Print, Loop) with the packages provided loaded, run `make utop`.
