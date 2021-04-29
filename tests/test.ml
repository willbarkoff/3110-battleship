open OUnit2

let battleship_test =
  [
    ( "sample test" >:: fun _ ->
      assert_equal ~printer:string_of_int 2 (1 + 1) );
  ]

let test_board = Battleship.board ()

let test_board_2 = Battleship.board ()

let carrier = Battleship.create_ship "carrier"

let cruiser = Battleship.create_ship "cruiser"

let destroyer = Battleship.create_ship "destroyer"

let battleship = Battleship.create_ship "battleship"

let submarine = Battleship.create_ship "submarine"

let test_ship_list =
  [ carrier; cruiser; destroyer; battleship; submarine ]

let test_player : Person.player =
  Person.create_player test_board test_ship_list

let test_player_2 : Person.player =
  Person.create_player test_board_2 test_ship_list

let get_board_test
    (name : string)
    (player : Person.player)
    (expected_output : Battleship.board) : test =
  name >:: fun _ ->
  assert_equal expected_output (Person.get_board player)

let get_ships_test
    (name : string)
    (player : Person.player)
    (expected_output : Battleship.ship list) : test =
  name >:: fun _ ->
  assert_equal expected_output (Person.get_ships player)

let get_string_of_position (pos : Battleship.position) : string =
  let position = Battleship.get_position pos in
  Char.escaped (fst position) ^ string_of_int (snd position)

let get_string_of_direction (direction : Battleship.direction) : string
    =
  match direction with
  | Left -> "Left"
  | Right -> "Right"
  | Up -> "Up"
  | Down -> "Down"

let action_to_string_list (action : Person.action) : string list =
  match action with
  | Place (ship_name, position, direction) ->
      [
        "place";
        ship_name;
        get_string_of_position position;
        get_string_of_direction direction;
      ]
  | Attack position -> [ "attack"; get_string_of_position position ]
  | Quit -> [ "quit" ]

let rec string_of_list lst =
  match lst with [] -> "" | h :: t -> h ^ " " ^ string_of_list t

let parse_test
    (name : string)
    (str : string)
    (expected_output : string list) : test =
  name >:: fun _ ->
  assert_equal expected_output
    (action_to_string_list (Person.parse_input str))
    ~printer:string_of_list

let parse_test_exception
    (name : string)
    (input : string)
    (expected_output : exn) : test =
  name >:: fun _ ->
  assert_raises expected_output (fun () -> Person.parse_input input)

let get_player_test
    (name : string)
    (state : State.t)
    (func : State.t -> Person.player)
    (expected_output : Person.player) : test =
  name >:: fun _ -> assert_equal expected_output (func state)

let arr =
  Array.make 10
    (Battleship.create_block_tile
       (Battleship.create_position ('A', 1))
       Battleship.Untargeted Battleship.Unoccupied)

let arr_of_arrs : Battleship.block_tile array array = Array.make 10 arr

let char_of_int i : char = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".[i]

let init_array () =
  let new_arr =
    Array.make 10
      (Array.make 10
         (Battleship.create_block_tile
            (Battleship.create_position ('A', 1))
            Battleship.Untargeted Battleship.Unoccupied))
  in
  for i = 0 to Array.length arr_of_arrs - 1 do
    let row_array = Array.copy arr_of_arrs.(i) in
    for j = 0 to Array.length arr_of_arrs - 1 do
      row_array.(j) <-
        Battleship.create_block_tile
          (Battleship.create_position (char_of_int i, j + 1))
          Battleship.Untargeted Battleship.Unoccupied
    done;
    new_arr.(i) <- Array.copy row_array
  done;
  new_arr

let make_copy arr =
  let copy =
    Array.make 10
      (Array.make 10
         (Battleship.create_block_tile
            (Battleship.create_position ('A', 1))
            Battleship.Untargeted Battleship.Unoccupied))
  in
  for i = 0 to Array.length arr - 1 do
    copy.(i) <- Array.copy arr.(i)
  done;
  arr

let rec update_array
    (new_tile_list : Battleship.block_tile list)
    (board : Battleship.block_tile array array) =
  let board_arr = make_copy board in
  match new_tile_list with
  | [] -> board_arr
  | h :: t -> (
      let pos = Battleship.get_position h.position in
      match pos with
      | row, col ->
          let b = make_copy board_arr in
          let row_array = Array.copy board_arr.(Char.code row - 65) in
          (* Printf.printf "Row index: %s\n" (string_of_int (Char.code
             row - 65)); Printf.printf "column index: %s\n"
             (string_of_int (col - 1)); *)
          row_array.(col - 1) <- h;
          b.(Char.code row - 65) <- Array.copy row_array;
          update_array t b)

let place_cruiser_A1_down () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('A', 1))
        Battleship.Untargeted (Battleship.Occupied Battleship.Cruiser);
      Battleship.create_block_tile
        (Battleship.create_position ('B', 1))
        Battleship.Untargeted (Battleship.Occupied Battleship.Cruiser);
      Battleship.create_block_tile
        (Battleship.create_position ('C', 1))
        Battleship.Untargeted (Battleship.Occupied Battleship.Cruiser);
    ]
    (make_copy (init_array ()))

let place_carrier_D1_right () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('D', 1))
        Battleship.Untargeted (Battleship.Occupied Battleship.Carrier);
      Battleship.create_block_tile
        (Battleship.create_position ('D', 2))
        Battleship.Untargeted (Battleship.Occupied Battleship.Carrier);
      Battleship.create_block_tile
        (Battleship.create_position ('D', 3))
        Battleship.Untargeted (Battleship.Occupied Battleship.Carrier);
      Battleship.create_block_tile
        (Battleship.create_position ('D', 4))
        Battleship.Untargeted (Battleship.Occupied Battleship.Carrier);
      Battleship.create_block_tile
        (Battleship.create_position ('D', 5))
        Battleship.Untargeted (Battleship.Occupied Battleship.Carrier);
    ]
    (make_copy (place_cruiser_A1_down ()))

let place_battleship_E5_right () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('E', 5))
        Battleship.Untargeted
        (Battleship.Occupied Battleship.Battleship);
      Battleship.create_block_tile
        (Battleship.create_position ('E', 6))
        Battleship.Untargeted
        (Battleship.Occupied Battleship.Battleship);
      Battleship.create_block_tile
        (Battleship.create_position ('E', 7))
        Battleship.Untargeted
        (Battleship.Occupied Battleship.Battleship);
      Battleship.create_block_tile
        (Battleship.create_position ('E', 8))
        Battleship.Untargeted
        (Battleship.Occupied Battleship.Battleship);
    ]
    (make_copy (place_carrier_D1_right ()))

let place_destroyer_H10_left () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 9))
        Battleship.Untargeted (Battleship.Occupied Battleship.Destroyer);
      Battleship.create_block_tile
        (Battleship.create_position ('H', 10))
        Battleship.Untargeted (Battleship.Occupied Battleship.Destroyer);
    ]
    (make_copy (place_battleship_E5_right ()))

let place_submarine_J5_up () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('J', 5))
        Battleship.Untargeted (Battleship.Occupied Battleship.Submarine);
      Battleship.create_block_tile
        (Battleship.create_position ('I', 5))
        Battleship.Untargeted (Battleship.Occupied Battleship.Submarine);
      Battleship.create_block_tile
        (Battleship.create_position ('H', 5))
        Battleship.Untargeted (Battleship.Occupied Battleship.Submarine);
    ]
    (make_copy (place_destroyer_H10_left ()))

let attack_A1 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('A', 1))
        Battleship.Hit (Battleship.Occupied Battleship.Cruiser);
    ]
    (make_copy (place_submarine_J5_up ()))

let attack_B1 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('B', 1))
        Battleship.Hit (Battleship.Occupied Battleship.Cruiser);
    ]
    (make_copy (attack_A1 ()))

let attack_C1 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('C', 1))
        Battleship.Hit (Battleship.Occupied Battleship.Cruiser);
    ]
    (make_copy (attack_B1 ()))

let attack_A5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('A', 5))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_C1 ()))

let attack_F7 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('F', 7))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_A5 ()))

let attack_J8 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('J', 8))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_F7 ()))

let attack_H3 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 3))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_J8 ()))

let attack_C3 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('C', 3))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_H3 ()))

let attack_H4 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 4))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_C3 ()))

let attack_A2 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('A', 2))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_H4 ()))

let attack_A3 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('A', 3))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_A2 ()))

let attack_H5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 5))
        Battleship.Hit (Battleship.Occupied Battleship.Submarine);
    ]
    (make_copy (attack_A3 ()))

let attack_G5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('G', 5))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_H5 ()))

let attack_H6 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 6))
        Battleship.Miss Battleship.Unoccupied;
    ]
    (make_copy (attack_G5 ()))

let attack_I5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('I', 5))
        Battleship.Hit (Battleship.Occupied Battleship.Submarine);
    ]
    (make_copy (attack_H6 ()))

let attack_J5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('J', 5))
        Battleship.Hit (Battleship.Occupied Battleship.Submarine);
    ]
    (make_copy (attack_I5 ()))

let attack_D1 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('D', 1))
        Battleship.Hit (Battleship.Occupied Battleship.Carrier);
    ]
    (make_copy (attack_J5 ()))

let attack_D2 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('D', 2))
        Battleship.Hit (Battleship.Occupied Battleship.Carrier);
    ]
    (make_copy (attack_D1 ()))

let attack_D3 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('D', 3))
        Battleship.Hit (Battleship.Occupied Battleship.Carrier);
    ]
    (make_copy (attack_D2 ()))

let attack_D4 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('D', 4))
        Battleship.Hit (Battleship.Occupied Battleship.Carrier);
    ]
    (make_copy (attack_D3 ()))

let attack_D5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('D', 5))
        Battleship.Hit (Battleship.Occupied Battleship.Carrier);
    ]
    (make_copy (attack_D4 ()))

let attack_E5 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('E', 5))
        Battleship.Hit (Battleship.Occupied Battleship.Battleship);
    ]
    (make_copy (attack_D5 ()))

let attack_E6 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('E', 6))
        Battleship.Hit (Battleship.Occupied Battleship.Battleship);
    ]
    (make_copy (attack_E5 ()))

let attack_E7 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('E', 7))
        Battleship.Hit (Battleship.Occupied Battleship.Battleship);
    ]
    (make_copy (attack_E6 ()))

let attack_E8 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('E', 8))
        Battleship.Hit (Battleship.Occupied Battleship.Battleship);
    ]
    (make_copy (attack_E7 ()))

let attack_H9 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 9))
        Battleship.Hit (Battleship.Occupied Battleship.Destroyer);
    ]
    (make_copy (attack_E8 ()))

let attack_H10 () =
  update_array
    [
      Battleship.create_block_tile
        (Battleship.create_position ('H', 10))
        Battleship.Hit (Battleship.Occupied Battleship.Destroyer);
    ]
    (make_copy (attack_H9 ()))

let array_of_state (s : State.t) =
  s |> State.get_current_player |> Person.get_board

let array_of_state_opponent (s : State.t) =
  s |> State.get_opponent |> Person.get_board

let check_occ (tile : Battleship.block_tile) =
  if tile.occupied <> Battleship.Unoccupied then "O" else "U"

let print_board b =
  b
  |> Array.map (Array.map check_occ)
  |> Array.iter (Array.iter print_endline)

let print_position (pos : Battleship.position) =
  match Battleship.get_position pos with
  | c, i -> Char.escaped c ^ string_of_int i

let place_ship_test2
    (name : string)
    (state : State.t)
    (position : char * int)
    (ship : string)
    (direction : Battleship.direction)
    (expected_output : Battleship.block_tile array array) : test =
  name >:: fun _ ->
  assert_equal
    (Battleship.print_board
       (Battleship.get_player_board
          (array_of_state
             (State.place_ship state
                (Battleship.create_position position)
                (Battleship.create_ship ship)
                direction))))
    (Battleship.print_board
       (Battleship.get_player_board expected_output))

let place_ship_test1
    (name : string)
    (state : State.t)
    (position : char * int)
    (ship : string)
    (direction : Battleship.direction)
    (expected_output : Battleship.block_tile array array) : test =
  name >:: fun _ ->
  assert_equal expected_output
    (array_of_state
       (State.place_ship state
          (Battleship.create_position position)
          (Battleship.create_ship ship)
          direction))

let test_state = State.create_state test_player test_player_2

let make_copy_state s =
  let p1 = State.get_current_player s in
  let p2 = State.get_opponent s in
  State.create_state
    (Person.create_player
       (make_copy (Person.get_board p1))
       test_ship_list)
    (Person.create_player
       (make_copy (Person.get_board p2))
       test_ship_list)

let state_1 () = make_copy_state test_state

let state_2 () =
  State.place_ship
    (make_copy_state (state_1 ()))
    (Battleship.create_position ('A', 1))
    (Battleship.create_ship "cruiser")
    Battleship.Down

let state_3 () =
  State.place_ship
    (make_copy_state
       (State.place_ship
          (make_copy_state (state_1 ()))
          (Battleship.create_position ('A', 1))
          (Battleship.create_ship "cruiser")
          Battleship.Down))
    (Battleship.create_position ('D', 1))
    (Battleship.create_ship "carrier")
    Battleship.Right

let state_list =
  [
    (('A', 1), "cruiser", Battleship.Down);
    (('D', 1), "carrier", Battleship.Right);
    (('E', 5), "battleship", Battleship.Right);
    (('H', 10), "destroyer", Battleship.Left);
    (('J', 5), "submarine", Battleship.Up);
  ]

let attack_positions_list =
  [
    ('A', 1);
    ('B', 1);
    ('C', 1);
    ('A', 5);
    ('F', 7);
    ('J', 8);
    ('H', 3);
    ('C', 3);
    ('H', 4);
    ('A', 2);
    ('A', 3);
    ('H', 5);
    ('G', 5);
    ('H', 6);
    ('I', 5);
    ('J', 5);
    ('D', 1);
    ('D', 2);
    ('D', 3);
    ('D', 4);
    ('D', 5);
    ('E', 5);
    ('E', 6);
    ('E', 7);
    ('E', 8);
    ('H', 9);
    ('H', 10);
  ]

let rec create_state count max list state =
  match list with
  | [] -> state
  | h :: t -> (
      if count > max then state
      else
        match h with
        | a, b, c ->
            create_state (count + 1) max t
              (State.place_ship state
                 (Battleship.create_position a)
                 (Battleship.create_ship b)
                 c))

let rec create_state_attack count max (list : (char * int) list) state =
  match list with
  | [] -> state
  | h :: t -> (
      if count > max then state
      else
        match h with
        | l ->
            create_state_attack (count + 1) max t
              (State.attack state (Battleship.create_position l)))

let base_state () =
  State.create_state
    (Person.create_player (Battleship.board ()) test_ship_list)
    (Person.create_player (Battleship.board ()) test_ship_list)

let attack_test1
    (name : string)
    (num_attacks : int)
    (position : char * int)
    (expected_output : Battleship.block_tile array array) : test =
  name >:: fun _ ->
  assert_equal expected_output
    (array_of_state_opponent
       (State.attack
          (create_state_attack 1 num_attacks attack_positions_list
             (State.toggle_player
                (create_state 1 5 state_list (base_state ()))))
          (Battleship.create_position position)))

let attack_test2
    (name : string)
    (num_attacks : int)
    (position : char * int)
    (expected_output : Battleship.block_tile array array) : test =
  name >:: fun _ ->
  assert_equal
    (Battleship.print_board
       (Battleship.get_player_board expected_output))
    (Battleship.print_board
       (Battleship.get_player_board
          (array_of_state_opponent
             (State.attack
                (create_state_attack 1 num_attacks attack_positions_list
                   (State.toggle_player
                      (create_state 1 5 state_list (base_state ()))))
                (Battleship.create_position position)))))

let place_ship_test_exn
    (name : string)
    (state : State.t)
    (position : char * int)
    (ship : string)
    (direction : Battleship.direction)
    (expected_output : exn) : test =
  name >:: fun _ ->
  assert_raises expected_output (fun () ->
      State.place_ship state
        (Battleship.create_position position)
        (Battleship.create_ship ship)
        direction)

let attack_test_exn
    (name : string)
    (state : State.t)
    (position : char * int)
    (expected_output : exn) : test =
  name >:: fun _ ->
  assert_raises expected_output (fun () ->
      State.attack state (Battleship.create_position position))

let finished_game_test
    (name : string)
    (state : State.t)
    (expected_output : bool) : test =
  name >:: fun _ ->
  assert_equal expected_output (State.finished_game state)

let person_tests =
  [
    get_board_test "initial player should have empty board" test_player
      test_board;
    get_ships_test "initial player should have standard ships list"
      test_player test_ship_list;
    (* parse_test "place test" "place cruiser A1 Up" [ "place";
       "cruiser"; "A1"; "Up" ]; parse_test "place test 2" "place
       battleship F9 Up" [ "place"; "battleship"; "F9"; "Up" ]; *)
    (* parse_test "place test extra spaces" "place submarine B5 Down" [
       "place"; "submarine"; "B5"; "Down" ]; parse_test "attack test"
       "attack A1" [ "attack"; "A1" ]; *)
    (* parse_test_exception "place test invalid input" "place"
       Person.Empty; parse_test_exception "place test invalid input"
       "place battleship" Person.Empty; *)
    parse_test_exception "place test empty input" "" Person.Empty;
  ]

let state_tests =
  [
    get_player_test "testing current player" test_state
      State.get_current_player test_player_2;
    get_player_test "testing player opponent" test_state
      State.get_opponent test_player;
    get_player_test "testing toggle player"
      (State.toggle_player test_state)
      State.get_current_player test_player;
    place_ship_test1 "placing cruiser at A1"
      (create_state 1 0 state_list (base_state ()))
      ('A', 1) "cruiser" Battleship.Down
      (place_cruiser_A1_down ());
    place_ship_test1 "placing carrier at D1"
      (create_state 1 1 state_list (base_state ()))
      ('D', 1) "carrier" Battleship.Right
      (place_carrier_D1_right ());
    place_ship_test1 "placing battleship at E5"
      (create_state 1 2 state_list (base_state ()))
      ('E', 5) "battleship" Battleship.Right
      (place_battleship_E5_right ());
    place_ship_test1 "placing destroyer at H10"
      (create_state 1 3 state_list (base_state ()))
      ('H', 10) "destroyer" Battleship.Left
      (place_destroyer_H10_left ());
    place_ship_test1 "placing submarine at J5"
      (create_state 1 4 state_list (base_state ()))
      ('J', 5) "submarine" Battleship.Up
      (place_submarine_J5_up ());
    attack_test1 "attacking A1 hit" 0 ('A', 1) (attack_A1 ());
    attack_test1 "attacking B1 hit" 1 ('B', 1) (attack_B1 ());
    attack_test1 "attacking C1 hit" 2 ('C', 1) (attack_C1 ());
    attack_test1 "attacking A5 miss" 3 ('A', 5) (attack_A5 ());
    attack_test1 "attacking F7 miss" 4 ('F', 7) (attack_F7 ());
    attack_test1 "attacking J8 miss" 5 ('J', 8) (attack_J8 ());
    attack_test1 "attacking H3 miss" 6 ('H', 3) (attack_H3 ());
    attack_test1 "attacking C3 miss" 7 ('C', 3) (attack_C3 ());
    attack_test1 "attacking H4 miss" 8 ('H', 4) (attack_H4 ());
    attack_test1 "attacking A2 miss" 9 ('A', 2) (attack_A2 ());
    attack_test1 "attacking A3 miss" 10 ('A', 3) (attack_A3 ());
    attack_test1 "attacking H5 hit" 11 ('H', 5) (attack_H5 ());
    attack_test1 "attacking G5 miss" 12 ('G', 5) (attack_G5 ());
    attack_test1 "attacking H6 miss" 13 ('H', 6) (attack_H6 ());
    attack_test1 "attacking I5 hit" 14 ('I', 5) (attack_I5 ());
    attack_test1 "attacking J5 hit" 15 ('J', 5) (attack_J5 ());
    attack_test1 "attacking D1 hit" 16 ('D', 1) (attack_D1 ());
    attack_test1 "attacking D2 hit" 17 ('D', 2) (attack_D2 ());
    attack_test1 "attacking D3 hit" 18 ('D', 3) (attack_D3 ());
    attack_test1 "attacking D4 hit" 19 ('D', 4) (attack_D4 ());
    attack_test1 "attacking D5 hit" 20 ('D', 5) (attack_D5 ());
    attack_test1 "attacking E5 hit" 21 ('E', 5) (attack_E5 ());
    attack_test1 "attacking E6 hit" 22 ('E', 6) (attack_E6 ());
    attack_test1 "attacking E7 hit" 23 ('E', 7) (attack_E7 ());
    attack_test1 "attacking E8 hit" 24 ('E', 8) (attack_E8 ());
    attack_test1 "attacking H9 hit" 25 ('H', 9) (attack_H9 ());
    finished_game_test "unfinished game"
      (create_state_attack 1 26 attack_positions_list
         (State.toggle_player
            (create_state 1 5 state_list (base_state ()))))
      false;
    attack_test1 "attacking H10 hit" 26 ('H', 10) (attack_H10 ());
    finished_game_test "finished game"
      (create_state_attack 1 27 attack_positions_list
         (State.toggle_player
            (create_state 1 5 state_list (base_state ()))))
      true;
    place_ship_test_exn "ship collision A1"
      (State.place_ship (base_state ())
         (Battleship.create_position ('A', 1))
         (Battleship.create_ship "cruiser")
         Battleship.Down)
      ('A', 1) "battleship" Battleship.Right Battleship.ShipCollision;
    place_ship_test_exn "unknown ship ship" (base_state ()) ('B', 1)
      "ship" Battleship.Right Battleship.UnknownShip;
    place_ship_test_exn "invalid position 0 is not a column"
      (base_state ()) ('B', 0) "battleship" Battleship.Right
      Battleship.InvalidPosition;
    place_ship_test_exn "invalid position 11 is not a column"
      (base_state ()) ('B', 11) "battleship" Battleship.Right
      Battleship.InvalidPosition;
    place_ship_test_exn "invalid position K is not a row"
      (base_state ()) ('K', 1) "battleship" Battleship.Right
      Battleship.InvalidPosition;
    place_ship_test_exn "invalid position M is not a row"
      (base_state ()) ('M', 1) "battleship" Battleship.Right
      Battleship.InvalidPosition;
    place_ship_test_exn "invalid position: ship would go off the board"
      (base_state ()) ('A', 1) "battleship" Battleship.Left
      Battleship.InvalidPosition;
    attack_test_exn
      "invalid position: position off the board, no 0 column"
      (base_state ()) ('A', 0) Battleship.InvalidPosition;
    attack_test_exn "invalid position: position off the board, no X row"
      (base_state ()) ('X', 1) Battleship.InvalidPosition;
  ]

let suite =
  "test suite for Battleship"
  >::: List.flatten [ battleship_test; person_tests; state_tests ]

let _ = run_test_tt_main suite
