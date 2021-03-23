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

type board = block_tile array array

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

let empty_board no_of_rows no_of_cols : board =
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

let valid_pos (pos : position) (ship : ship) (board : board) =
  failwith "Unimplemented"

let place_ship
    (ship : ship)
    (start_pos : position)
    (board : board)
    (direction : direction) : board =
  failwith "Unimplemented"

(* [check_shot ships position board] checks whether the shot fired has
   hit a ship or not. *)
let check_shot (ships : ships) (position : position) (board : board) :
    bool =
  failwith "Unimplemented"

let attack (ships : ships) (position : position) (board : board) : board
    =
  failwith "Unimplemented"

let finished_game (ships : ships) : bool = failwith "Unimplemented"
