let rec read_pos () =
  try
    Util.plfs [ ([ ANSITerminal.green ], "Row (A-J)> ") ];
    let row =
      read_line () |> Util.explode |> List.hd |> Char.uppercase_ascii
    in
    Util.plfs [ ([ ANSITerminal.green ], "Column (1-10)> ") ];
    let col = read_int () in
    Battleship.create_position (row, col)
  with _ ->
    Util.plfs [ ([ ANSITerminal.red ], "That's not a valid input\n\n") ];
    read_pos ()

let rec read_orientation () =
  try
    Util.plfs [ ([ ANSITerminal.green ], "Orientation (L,R,U,D)> ") ];
    let orientation =
      read_line () |> Util.explode |> List.hd |> Char.uppercase_ascii
    in
    if orientation = 'L' then Battleship.Left
    else if orientation = 'R' then Battleship.Right
    else if orientation = 'U' then Battleship.Up
    else if orientation = 'D' then Battleship.Down
    else failwith "Invalid"
  with _ ->
    Util.plfs [ ([ ANSITerminal.red ], "That's not a valid input\n\n") ];
    read_orientation ()

let rec place (state : State.t) (ship : Battleship.ship) =
  ANSITerminal.erase ANSITerminal.Screen;
  Util.plfs [ ([ ANSITerminal.Bold ], "\nPlace a ship\n\n") ];
  state |> State.get_current_player |> Person.get_board
  |> Battleship.get_player_board |> Battleship.print_board;
  Util.print_board_legend ();
  Util.plfs
    [
      ([], "You're placing the ");
      ([ ANSITerminal.Underlined ], Battleship.get_ship_name ship);
      ([], " which has a size of ");
      ( [ ANSITerminal.Underlined ],
        ship |> Battleship.get_ship_size |> string_of_int );
      ([], ".\n");
      ( [],
        "The orientation denotes which direction the ship is placed \
         from the starting position." );
      ([], "\n");
    ];
  try
    let pos = read_pos () in
    let ori = read_orientation () in
    State.place_ship state pos ship ori
  with _ ->
    Util.plfs
      [
        ( [ ANSITerminal.red ],
          "That's an invalid placement. Press enter to continue.\n\n" );
      ];
    read_line () |> ignore;
    place state ship
