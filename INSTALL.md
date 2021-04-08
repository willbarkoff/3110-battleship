# Installation

Right now, the required packages include these packages distributed with cs3110-2021sp switch
- make
- ANSITerminal
- ounit2

In addition, the [`core`](https://opensource.janestreet.com/core/) and [`async`](https://opensource.janestreet.com/async/) packages are also used for networking. In addition, the `async` package also requires the `ppx_let` language extension. Each of these can be installed with:

```shell
$ opam install core async ppx_let
```

To build and run the game, run `make`.

To open an interactive REPL with the modules loaded, run `make utop`. 