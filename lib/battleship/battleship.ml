open Util

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

let string_of_attack_type = function
  | Hit -> "Hit"
  | Miss -> "Miss"
  | Untargeted -> "Untargeted"

type direction =
  | Left
  | Right
  | Up
  | Down

type block_display =
  | DisplayHit
  | DisplayMiss
  | DisplayShip of ship_type
  | DisplaySea

exception ShipCollision

exception UnknownShip

exception InvalidPosition

type position = char * int

let string_of_position (c, y) =
  "(" ^ String.make 1 c ^ "," ^ string_of_int y ^ ")"

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

let get_ship_name ship =
  match ship.ship_type with
  | Battleship -> "Battleship"
  | Cruiser -> "Cruiser"
  | Carrier -> "Carrier"
  | Submarine -> "Submarine"
  | Destroyer -> "Destroyer"

let ship_print occupied_tile =
  match occupied_tile.occupied with
  | Occupied ship_type -> (
      match ship_type with
      | Carrier -> "C"
      | Destroyer -> "D"
      | Submarine -> "S"
      | Battleship -> "B"
      | Cruiser -> "Cr")
  | _ -> failwith "precondition of occupied"

let get_ship_size ship = ship.size

type ships = ship list

let carrier =
  { ship_type = Carrier; positions = []; size = 5 }

let battleship =
  {
    ship_type = Battleship;
    positions = [];
    size = 4;
  }

let cruiser =
  { ship_type = Cruiser; positions = []; size = 3 }

let submarine =
  { ship_type = Submarine; positions = []; size = 3 }

let destroyer =
  { ship_type = Destroyer; positions = []; size = 2 }

let ships = [ carrier; battleship; cruiser; submarine; destroyer ]

let no_of_rows = 10

let no_of_cols = 10

let create_ship = function
  | "cruiser" -> cruiser
  | "destroyer" -> destroyer
  | "battleship" -> battleship
  | "submarine" -> submarine
  | "carrier" -> carrier
  | _ -> raise UnknownShip

let create_position (tple : char * int) : position = tple

let create_block_tile position attack occupied : block_tile =
  { position; occupied; attack }

let get_position pos = pos

let get_tile_position tile = tile.position

let get_tile_attack tile = tile.attack

let get_tile_occupation tile = tile.occupied

let board () : board =
  let cols = Array.init no_of_rows (fun value -> value + 1) in
  let row letter =
    let char_letter = Char.chr (letter + 65) in
    Array.map
      (fun idx ->
        {
          position = (char_letter, idx);
          occupied = Unoccupied;
          attack = Untargeted;
        })
      cols
  in
  Array.init no_of_cols row

(* [indices_of_position (c, i)] returns the array location of the
   position on the board *)
let indicies_of_position (c, i) = (int_of_char c - 65, i - 1)

(* [check_idx idx] checks whether the second value in position is a
   valid value within the board. *)
let check_idx (idx : int) : bool = idx > 0 && idx <= no_of_cols

(* [check_char letter] checks whether the first value in position is a
   valid value within the board. *)
let check_char (letter : char) : bool =
  let ascii = Char.code letter in
  ascii >= 65 && ascii < 65 + no_of_rows

(* [char_generation op start start_idx offset] is the abstract function
   that generates the different letters when [direction] of ship is [Up]
   or [Down] *)
let char_generation op (start : int) (start_idx : int) (offset : int) =
  (Char.chr (op start offset), start_idx)

(* [int_generation op start_idx start_letter offset] is the abstract
   function that generates the different letters when [direction] of
   ship is [Left] or [Right] *)
let int_generation
    op
    (start_idx : int)
    (start_letter : char)
    (offset : int) =
  (start_letter, op start_idx offset)

(* [gen_positions pos ship direction] generates the ship positions based
   on a specific direction *)
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
  if not (check_char (fst pos) && check_idx (snd pos)) then
    raise InvalidPosition;
  let end_pos = List.hd (List.rev (gen_positions pos ship direction)) in
  check_char (fst end_pos) && check_idx (snd end_pos)

(* [find arr pos idx] returns the index in which [arr] position matches
   [pos] *)
let rec find arr pos idx =
  if idx >= Array.length arr then None
  else if arr.(idx).position = pos then Some idx
  else find arr pos (idx + 1)

(* [check_collision arr ship pos direction] checks if [ship] is going to
   collide with another ship. *)
let check_collision
    (arr : block_tile array)
    (ship : ship)
    (pos : position)
    (direction : direction) : bool =
  let ship_pos = gen_positions pos ship direction in
  let result = ref true in
  for i = 0 to List.length ship_pos - 1 do
    let result_idx = find arr (List.nth ship_pos i) 0 in
    match result_idx with
    | None -> ()
    | Some idx ->
        if arr.(idx).occupied <> Unoccupied then result := false
  done;
  !result

(* [modify_occupied arr ship pos direction] modifies the board when
   placing [ship] onto the board and gives those positions to the ship. *)
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
    (direction : direction)
    debug =
  if not (valid_pos start_pos direction ship) then raise InvalidPosition;
  (* load_and_play_audio "./audio_files/place_ship.wav" 2000; *)
  if debug then (
    for i = 0 to Array.length board - 1 do
      if check_collision board.(i) ship start_pos direction then
        modify_occupied board.(i) ship start_pos direction
      else raise ShipCollision
    done;
    ())
  else (
    load_and_play_audio "./audio_files/place_ship.wav" 2000;
    for i = 0 to Array.length board - 1 do
      if check_collision board.(i) ship start_pos direction then
        modify_occupied board.(i) ship start_pos direction
      else raise ShipCollision
    done;
    ())

let attack pos (board : board) debug =
  try
    let row, col = indicies_of_position pos in
    match board.(row).(col).occupied with
    | Occupied _ ->
        if debug then board.(row).(col).attack <- Hit
        else (
          load_and_play_audio "./audio_files/attack.wav" 4000;
          board.(row).(col).attack <- Hit)
    | Unoccupied ->
        if debug then board.(row).(col).attack <- Miss
        else (
          load_and_play_audio "./audio_files/miss.wav" 4000;
          board.(row).(col).attack <- Miss;
          ())
  with _ -> raise InvalidPosition

let finished_game (board : board) =
  Array.fold_left
    (fun acc arr ->
      Array.fold_left
        (fun acc i ->
          if not acc then false
          else
            match i.occupied with
            | Occupied _ -> (
                match i.attack with Hit -> true | _ -> false)
            | Unoccupied -> true)
        acc arr)
    true board

(** [map_board f b] is the equivalent of [List.map] on a board, [b]*)
let map_board f = Array.map (Array.map f)

let get_player_board =
  map_board (fun tile ->
      match tile.occupied with
      | Occupied ship_type -> (
          match tile.attack with
          | Hit -> DisplayHit
          | Untargeted -> DisplayShip ship_type
          | Miss -> failwith "Tile with ship missed")
      | Unoccupied -> (
          match tile.attack with
          | Untargeted -> DisplaySea
          | Miss -> DisplayMiss
          | Hit -> failwith "Tile without ship hit"))

let get_opponent_board =
  map_board (fun tile ->
      match tile.attack with
      | Hit -> DisplayHit
      | Miss -> DisplayMiss
      | Untargeted -> DisplaySea)

(** [print_tile settings t] prints a tile [t] with the additional
    settings [settings.]*)
let print_tile settings = function
  | DisplayHit ->
      ANSITerminal.print_string (settings @ [ ANSITerminal.red ]) " H "
  | DisplayMiss ->
      ANSITerminal.print_string
        (settings @ [ ANSITerminal.blue ])
        " • "
  | DisplaySea -> ANSITerminal.print_string settings " • "
  | DisplayShip ship_type ->
      let ship_print =
        match ship_type with
        | Carrier -> " C "
        | Destroyer -> " D "
        | Submarine -> " S "
        | Battleship -> " B "
        | Cruiser -> " Cr"
      in
      ANSITerminal.print_string
        (settings @ [ ANSITerminal.green ])
        ship_print

(** [print_board b] prints the given board, [b]*)
let print_board (b : block_display array array) =
  print_string ("--" ^ String.make (Array.length b * 3) '=' ^ "-");
  print_endline "";
  print_string "|";
  for i = 1 to Array.length b do
    print_string " ";
    print_int i;
    print_string " "
  done;
  Array.iteri
    (fun i row ->
      print_string ("\n" ^ String.make 1 (Char.chr (i + 65)));
      Array.iter (print_tile []) row)
    b;
  print_newline ()

let print_board_with_special_tile b pos = failwith "TODO"
