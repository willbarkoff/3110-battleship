(** Network holds networking related features for the battleship game. *)

(** [message] represents the type of message sent to or from the server.*)
type message

(** [listen_and_serve p l] is a function that listens on port [p] and
    handles messages with the [listener] [l].*)
val listen_and_serve : int -> unit

(** [network_debug p] provides a REPL for testing the network
    interfaces. It tests them on port [p]. *)
val network_debug : int -> unit

(** [play_internet_game addr] plays a game over the network with the
    server hosted at [addr].*)
val play_internet_game : Unix.sockaddr -> unit
