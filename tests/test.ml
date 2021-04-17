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
  | Left -> "left"
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

let rec string_list_to_string str_list =
  match str_list with [] -> "" | h :: t -> h ^ string_list_to_string t

let parse_test
    (name : string)
    (str : string)
    (expected_output : string list) : test =
  name >:: fun _ ->
  assert_equal expected_output
    (action_to_string_list (Person.parse_input str))
    ~printer:string_list_to_string

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

let test_state = State.create_state test_player test_player_2

let person_tests =
  [
    get_board_test "initial player should have empty board" test_player
      test_board;
    get_ships_test "initial player should have standard ships list"
      test_player test_ship_list;
    parse_test "place test" "place cruiser A1 Up"
      [ "place"; "cruiser"; "A1"; "Up" ];
    parse_test "place test 2" "place battleship F9 Up"
      [ "place"; "battleship"; "F9"; "Up" ];
    parse_test "place test extra spaces"
      "place        submarine    B5    Down"
      [ "place"; "submarine"; "B5"; "Down" ];
    parse_test "attack test" "attack A1" [ "attack"; "A1" ];
    parse_test_exception "place test invalid input" "place"
      Person.Malformed;
    parse_test_exception "place test invalid input" "place   battleship"
      Person.Malformed;
    parse_test_exception "place test empty input" "" Person.Empty;
    get_player_test "testing current player" test_state
      State.get_current_player test_player_2;
    get_player_test "testing player opponent" test_state
      State.get_opponent test_player;
  ]

let suite =
  "test suite for Battleship"
  >::: List.flatten [ battleship_test; person_tests ]

let _ = run_test_tt_main suite
