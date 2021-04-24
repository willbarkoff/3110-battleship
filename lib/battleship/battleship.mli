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
type block_occupation =
  | Occupied of ship_type
  | Unoccupied

(** The type of attack *)
type attack_type =
  | Hit
  | Miss
  | Untargeted

(** Defines one specific block tile *)
type block_tile = {
  position : position;
  mutable occupied : block_occupation;
  mutable attack : attack_type;
}

(** Direction that the ship is oriented *)
type direction =
  | Left
  | Right
  | Up
  | Down

(** Block display specifies how a block should be displayed *)
type block_display =
  | DisplayHit
  | DisplayMiss
  | DisplayShip of ship_type
  | DisplaySea

(** Raised when ship collides with another ship *)
exception ShipCollision

(** Raised when there is an unknown ship *)
exception UnknownShip

(** Raised when the given position is invalid *)
exception InvalidPosition

(** The abstract type of board. *)
type board = block_tile array array

(** The type of ship. *)
type ship

(** The list of ships in the game. *)
val ships : ship list

(** Creates an empty board. *)
val board : unit -> board

(** Returns a ship in Battleship. Raises [UnknownShip] if the string is
    not one of the ships. *)
val create_ship : string -> ship

(** Creates a Battleship.position from an input *)
val create_position : char * int -> position

(** Creates a Battleship.block_tile from an input *)
val create_block_tile :
  position -> attack_type -> block_occupation -> block_tile

(** [get_position p] gets the [char * int] pair from the position [p]*)
val get_position : position -> char * int

(** [get_tile_position t] retrieves the position from the block_tile *)
val get_tile_position : block_tile -> position

(** [get_tile_attack t] retrieves the attack type from block_tile *)
val get_tile_attack : block_tile -> attack_type

(** [get_tile_occupation t] retrieves the block occupation from
    block_tile *)
val get_tile_occupation : block_tile -> block_occupation

(** Places the ship onto the board. Raises [ShipCollision] if the ship
    placed collides with another ship *)
val place_ship : ship -> position -> board -> direction -> unit

(** Performs an attack on the opponent. *)
val attack : position -> board -> unit

(** Checks if the game is finished. *)
val finished_game : board -> bool

(** [get_opponent_board b] gets the display of the opponent's board, [b]*)
val get_opponent_board : board -> block_display array array

(** [get_player_board b] gets the display of the player's board, [b]*)
val get_player_board : board -> block_display array array

(** [print_tile settings t] prints a tile [t] with the additional
    settings [settings.]*)
val print_tile : ANSITerminal.style list -> block_display -> unit

(** [print_board b] prints the board [b] *)
val print_board : block_display array array -> unit

(** [get_ship_name s] gets the name of ship [s] *)
val get_ship_name : ship -> string

(** [get_ship_size s] gets the size of ship [s] *)
val get_ship_size : ship -> int
