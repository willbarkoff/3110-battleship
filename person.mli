(** Representation of a player in the game Battleship

    This module contains all the methods needed for a player to either
    attack/place a ship in Battleship. *)

(** Player in the game *)
type player

(** The types of actions possible in Battleship *)
type action =
  | Place of string * Battleship.position * Battleship.direction
  | Attack of Battleship.position
  | Quit

(** Raised when an empty input is encountered *)
exception Empty

(** Raised when a malformed input is detected. *)
exception Malformed

(** Creates a player for the game *)
val create_player : Battleship.board -> Battleship.ship list -> player

(** Returns the board of a player *)
val get_board : player -> Battleship.board

(** Returns the ships of a player *)
val get_ships : player -> Battleship.ship list

(** [parse_input input] turns the string [input] into an [action]
    corresponding to that input *)
val parse_input : string -> action
