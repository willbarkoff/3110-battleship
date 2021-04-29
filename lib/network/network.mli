(** Network holds networking related features for the battleship game. *)

(** {1 Message} *)

(** [message] represents the type of message sent to or from the server.*)
type message

(** {1 Listener} *)

(** [listen_and_serve p l] is a function that listens on port [p] and
    handles messages with the [listener] [l].*)
val listen_and_serve : int -> unit

(** [network_debug p] provides a REPL for testing the network
    interfaces. It tests them on port [p]. *)
val network_debug : int -> unit
