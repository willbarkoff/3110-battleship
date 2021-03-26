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
  mutable positions : position list;
  size : int;
}

type ships = ship list

let carrier = { ship_type = Carrier; positions = []; size = 5 }

let battleship = { ship_type = Battleship; positions = []; size = 4 }

let cruiser = { ship_type = Cruiser; positions = []; size = 3 }

let submarine = { ship_type = Submarine; positions = []; size = 3 }

let destroyer = { ship_type = Destroyer; positions = []; size = 2 }

let ships = [ carrier; battleship; cruiser; submarine; destroyer ]

let no_of_rows = 3

let no_of_cols = 2

let ship_board : board =
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

let shoot_board : board =
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

(* [gen_end_position] *)
let gen_end_position (pos : position) (ship : ship) =
  let ship_size = ship.size in
  let start_letter, start_idx = pos in
  function
  | Up ->
      let start = Char.code start_letter in
      (Char.chr (start - ship_size), start_idx)
  | Down ->
      let start = Char.code start_letter in
      (Char.chr (start + ship_size), start_idx)
  | Left -> (start_letter, start_idx - ship_size)
  | Right -> (start_letter, start_idx + ship_size)

(* [valid_pos pos ship board] checks if the board position is valid and
   if ship can be fit inside the board. *)
let valid_pos (pos : position) (direction : direction) (ship : ship) =
  assert (check_char (fst pos) && check_idx (snd pos));
  let end_pos = gen_end_position pos ship direction in
  check_char (fst end_pos) && check_idx (snd end_pos)

(* [modify_occupied] *)
let modify_occupied
    (arr : block_tile array)
    (ship_type : ship_type)
    (pos : position) =
  for idx = 0 to Array.length arr - 1 do
    if arr.(idx).position = pos then
      arr.(idx).occupied <- Occupied ship_type
  done;
  ()

let place_ship
    (ship : ship)
    (start_pos : position)
    (board : board)
    (direction : direction) =
  assert (valid_pos start_pos direction ship);
  let ship_type = ship.ship_type in
  for i = 0 to Array.length board - 1 do
    modify_occupied board.(i) ship_type start_pos
  done;
  ()

(* [check_shot ships position board] checks whether the shot fired has
   hit a ship or not. *)
let check_shot (ships : ships) (position : position) (board : board) :
    bool =
  failwith "Unimplemented"

let attack (ships : ships) (position : position) (board : board) : board
    =
  failwith "Unimplemented"

let finished_game (ships : ships) : bool = failwith "Unimplemented"
