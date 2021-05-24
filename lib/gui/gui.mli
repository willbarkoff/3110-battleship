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

val draw_current_board : Battleship.board -> unit

val draw_opponent_board : Battleship.board -> unit

val display_player_board_text :
  string -> string -> Battleship.board -> unit

(** [place state ship] places a ship onto the GUI board *)
val place : State.t -> Battleship.ship -> State.t

(** [write_player_text p] displays the text (either player or opponent) *)
val write_player_text : int -> unit

(** [update_board s] updates the drawn board after an attack turn *)
val update_board : State.t -> State.t

(* [draw_gameboard] draws the empty gameboards on the graphics window*)
val draw_gameboard : unit -> unit

val toggle_player : unit -> unit

(* [finish_board] display win or loss statistics *)
val finish_board : State.t -> unit
