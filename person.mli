type player = {
  board : Battleship.board;
  ships : Battleship.ships;
}

type t = {
  player : player;
  opponent : player;
}

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
