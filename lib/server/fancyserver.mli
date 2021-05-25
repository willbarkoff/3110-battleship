(** [Fancyserver] provides a TCP server. It is a reimplementation of
    [Unix.establish_server]; however, it uses threads rather than forks
    to allow for communication between different serving processes using
    [Event.channel]s.

    I beleive that this isn't a violation of the rule prohibiting the
    reimplementation of standard library functions, because I made
    changes to the function to allow it to work more efficiently in our
    case.

    Much of the code here was highly inspired by the Unix module in
    OCaml's standard library. In fact, most of the code here was pretty
    much based on it, with a few modifications to allow the sharing of
    memory of processes at runtime. *)

type server_func = in_channel -> out_channel -> unit

val establish_server : server_func -> Unix.sockaddr -> unit
