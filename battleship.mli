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
type position = char * int

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
type block_tile = {
  position : position;
  occupied : block_occupation;
  attack : attack_type;
}

(** The abstract type of board. *)
type board = block_tile array array

(** The type of ship. *)
type ship = {
  ship : ship_type;
  positions : block_tile list;
}

(** The list of ships in the game. *)
type ships = ship list

(** Creates an empty board. *)
val empty_board : int -> int -> board

(** Checks if the board position is valid and if ship can be fit inside
    the board. *)
val valid_pos : position -> ship -> board -> bool

(** Places the ship onto the board. *)
val place_ship : ship -> position -> board -> direction -> board

(** Performs an attack on the opponent. *)
val attack : ships -> position -> board -> board

(** Checks if the game is finished. *)
val finished_game : ships -> bool
