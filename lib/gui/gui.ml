open Graphics

type gui_pos = int * int

exception OutofBounds

exception InvalidOrientation

type gui_tile = {
  bot_left_corner : gui_pos;
  bot_right_corner : gui_pos;
  top_left_corner : gui_pos;
  top_right_corner : gui_pos;
}

type gui_board = gui_tile array array

let background = rgb 18 52 86

let foreground = white

let foreground_text = red

let hit_color = red

let error_color = rgb 204 0 0

let miss_color = cyan

let tile_length = 60

let player_turn = ref 1

let set_background_color color =
  let fg = foreground in
  set_color color;
  fill_rect 0 0 (size_x ()) (size_y ());
  set_color fg

let make_board () =
  let open Battleship in
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
  set_background_color background;
  let b = make_board () in
  let draw_line (i_x, i_y) (f_x, f_y) =
    moveto i_x i_y;
    rlineto (f_x - i_x) (f_y - i_y)
  in
  let write_char (x, y) =
    moveto (x - (tile_length / 2) + 10) (y + (tile_length / 2));
    draw_char (Char.chr (75 - (y / tile_length)))
  in
  let write_numbers (x, y) =
    moveto (x + (tile_length / 2) - 10) (y + (tile_length / 2) - 20);
    draw_string (string_of_int (x / tile_length))
  in
  Graphics.set_font
    "-*-fixed-medium-r-semicondensed--17-*-*-*-*-*-iso8859-1";
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

let keyboard_read () =
  let stat = wait_next_event [ Key_pressed ] in
  stat.key

let rec keyboard_read_enter () =
  let key_char = keyboard_read () in
  if Char.code key_char <> 13 then keyboard_read_enter () else ()

let write_middle_tile (pos : Battleship.position) str =
  let bot_left_pos = List.nth (gui_pos_of_battleship_pos pos) 0 in
  moveto
    (fst bot_left_pos + (tile_length / 2))
    (snd bot_left_pos + (tile_length / 2));
  draw_string str

let draw_current_board (b : Battleship.board) =
  let open Battleship in
  draw_board ();
  moveto ((size_x () / 2) - 150) (size_y () - 40);
  draw_string ("Player " ^ string_of_int !player_turn ^ "'s turn");
  Array.iter
    (fun arr ->
      Array.iter
        (fun a ->
          match a.attack with
          | Hit ->
              set_color hit_color;
              write_middle_tile a.position "H";
              set_color foreground
          | Miss ->
              set_color miss_color;
              write_middle_tile a.position "M";
              set_color foreground
          | Untargeted -> (
              match a.occupied with
              | Occupied _ ->
                  write_middle_tile a.position (Battleship.ship_print a)
              | Unoccupied -> ()))
        arr)
    b

let draw_opponent_board (b : Battleship.board) =
  let open Battleship in
  draw_board ();
  moveto ((size_x () / 2) - 150) (size_y () - 40);
  draw_string ("Player " ^ string_of_int !player_turn ^ "'s turn");
  Array.iter
    (fun arr ->
      Array.iter
        (fun a ->
          match a.attack with
          | Hit ->
              set_color hit_color;
              write_middle_tile a.position "H";
              set_color foreground_text
          | Miss ->
              set_color miss_color;
              write_middle_tile a.position "M";
              set_color foreground_text
          | Untargeted -> ())
        arr)
    b

let display_player_board_text s1 s2 b =
  draw_current_board b;
  moveto ((size_x () / 2) - 150) (size_y () - 60);
  set_color foreground_text;
  draw_string s1;
  moveto ((size_x () / 2) - 150) (size_y () - 80);
  draw_string s2;
  keyboard_read_enter ()

let rec read_pos (b : Battleship.board) (ship : Battleship.ship) =
  try
    clear_graph ();
    draw_current_board b;
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    draw_string
      ("Choose a tile to place the " ^ Battleship.get_ship_name ship);
    Battleship.create_position (mouse_click ())
  with _ ->
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    clear_graph ();
    set_color error_color;
    draw_string "Invalid Position. Try again...";
    set_color foreground;
    Unix.sleepf 1.0;
    clear_graph ();
    draw_current_board b;
    read_pos b ship

let rec read_pos_attack (b : Battleship.board) =
  try
    clear_graph ();
    draw_opponent_board b;
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    draw_string "Your opponent's board";
    moveto ((size_x () / 2) - 150) (size_y () - 80);
    draw_string "Click where you want to place your next shot";
    Battleship.create_position (mouse_click ())
  with _ ->
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    clear_graph ();
    set_color error_color;
    draw_string "Invalid Position. Try again...";
    set_color foreground;
    Unix.sleepf 1.0;
    clear_graph ();
    draw_opponent_board b;
    read_pos_attack b

let rec read_orientation (b : Battleship.board) =
  try
    clear_graph ();
    draw_current_board b;
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    draw_string "Type an Orientation (L, U, D, R): ";
    let key_char = keyboard_read () in
    let orientation = key_char |> Char.uppercase_ascii in
    if orientation = 'L' then Battleship.Left
    else if orientation = 'R' then Battleship.Right
    else if orientation = 'U' then Battleship.Up
    else if orientation = 'D' then Battleship.Down
    else raise InvalidOrientation
  with _ ->
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    clear_graph ();
    set_color error_color;
    draw_string "Invalid Orientation. Try again...";
    set_color foreground;
    Unix.sleepf 1.0;
    clear_graph ();
    draw_current_board b;
    read_orientation b

let rec place (state : State.t) (ship : Battleship.ship) =
  let b = state |> State.get_current_player |> Person.get_board in
  clear_graph ();
  draw_current_board b;
  try
    let pos = read_pos b ship in
    let o = read_orientation b in
    let new_state = State.place_ship state pos ship o in
    let new_board =
      new_state |> State.get_current_player |> Person.get_board
    in
    clear_graph ();
    draw_current_board new_board;
    new_state
  with _ ->
    clear_graph ();
    set_color error_color;
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    draw_string "That's an invalid placement. Press enter to continue.";
    keyboard_read_enter ();
    place state ship

let toggle_player () =
  if !player_turn = 1 then player_turn := 2 else player_turn := 1;
  moveto ((size_x () / 2) - 150) (size_y () - 60);
  set_color foreground_text;
  draw_string "Pass the computer to the next player.";
  moveto ((size_x () / 2) - 150) (size_y () - 80);
  draw_string "Press enter when you're ready to continue.";
  keyboard_read_enter ()

let finish_board (state : State.t) =
  clear_graph ();
  moveto ((size_x () / 2) - 150) ((size_y () / 2) - 60);
  Graphics.set_font
    "-*-fixed-medium-r-semicondensed--20-*-*-*-*-*-iso8859-1";
  draw_string "GAME OVER!";
  let b = state |> State.get_current_player |> Person.get_board in
  draw_current_board b

let new_window () =
  set_window_title "Battleship";
  open_graph " 700x800";
  set_background_color background

let rec update_board state =
  let b = state |> State.get_opponent |> Person.get_board in
  clear_graph ();
  draw_opponent_board b;
  try
    let pos = read_pos_attack b in
    let new_state = State.attack state pos in
    let new_board =
      new_state |> State.get_opponent |> Person.get_board
    in
    clear_graph ();
    draw_opponent_board new_board;
    new_state
  with _ ->
    set_color error_color;
    moveto ((size_x () / 2) - 150) (size_y () - 60);
    draw_string "That's an invalid attack. Press enter to continue.";
    keyboard_read_enter ();
    update_board state
