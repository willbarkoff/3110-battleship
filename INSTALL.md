# Installation

Right now, the required packages include these packages distributed with cs3110-2021sp switch
- make
- ANSITerminal
- ounit2

In addition, the `mirage-tcpip` package is required. It can be installed with
```shell
$ opam install tcpip
```

To build and run the game, run `make`.

To open an interactive REPL with the modules loaded, run `make utop`. 