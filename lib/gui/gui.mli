(** GUI system for game Battleship

    This module defines all the methods needed to render Battleship *)

type gui_pos

type gui_board

val new_window : unit -> unit

val close_window : unit -> unit

val draw_ship : Battleship.ship_type -> unit

val draw_board : unit -> unit
