(** The Client module provides a client for playing a game over the
    network. It differs from the Server module in that it does not
    handle any of the game logic or scoring, it simply provides a means
    to interact with the server.*)

(** [message] represents a message sent over the network. *)
type message

(** [play_internet_game addr] plays a game over the network with the
    server hosted at [addr].*)
val play_internet_game : Unix.sockaddr -> unit
