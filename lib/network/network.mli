(** Network holds networking related features for the battleship game. *)

(** [message] represents the type of message sent to or from the server.*)
type message

(** [listen_and_serve p l] is a function that listens on port [p] and
    handles messages with the [listener] [l].*)
val listen_and_serve : int -> unit
