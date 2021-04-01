open Util

let title = "Battleship"

(** [~^/] is an operator that appends a newline to a string. For
    example, [~^/"Hello"] becomes ["Hello\n"] *)
let ( ~^/ ) a = a ^ "\n"

let authors =
  [ "Will Barkoff"; "Brian Ling"; "Tanay Menezes"; "Travis Zhang" ]

type main_menu_opt =
  | NewGame
  | Quit

let main_menu =
  [ Menu.prompt "New game" NewGame; Menu.prompt "Quit" Quit ]

let print_title () =
  ANSITerminal.set_cursor 1 1;
  ANSITerminal.print_string
    [ ANSITerminal.Bold; ANSITerminal.blue ]
    ~^/title;
  ANSITerminal.print_string [] ~^/("By " ^ pretty_string_of_list authors);
  ANSITerminal.print_string [] "\n\n"

let quit () =
  ANSITerminal.print_string [ ANSITerminal.blue ]
    "Thanks for playing!\n";
  exit 0

let place_ships state =
  List.fold_left Selectlocation.place state Battleship.ships

let toggle_player state =
  ANSITerminal.erase ANSITerminal.Screen;
  Util.plfs
    [
      ( [ ANSITerminal.Bold ],
        "\n\nPass the computer to the next player.\n" );
      ([], "Press enter when you're ready to continue.");
    ];
  ANSITerminal.save_cursor ();
  ANSITerminal.set_cursor 1 1;
  read_line () |> ignore;
  ANSITerminal.restore_cursor ();
  State.toggle_player state

let show_player_board s =
  ANSITerminal.erase ANSITerminal.Screen;
  Util.plfs
    [
      ([ ANSITerminal.Bold ], "\nYour board:\n");
      ([], "Press enter to continue\n\n");
    ];
  s |> State.get_current_player |> Person.get_board
  |> Battleship.get_player_board |> Battleship.print_board;
  Util.print_board_legend ();
  read_line () |> ignore;
  s

let show_opponent_board s =
  ANSITerminal.erase ANSITerminal.Screen;
  Util.plfs
    [
      ([ ANSITerminal.Bold ], "\nYour opponent's board:\n");
      ([], "Press enter to continue\n\n");
    ];
  s |> State.get_opponent |> Person.get_board
  |> Battleship.get_opponent_board |> Battleship.print_board;
  Util.print_board_legend ();
  read_line () |> ignore;
  s

let rec attack s =
  ANSITerminal.erase ANSITerminal.Screen;
  Util.plfs [ ([ ANSITerminal.Bold ], "\nYour opponent's board:\n") ];
  s |> State.get_opponent |> Person.get_board
  |> Battleship.get_opponent_board |> Battleship.print_board;
  Util.print_board_legend ();
  Util.plfs [ ([], "\n\nWhere would you like to attack?\n") ];
  let pos = Selectlocation.read_pos () in
  try State.attack s pos
  with _ ->
    Util.plfs
      [ ([ ANSITerminal.red ], "\nThat is an invalid position.\n") ];
    attack s

let finish s =
  ANSITerminal.erase ANSITerminal.Screen;
  Util.plfs
    [
      ( [
          ANSITerminal.Blink;
          ANSITerminal.Bold;
          ANSITerminal.Underlined;
          ANSITerminal.green;
        ],
        "GAME OVER!" );
      ([ ANSITerminal.Bold ], "\nPlayer 1 board:\n");
    ];
  s |> State.get_current_player |> Person.get_board
  |> Battleship.get_player_board |> Battleship.print_board;
  Util.plfs [ ([ ANSITerminal.Bold ], "\nPlayer 2 board:\n") ];
  s |> State.get_opponent |> Person.get_board
  |> Battleship.get_player_board |> Battleship.print_board;
  Util.print_board_legend ();
  Util.plfs [ ([], "\n\nPress enter to continue") ];
  read_line () |> ignore

let rec play s =
  let moved = s |> show_player_board |> attack |> show_opponent_board in
  if State.finished_game moved then finish moved
  else moved |> toggle_player |> play

let new_game () =
  State.create_state
    (Person.create_player (Battleship.board ()) [])
    (Person.create_player (Battleship.board ()) [])
  |> place_ships |> toggle_player |> place_ships |> play

let rec show_main_menu () =
  if not (Unix.isatty Unix.stdin) then begin
    print_endline "Currently, this game is only supported on ttys";
    exit 1
  end
  else begin
    ANSITerminal.erase ANSITerminal.Screen;
    print_title ();
    match Menu.show_menu "Main menu" main_menu with
    | NewGame ->
        new_game ();
        show_main_menu ()
    | Quit -> quit ()
  end

let _ = show_main_menu ()
