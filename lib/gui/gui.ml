open Graphics
open Battleship

type gui_pos = int * int

exception OutofBounds

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

(* let cols = Array.init no_of_rows (fun value -> value + 1) in let row
   y = let y = y + 1 in Array.map (fun x -> [ (x * tile_length, y *
   tile_length); ((x + 1) * tile_length, y * tile_length); (x *
   tile_length, (y + 1) * tile_length); ((x + 1) * tile_length, (y + 1)
   * tile_length); ]) cols in Array.init no_of_cols row *)

let make_board () =
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
  let b = make_board () in
  let draw_line (i_x, i_y) (f_x, f_y) =
    moveto i_x i_y;
    rlineto (f_x - i_x) (f_y - i_y)
  in
  (* Fix text size *)
  let write_char (x, y) =
    moveto (x - (tile_length / 2) + 10) (y + (tile_length / 2));
    draw_char (Char.chr (75 - (y / tile_length)))
  in
  let write_numbers (x, y) =
    moveto (x + (tile_length / 2) - 10) (y + (tile_length / 2) - 20);
    draw_string (string_of_int (x / tile_length))
  in
  Array.iter
    (fun arr ->
      write_char arr.(0).bot_left_corner;
      Array.iter
        (fun r ->
          draw_line r.bot_left_corner r.bot_right_corner;
          draw_line r.top_left_corner r.top_right_corner;
          draw_line r.bot_left_corner r.top_left_corner;
          draw_line r.bot_right_corner r.top_right_corner)
        arr)
    b;
  Array.iter (fun r -> write_numbers r.top_left_corner) b.(9)

let get_board_tile s =
  let c = 75 - (s.mouse_y / tile_length) in
  let idx = s.mouse_x / tile_length in
  if c < 65 || c > 74 || idx < 1 || idx > 10 then raise OutofBounds
  else (Char.chr c, idx)

let mouse_click () =
  let stat = wait_next_event [ Button_up ] in
  let x, y = get_board_tile stat in
  draw_string (String.make 1 x ^ " " ^ string_of_int y);
  moveto (fst (current_point ()) - 10) (snd (current_point ()) - 10)

let new_window () =
  set_window_title "Battleship";
  open_graph " 800x800";
  set_background_color cyan;
  draw_board ();
  moveto (fst (current_point ()) + 20) (snd (current_point ()));
  while true do
    mouse_click ()
  done

let draw_ship (ship : ship_type) = ()

let close_window () = close_graph ()
