(** Representation of a player in the game Battleship

    This module contains all the methods needed for a player to either
    attack/place a ship in Battleship. *)

(** Player in the game *)
type player

(** Creates a player for the game *)
val create_player : Battleship.board -> Battleship.ship list -> player

(** Returns the board of a player *)
val get_board : player -> Battleship.board

(** Returns the ships of a player *)
val get_ships : player -> Battleship.ship list
