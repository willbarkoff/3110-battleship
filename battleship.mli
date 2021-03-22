(* TODO: Modify description of module *)
(** Representation of the game, Battleship 

    This module represents the data stored in adventure files, including
    the rooms and exits. It handles loading of that data from JSON as
    well as querying the data. *)

(** The abstract type of board. *)
type board

(** The type of ship. *)
type ship

(** The type of attack *)
type hit_or_miss

(** Raised when an unknown ship is called. *)
exception UnknownShip of ship


