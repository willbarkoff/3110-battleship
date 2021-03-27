type t

type position = char * int

type action =
  | Place of string * position
  | Attack of position
  | Quit

(** Raised when an empty command is parsed. *)
exception Empty

(** Raised when a malformed command is encountered. *)
exception Malformed

val parse_input : string -> action
