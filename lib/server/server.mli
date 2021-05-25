(** Server provides game logic and communication protocols so that
    mutliple players can play together on different computers *)

(** A [message] represents a single message sent between the client and
    the server.

    @see {! Client.message}*)
type message

(** [listen_and_serve port] starts a multithreaded server on [port]. It
    never returns.*)
val listen_and_serve : int -> unit
