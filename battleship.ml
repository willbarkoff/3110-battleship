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
  occupied : block_occupation;
  attack : attack_type;
}

type board = block_tile list list

type ship = {
  ship : ship_type;
  size : int;
}

type ships = ship list

let carrier = { ship = Carrier; size = 5 }

let battleship = { ship = Battleship; size = 4 }

let cruiser = { ship = Cruiser; size = 3 }

let submarine = { ship = Submarine; size = 3 }

let destroyer = { ship = Destroyer; size = 2 }

let ships = [ carrier; battleship; cruiser; submarine; destroyer ]

let no_of_rows = 10

let no_of_cols = 10

let empty_board : board =
  let rows =
    List.init no_of_rows (fun ascii -> Char.chr (ascii + 65))
  in
  let row idx =
    List.map
      (fun letter ->
        {
          position = (letter, idx);
          occupied = Unoccupied;
          attack = Untargeted;
        })
      rows
  in
  List.init no_of_cols row

(* [check_idx ] *)
let check_idx (idx : int) : bool = idx >= 0 && idx < no_of_rows

(* [check_char ] *)
let check_char (letter : char) : bool =
  let ascii = Char.code letter in
  ascii >= 65 && ascii < 65 + no_of_cols

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
  assert (check_idx (snd pos) && check_char (fst pos));
  let end_pos = gen_end_position pos ship direction in
  check_idx (snd end_pos) && check_char (fst end_pos)

let place_ship
    (ship : ship)
    (start_pos : position)
    (board : board)
    (direction : direction) : board =
  assert (valid_pos start_pos direction ship);
  failwith "UnImplemented"

(* [check_shot ships position board] checks whether the shot fired has
   hit a ship or not. *)
let check_shot (ships : ships) (position : position) (board : board) :
    bool =
  failwith "Unimplemented"

let attack (ships : ships) (position : position) (board : board) : board
    =
  failwith "Unimplemented"

let finished_game (ships : ships) : bool = failwith "Unimplemented"
