type player

val create_player : Battleship.board -> Battleship.ship list -> player

val get_board : player -> Battleship.board

val get_ships : player -> Battleship.ship list

type action =
  | Place of string * Battleship.position * Battleship.direction
  | Attack of Battleship.position
  | Quit

(** Raised when an empty input is encountered *)
exception Empty

(** Raised when a malformed input is detected. *)
exception Malformed

(** [parse_input input] turns the string [input] into an [action]
    corresponding to that input *)
val parse_input : string -> action
