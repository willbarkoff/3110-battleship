open Graphics
open Battleship
open State

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

let draw_gameboard () =
  moveto 448 440;
  Graphics.set_font
    "-*-fixed-medium-r-semicondensed--20-*-*-*-*-*-iso8859-1";
  draw_string "3110 Battleship";
  moveto 445 400;
  Graphics.set_font
    "-*-fixed-medium-r-semicondensed--11-*-*-*-*-*-iso8859-1";
  draw_string "Enter commands in terminal";
  Graphics.set_font
    "-*-fixed-medium-r-semicondensed--12-*-*-*-*-*-iso8859-1";
  moveto 450 360;
  draw_string "Created by:";
  moveto 450 340;
  draw_string "Travis Zhang";
  moveto 450 330;
  draw_string "Brian Ling";
  moveto 450 320;
  draw_string "Tanay Menezes";
  moveto 450 310;
  draw_string "Will Barkoff"

let get_board_tile s =
  let c = 75 - (s.mouse_y / tile_length) in
  let idx = s.mouse_x / tile_length in
  if c < 65 || c > 74 || idx < 1 || idx > 10 then raise OutofBounds
  else (Char.chr c, idx)

let gui_pos_of_battleship_pos (p : Battleship.position) =
  let letter, idx = Battleship.get_position p in
  let char_int = Char.code letter in
  let char_convert = (75 - char_int) * tile_length in
  let idx_convert = idx * tile_length in
  [
    (idx_convert, char_convert);
    (idx_convert + tile_length, char_convert);
    (idx_convert, char_convert + tile_length);
    (idx_convert + tile_length, char_convert + tile_length);
  ]

let mouse_click () =
  let stat = wait_next_event [ Button_up ] in
  get_board_tile stat

let write_middle_tile (pos : Battleship.position) str =
  let bot_left_pos = List.nth (gui_pos_of_battleship_pos pos) 0 in
  moveto
    (fst bot_left_pos + (tile_length / 2))
    (snd bot_left_pos + (tile_length / 2));
  draw_string str

let draw_current_board (b : Battleship.board) =
  draw_board ();
  Array.iter
    (fun arr ->
      Array.iter
        (fun a ->
          (match a.occupied with
          | Occupied s -> write_middle_tile a.position "S"
          | Unoccupied -> ());
          match a.attack with
          | Hit -> write_middle_tile a.position "H"
          | Miss -> write_middle_tile a.position "M"
          | Untargeted -> ())
        arr)
    b

let rec read_pos (b : Battleship.board) (ship : Battleship.ship) =
  try
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    draw_string
      ("Choose a tile to place the " ^ Battleship.get_ship_name ship);
    Battleship.create_position (mouse_click ())
  with _ ->
    moveto (size_x () / 2) (size_y () - 60);
    clear_graph ();
    set_color red;
    draw_string "Invalid Position. Try again...";
    set_color black;
    clear_graph ();
    draw_current_board b;
    read_pos b ship

let rec place (state : State.t) (ship : Battleship.ship) =
  let b = state |> State.get_current_player |> Person.get_board in
  clear_graph ();
  set_background_color cyan;
  draw_current_board b;
  let b = read_pos b ship in
  print_endline
    (String.make 1 (fst (Battleship.get_position b))
    ^ " "
    ^ string_of_int (snd (Battleship.get_position b)));
  ()

let rec finish_board (state : State.t) =
  clear_graph ();
  moveto 448 440;
  Graphics.set_font
    "-*-fixed-medium-r-semicondensed--20-*-*-*-*-*-iso8859-1";
  draw_string "GAME OVER!";
  state |> State.get_current_player |> Person.get_board
  |> Battleship.get_player_board |> Battleship.print_board;
  ()

let new_window () =
  set_window_title "Battleship";
  open_graph " 800x800";
  set_background_color white

let draw_ship () = ()

let update_board () = ()

let write_player_text i = ()

let close_window () = close_graph ()
