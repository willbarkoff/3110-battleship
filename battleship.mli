(** Representation of the game, Battleship

    This module defines the rules of the game Battleship. The module
    also creates the boards and ships for each Player. *)

(* TODO: Fix/Revise all the comments *)

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
type block_occupation =
  | Occupied of ship_type
  | Unoccupied

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

(** The abstract type of board. *)
type board

(** The type of ship. *)
type ship

(** The list of ships in the game. *)
type ships

(** Creates an empty board. *)
val board : unit -> board

(** Places the ship onto the board. Raises [ShipCollision] if the ship
    placed collides with another ship *)
val place_ship : ship -> position -> board -> direction -> unit

(** Performs an attack on the opponent. *)
val attack : ships -> position -> ship -> board -> unit

(** Checks if the game is finished. *)
val finished_game : ships -> bool

(** [print_board b] prints the board b *)
val print_board : board -> unit
