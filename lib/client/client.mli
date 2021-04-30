type message

(** [play_internet_game addr] plays a game over the network with the
    server hosted at [addr].*)
val play_internet_game : Unix.sockaddr -> unit
