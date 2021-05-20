(** GUI system for game Battleship

    This module defines all the methods needed to render Battleship *)

(** TODO: PRETTY MUCH ALL OF UI.ml and selectlocation.ml: Place ships,
    toggle player, read_pos, update after attack, put board text at top,
    win/lose end result, print_error_message Second priority: main menu *)

type gui_pos

type gui_board

exception OutofBounds

(** [new_window ()] *)
val new_window : unit -> unit

val close_window : unit -> unit

(** [draw_ship s] updates the board after placing a ship *)
val draw_ship : unit -> unit

(** [draw_board ()] draws the empty board onto the GUI *)
val draw_board : unit -> unit

(** [write_player_text p] displays the text (either player or opponent) *)
val write_player_text : int -> unit

(** [update_board s] updates the drawn board after an attack turn *)
val update_board : unit -> unit
