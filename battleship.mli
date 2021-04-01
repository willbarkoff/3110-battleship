(** Representation of the game, Battleship

    This module defines the rules of the game Battleship and creates the
    boards and ships for each Player. *)

(* Variant for type of ship *)
type ship_type =
  | Carrier
  | Battleship
  | Cruiser
  | Submarine
  | Destroyer

(** A position in Battleship. *)
type position

(** Determines whether block has been occupied or not *)
type block_occupation

(** The type of attack *)
type attack_type =
  | Hit
  | Miss
  | Untargeted

(** Direction that the ship is oriented *)
type direction =
  | Left
  | Right
  | Up
  | Down

(** Defines one specific block tile *)
type block_tile

(** Raised when ship collides with another ship *)
exception ShipCollision

(** Raised when there is an unknown ship *)
exception UnknownShip

(** The abstract type of board. *)
type board

(** The type of ship. *)
type ship

(** The list of ships in the game. *)
type ships

(** Creates an empty board. *)
val board : unit -> board

(** Returns a ship in Battleship. Raises [UnknownShip] if the string is
    not one of the ships. *)
val create_ship : string -> ship

(** Creates a Battleship.position from an input *)
val create_position : char * int -> position

(** Places the ship onto the board. Raises [ShipCollision] if the ship
    placed collides with another ship *)
val place_ship : ship -> position -> board -> direction -> unit

(** Performs an attack on the opponent. *)
val attack : ships -> position -> ship -> board -> unit

(** Checks if the game is finished. *)
val finished_game : ships -> bool

(** Prints the opponent's board (the shots that have been hit or missed) *)
val print_opponent_board : board -> unit

(** Prints the player board and all its ships *)
val print_player_board : board -> unit
