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

let init_array =
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
          Printf.printf "Row index: %s\n"
            (string_of_int (Char.code row - 65));
          Printf.printf "column index: %s\n" (string_of_int (col - 1));
          row_array.(col - 1) <- h;
          b.(Char.code row - 65) <- Array.copy row_array;
          update_array t b)

let place_cruiser_A1_down =
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
    (make_copy init_array)

let array_of_state (s : State.t) =
  Printf.printf "%s\n" "array of state:";
  s |> State.get_current_player |> Person.get_board

let check_occ (tile : Battleship.block_tile) =
  if tile.occupied <> Battleship.Unoccupied then "O" else "U"

let print_board b =
  b
  |> Array.map (Array.map check_occ)
  |> Array.iter (Array.iter print_endline)

let print_position (pos : Battleship.position) =
  match Battleship.get_position pos with
  | c, i -> Char.escaped c ^ string_of_int i

let get_place_ship_test2
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

let get_place_ship_test1
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

let person_tests =
  [
    get_board_test "initial player should have empty board" test_player
      test_board;
    get_ships_test "initial player should have standard ships list"
      test_player test_ship_list;
    parse_test "place test" "place cruiser A1 Up"
      [ "place"; "cruiser"; "A1"; "Up" ];
    (* parse_test "place test 2" "place\n battleship F9 Up" [ "place";
       "battleship"; "F9"; "Up" ]; parse_test "place test extra spaces"
       "place submarine B5 Down" [ "place"; "submarine"; "B5"; "Down" ];
       parse_test "attack test" "attack A1" [ "attack"; "A1" ]; *)
    (* parse_test_exception "place test invalid input" "place"
       Person.Empty; parse_test_exception "place test invalid input"
       "place battleship" Person.Empty; *)
    parse_test_exception "place test empty input" "" Person.Empty;
    get_player_test "testing current player" test_state
      State.get_current_player test_player_2;
    get_player_test "testing player opponent" test_state
      State.get_opponent test_player;
    get_place_ship_test2 "placing cruiser at A1" test_state ('A', 1)
      "cruiser" Battleship.Down place_cruiser_A1_down;
    (* get_place_ship_test2 "placing carrier at D1" test_state ('D', 1)
       "carrier" Battleship.Right place_carrier_D1_right; *)
  ]

let suite =
  "test suite for Battleship"
  >::: List.flatten [ battleship_test; person_tests ]

let _ = run_test_tt_main suite

let place_carrier_D1_right =
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
    (make_copy place_cruiser_A1_down)
