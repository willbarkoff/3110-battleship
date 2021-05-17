open Graphics
open Battleship

type gui_pos = int * int

type gui_tile = {
  bot_left_corner : gui_pos;
  bot_right_corner : gui_pos;
  top_left_corner : gui_pos;
  top_right_corner : gui_pos;
}

type gui_board = {
  tiles : gui_tile array array;
  board : Battleship.board;
}

let tile_length = 60

let print_gui_pos (pos : gui_pos) =
  print_endline (string_of_int (fst pos) ^ " " ^ string_of_int (snd pos))

let set_background_color color =
  let fg = foreground in
  set_color color;
  fill_rect 0 0 (size_x ()) (size_y ());
  set_color fg

let make_gui_board () =
  let cols = Array.init no_of_rows (fun value -> value + 1) in
  let row y =
    let y = y + 1 in
    Array.map
      (fun x ->
        {
          bot_left_corner = (x * tile_length, y * tile_length);
          bot_right_corner = ((x + 1) * tile_length, y * tile_length);
          top_left_corner = (x * tile_length, (y + 1) * tile_length);
          top_right_corner =
            ((x + 1) * tile_length, (y + 1) * tile_length);
        })
      cols
  in
  Array.init no_of_cols row

let draw_board () =
  let b = make_gui_board () in
  let draw_line (i_x, i_y) (f_x, f_y) =
    moveto i_x i_y;
    rlineto (f_x - i_x) (f_y - i_y)
  in
  Array.iter
    (fun arr ->
      Array.iter
        (fun r ->
          draw_line r.bot_left_corner r.bot_right_corner;
          draw_line r.top_left_corner r.top_right_corner;
          draw_line r.bot_left_corner r.top_left_corner;
          draw_line r.bot_right_corner r.top_right_corner)
        arr)
    b

let new_window () =
  set_window_title "Battleship";
  open_graph " 800x800";
  set_background_color cyan;
  draw_board ()

let draw_ship (ship : ship_type) = ()

let close_window () = close_graph ()
