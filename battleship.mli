(** Representation of the game, Battleship

    This module defines the rules of the game Battleship. The module
    also creates the boards and ships for each Player. *)

(** The abstract type of board. *)
type board

(** The type of ship. *)
type ship

(** The type of attack *)
type hit_or_miss

(** Raised when an unknown ship is called. *)
exception UnknownShip of ship
