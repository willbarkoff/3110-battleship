type ship_type =
  | Carrier
  | Battleship
  | Cruiser
  | Submarine
  | Destroyer

type block_occupation =
  | Occupied of ship_type
  | Unoccupied

type attack_type =
  | Hit
  | Miss
  | Untargeted

type direction =
  | Left
  | Right
  | Up
  | Down

type position = char * int

type block_tile = {
  position : position;
  mutable occupied : block_occupation;
  mutable attack : attack_type;
}

type board = block_tile array array

type ship = {
  ship_type : ship_type;
  mutable destroyed : bool;
  mutable positions : position list;
  size : int;
}

type ships = ship list

let carrier =
  { ship_type = Carrier; destroyed = false; positions = []; size = 5 }

let battleship =
  {
    ship_type = Battleship;
    destroyed = false;
    positions = [];
    size = 4;
  }

let cruiser =
  { ship_type = Cruiser; destroyed = false; positions = []; size = 3 }

let submarine =
  { ship_type = Submarine; destroyed = false; positions = []; size = 3 }

let destroyer =
  { ship_type = Destroyer; destroyed = false; positions = []; size = 2 }

let ships = [ carrier; battleship; cruiser; submarine; destroyer ]

let no_of_rows = 10

let no_of_cols = 10

let board () : board =
  let rows =
    Array.init no_of_rows (fun ascii -> Char.chr (ascii + 65))
  in
  let row idx =
    Array.map
      (fun letter ->
        {
          position = (letter, idx);
          occupied = Unoccupied;
          attack = Untargeted;
        })
      rows
  in
  Array.init no_of_cols row

(* [check_idx ] *)
let check_idx (idx : int) : bool = idx >= 0 && idx < no_of_cols

(* [check_char ] *)
let check_char (letter : char) : bool =
  let ascii = Char.code letter in
  ascii >= 65 && ascii < 65 + no_of_rows

let char_generation op (start : int) (start_idx : int) (offset : int) =
  (Char.chr (op start offset), start_idx)

let int_generation
    op
    (start_idx : int)
    (start_letter : char)
    (offset : int) =
  (start_letter, op start_idx offset)

(* [gen_positions] *)
let gen_positions (pos : position) (ship : ship) =
  let ship_size = ship.size in
  let start_letter, start_idx = pos in
  function
  | Up ->
      let start = Char.code start_letter in
      List.init ship_size (char_generation ( - ) start start_idx)
  | Down ->
      let start = Char.code start_letter in
      List.init ship_size (char_generation ( + ) start start_idx)
  | Left ->
      List.init ship_size (int_generation ( - ) start_idx start_letter)
  | Right ->
      List.init ship_size (int_generation ( + ) start_idx start_letter)

(* [valid_pos pos ship board] checks if the board position is valid and
   if ship can be fit inside the board. *)
let valid_pos (pos : position) (direction : direction) (ship : ship) =
  assert (check_char (fst pos) && check_idx (snd pos));
  let end_pos = List.hd (List.rev (gen_positions pos ship direction)) in
  check_char (fst end_pos) && check_idx (snd end_pos)

(* [check_collision ] *)
let check_collision
    (arr : block_tile array)
    (ship : ship)
    (pos : position)
    (direction : direction) : bool =
  let positions = gen_positions pos ship direction in
  Array.for_all
    (fun tile ->
      if List.mem tile.position positions then
        tile.occupied = Unoccupied
      else true)
    arr

(* [modify_occupied] *)
let modify_occupied
    (arr : block_tile array)
    (ship : ship)
    (pos : position)
    (direction : direction) =
  let positions = gen_positions pos ship direction in
  ship.positions <- positions;
  Array.iter
    (fun tile ->
      if List.mem tile.position positions then
        tile.occupied <- Occupied ship.ship_type)
    arr

let place_ship
    (ship : ship)
    (start_pos : position)
    (board : board)
    (direction : direction) =
  assert (valid_pos start_pos direction ship);
  assert (List.length ship.positions = 0);
  for i = 0 to Array.length board - 1 do
    modify_occupied board.(i) ship start_pos direction
  done;
  ()

(* [check_shot ships shot_pos] checks whether the shot fired has hit a
   ship or not. *)
let check_shot (ships : ships) (shot_pos : position) : bool =
  assert (check_char (fst shot_pos) && check_idx (snd shot_pos));
  let ship_pos = List.map (fun x -> x.positions) ships in
  List.mem shot_pos (List.flatten ship_pos)

(* [attack ships shot_pos board] modify the board so that the block tile
   is either marked as hit or missed. *)
let attack (ships : ships) (shot_pos : position) (board : board) : board
    =
  failwith "Unimplemented"

let finished_game (ships : ships) : bool =
  List.for_all (fun ship -> ship.destroyed) ships

let print_board (b : board) =
  print_endline ("--" ^ String.make (Array.length b) '=' ^ "-");
  Array.iteri
    (fun i row ->
      print_string (String.make 1 (Char.chr (i + 65)));
      Array.iter
        (fun tile ->
          match tile.attack with
          | Hit -> print_string "H"
          | Miss -> print_string "M"
          | Untargeted -> print_string "•")
        row)
    b;
  print_string " |";
  for i = 1 to Array.length b do
    print_int i
  done;
  print_newline ()
