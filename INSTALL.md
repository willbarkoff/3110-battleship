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

Next, install `sdl2` for your operating system.

- On macOS:
  - Homebrew:
    - `brew install pkgconfig`
    - `brew install sdl2`
    - `brew install sdl2_image`
    - `brew install sdl2_ttf`
  - MacPorts:
    - `port install pkgconfig`
    - `port install libsdl2`
- On Ubuntu (or WSL with Ubuntu):
  - `sudo apt install libsdl2`
  - You may need to also install `pkgconfig` with `sudo apt install pkgconfig`; though none of us have Ubuntu machines to test this unfortunately.

If you're using another operating system, you can likely find instructions for installing `sdl2` online.

Next, install the required dependencies using `opam`:

```
$ opam install ANSITerminal ounit2 dune core async ppx_let ocamlsdl2 graphics
```

When installing `graphics`, you may encounter the following error:

```
# In file included from src/unix/subwindow.c:16:
# src/unix/libgraph.h:17:10: fatal error: 'X11/Xlib.h' file not found
# #include <X11/Xlib.h>
#          ^~~~~~~~~~~~
# 1 error generated.
#           cc src/text.o (exit 1)
# (cd _build/default/src && /usr/bin/cc -O2 -fno-strict-aliasing -fwrapv -D_FILE_OFFSET_BITS=64 -D_REENTRANT -g -I /Users/traviszhang/.opam/cs3110-2021sp/lib/ocaml -o text.o -c text.c)
# In file included from src/unix/text.c:16:
# src/unix/libgraph.h:17:10: fatal error: 'X11/Xlib.h' file not found
# #include <X11/Xlib.h>
#          ^~~~~~~~~~~~
# 1 error generated.
```

The following thread (https://github.com/ocaml/graphics/pull/36#issuecomment-846827032) contains the solution to solving this problem. The basic rundown is that when installing x11, it is installed in a different directory, and the recent graphics version doesn't look in that directory.

You will also need a window server that supports the X Window System.

- On macOS:
  - Install XQuartz: https://www.xquartz.org/
- On Windows:
  - Install XMing: https://sourceforge.net/projects/xming/
- On Linux:
  - Install any window server that supports the X Window System. Our favorites are [Gnome](https://www.gnome.org/) (preinstalled on Ubuntu Desktop) and [KDE](https://kde.org/) (preinstalled on Kubuntu). In addition, on lightweight systems (like a Raspberry Pi), [LXDE](https://www.lxde.org/) (preinstalled on Raspberry Pi OS, and Raspbian) works well too.

Finally, to run the program, run `make`. This will launch a local game, so that several users can play on the same computer.

To start a server, run `make serve`. This will launch a battleship server, to host games for many people to play together on different computers.

---

To generate documentation for the packages provided by this software, run `make docs`. This will generate HTML documentation in `./_build/default/_doc/_html`. To start a documentation server, simply run `make docs-serve`. This will serve documentation on your local machine's port 5000. You can then navigate to [127.0.0.1:5000](http://127.0.0.1:5000) in a web browser to view the documentation.

To launch an interactive REPL (Read, Evaluate, Print, Loop) with the packages provided loaded, run `make utop`.
