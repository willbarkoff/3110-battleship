type t

type action =
  | Place of Battleship.ship_type * Battleship.block_tile
  | Attack of Battleship.block_tile
  | Quit

(** Raised when an empty command is parsed. *)
exception Empty

(** Raised when a malformed command is encountered. *)
exception Malformed

val parse_input : string -> action
