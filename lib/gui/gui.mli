(** GUI system for game Battleship

    This module defines all the methods needed to render Battleship on a
    GUI system*)

(** Position to draw on the window*)
type gui_pos

(** Board that stores all the positions for each tile *)
type gui_board

(** Raised when a user clicks off the grid or in an invalid position *)
exception OutofBounds

(** [new_window ()] creates a window for the game *)
val new_window : unit -> unit

(** [draw_board ()] draws the empty board onto the GUI *)
val draw_board : unit -> unit

(** [draw_current_board b] draws b onto the GUI such that both ship
    locations and hits and misses are displayed *)
val draw_current_board : Battleship.board -> unit

(** [draw_opponent_board b] draws b onto the GUI such that only hits and
    misses are displayed *)
val draw_opponent_board : Battleship.board -> unit

(** [display_player_board_text s1 s2 b] writes s1 and s2 at the top of
    the window before drawing b onto the GUI such that both ship
    locations and hits and misses are displayed *)
val display_player_board_text :
  string -> string -> Battleship.board -> unit

(** [place state ship] places a ship onto the GUI board *)
val place : State.t -> Battleship.ship -> State.t

(** [update_board s] updates the drawn board after an attack turn *)
val update_board : State.t -> State.t

(* [draw_gameboard] draws the empty gameboards on the graphics window*)
val draw_gameboard : unit -> unit

(* [toggle_player] toggles whose turn it is in the game from one player
   to the other*)
val toggle_player : unit -> unit

(* [finish_board] display win or loss statistics *)
val finish_board : State.t -> unit
