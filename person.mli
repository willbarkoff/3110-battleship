type t

type position = char * int

type direction =
  | Left
  | Right
  | Up
  | Down

type action =
  | Place of string * position
  | Attack of position
  | Quit

(** Raised when an empty input is encountered *)
exception Empty

(** Raised when a malformed input is detected. *)
exception Malformed

(** [parse_input input] turns the string [input] into an [action]
    corresponding to that input *)
val parse_input : string -> action
