(** GUI system for game Battleship
    
    This module defines all the methods needed to render Battleship *)

val new_window : unit -> unit

val close_window : unit -> unit

val draw_ship : Battleship.ship_type -> unit

val draw_board : unit -> unit