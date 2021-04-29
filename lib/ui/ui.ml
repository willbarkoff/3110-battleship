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
