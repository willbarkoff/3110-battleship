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

exception ShipCollision

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

let create_ship = function
  | "cruiser" -> cruiser
  | "destroyer" -> destroyer
  | "battleship" -> battleship
  | "submarine" -> submarine
  | "carrier" -> carrier
  | _ -> failwith "Ship does not exist"

let create_position (tple : char * int) : position = tple

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

(* [check_idx idx] checks whether the second value in position is a
   valid value within the board. *)
let check_idx (idx : int) : bool = idx >= 0 && idx < no_of_cols

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
  assert (check_char (fst pos) && check_idx (snd pos));
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
    (direction : direction) =
  assert (
    let cond = valid_pos start_pos direction ship in
    if not cond then print_endline "Not a valid position";
    cond);
  assert (
    let cond = List.length ship.positions = 0 in
    if not cond then
      print_endline "Ship has already been placed on board";
    cond);
  try
    for i = 0 to Array.length board - 1 do
      if check_collision board.(i) ship start_pos direction then
        modify_occupied board.(i) ship start_pos direction
      else raise ShipCollision
    done;
    ()
  with ShipCollision -> print_endline "Ship Collision!"

(* [check_shot ships shot_pos] checks whether the shot has hit a ship or
   not. *)
let check_shot (ships : ships) (shot_pos : position) : bool =
  assert (check_char (fst shot_pos) && check_idx (snd shot_pos));
  let ship_pos = List.map (fun x -> x.positions) ships in
  List.mem shot_pos (List.flatten ship_pos)

(* [modify attack] modifies the tile's attack as Hit, Miss *)
let modify_attack
    (arr : block_tile array)
    (ships : ships)
    (shot_pos : position)
    (board : board) : unit =
  Array.iter
    (fun tile ->
      if check_shot ships shot_pos then tile.attack <- Hit
      else tile.attack <- Miss)
    arr

(* [modify destroyed] modifies ship's destroyed to be true when the ship
   was hit *)
let modify_destroyed
    (arr : block_tile array)
    (shot_pos : position)
    (ship : ship) : unit =
  ship.destroyed <-
    Array.for_all
      (fun tile -> if tile.attack = Hit then true else false)
      arr;
  ()

(* how to check if all the tile in one ship is destroyed *)

let attack
    (ships : ships)
    (shot_pos : position)
    (ship : ship)
    (board : board) : unit =
  let row = board.(snd shot_pos) in
  for i = 0 to Array.length row - 1 do
    modify_attack board.(i) ships shot_pos board;
    modify_destroyed board.(i) shot_pos ship
  done;
  ()

(* Modify the board so that the block tile is either marked as hit or
   missed. Update ship.destroyed status 2. Check if all the ship
   position has been hit, modify ship.destroyed to be true *)
let finished_game (ships : ships) : bool =
  List.for_all (fun ship -> ship.destroyed) ships

let print_board (tile_printer : block_tile -> unit) (b : board) =
  print_string ("--" ^ String.make (Array.length b * 3) '=' ^ "-");
  Array.iteri
    (fun i row ->
      print_string ("\n" ^ String.make 1 (Char.chr (i + 65)));
      Array.iter tile_printer row)
    b;
  print_endline "";
  print_string "|";
  for i = 1 to Array.length b do
    print_string " ";
    print_int i;
    print_string " "
  done;
  print_newline ()

let print_opponent_board =
  print_board (fun tile ->
      match tile.attack with
      | Hit -> ANSITerminal.print_string [ ANSITerminal.red ] " H "
      | Miss -> ANSITerminal.print_string [ ANSITerminal.blue ] " • "
      | Untargeted -> print_string " • ")

let print_player_board =
  print_board (fun tile ->
      match tile.occupied with
      | Occupied _ -> (
          match tile.attack with
          | Hit -> ANSITerminal.print_string [ ANSITerminal.red ] " H "
          | Untargeted ->
              ANSITerminal.print_string [ ANSITerminal.green ] " S "
          | Miss -> failwith "Tile with ship missed.")
      | Unoccupied -> (
          match tile.attack with
          | Untargeted -> print_endline "•"
          | Miss ->
              ANSITerminal.print_string [ ANSITerminal.blue ] " • "
          | Hit -> failwith "Tile without ship hit"))
