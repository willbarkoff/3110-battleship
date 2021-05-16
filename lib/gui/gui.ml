open Graphics
open Battleship

let set_background_color color =
  let fg = foreground in
  set_color color;
  fill_rect 0 0 (size_x ()) (size_y ());
  set_color fg

let scale = 70

let tile_length = 700

let draw_board () =
  let rows = List.init 10 (fun value -> value + 1) in
  let rows_scaled = List.map (fun r -> r * scale) rows in
  let draw_horizontal y =
    moveto 0 y;
    rlineto 700 0
  in
  let draw_vertical x =
    moveto x 0;
    rlineto 0 700
  in
  let _ = List.map draw_horizontal rows_scaled in
  let _ = List.map draw_vertical rows_scaled in
  ()

let new_window () =
  set_window_title "Battleship";
  open_graph " 1000x800";
  set_background_color cyan;
  draw_board ()

let draw_ship (ship : ship_type) = ()

let close_window () = close_graph ()
