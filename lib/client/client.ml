type message =
  | GetGamecode
  | Gamecode of string
  | Join of string
  | Joined of bool
  | PassState of State.t
  | Error of string

let read_message chan : message = Marshal.from_channel chan

let write_message chan (msg : message) =
  Marshal.to_channel chan msg [];
  flush chan

let get_state_from_message = function
  | PassState s -> s
  | _ -> failwith "invalid"

let get_message_from_state s = PassState s

let rec play in_chan out_chan =
  let open Ui in
  let state =
    in_chan |> read_message |> get_state_from_message
    |> show_player_board |> attack |> show_opponent_board
  in
  flush out_chan;
  if State.finished_game state then finish state
  else begin
    state |> State.toggle_player |> get_message_from_state
    |> write_message out_chan;
    play in_chan out_chan
  end

type internet_menu_option =
  | CreateGame
  | JoinGame
  | Exit

let internet_menu =
  [
    Menu.prompt "Create game" CreateGame;
    Menu.prompt "Join game" JoinGame;
    Menu.prompt "Back to main menu" Exit;
  ]

let place_ships state =
  List.fold_left Selectlocation.place state Battleship.ships

let create_game in_chan out_chan =
  ANSITerminal.erase ANSITerminal.Screen;
  ANSITerminal.set_cursor 1 1;
  GetGamecode |> write_message out_chan;
  match read_message in_chan with
  | Gamecode s -> (
      Util.plfs
        [
          ([], "Your gamecode is ");
          ([ ANSITerminal.blue; ANSITerminal.Underlined ], s);
          ([], ". Share it with the person you'd like to play with.\n\n");
          ([], "Waiting for opponent...\n");
        ];
      match read_message in_chan with
      | PassState s ->
          let new_state = s |> State.toggle_player |> place_ships in
          PassState new_state |> write_message out_chan;
          play in_chan out_chan
      | _ -> Ui.print_error_message ())
  | _ -> Ui.print_error_message ()

let create_state () =
  State.create_state
    (Person.create_player (Battleship.board ()) [])
    (Person.create_player (Battleship.board ()) [])

let join_game in_chan out_chan =
  ANSITerminal.erase ANSITerminal.Screen;
  ANSITerminal.set_cursor 1 1;
  let gamecode = Menu.ask "What is the gamecode?" in
  Join gamecode |> write_message out_chan;
  match read_message in_chan with
  | Joined success ->
      if success then
        Util.plfs
          [
            ( [ ANSITerminal.green; ANSITerminal.Underlined ],
              "Joined!\n\n" );
            ([], "Press ");
            ([ ANSITerminal.Bold ], "enter");
            ([], " when you're ready to place your ships.");
          ];
      ignore (read_line ());
      let new_state = create_state () |> place_ships in
      PassState new_state |> write_message out_chan;
      play in_chan out_chan
  | _ -> Ui.print_error_message ()

let play_internet_game addr =
  let in_chan, out_chan = Unix.open_connection addr in
  ANSITerminal.erase ANSITerminal.Screen;
  ANSITerminal.set_cursor 1 1;
  Util.print_text_centered [ ([], "Battleship") ];
  print_newline ();
  let address =
    match addr with ADDR_INET (h, _) -> h | _ -> failwith "Not right"
  in
  Util.plfs
    [
      ([], "Client at ");
      ( [ ANSITerminal.blue; ANSITerminal.Underlined ],
        Unix.string_of_inet_addr address ^ ":" ^ string_of_int 1234 );
    ];
  print_newline ();
  match Menu.show_menu "Multiplayer" internet_menu with
  | CreateGame -> create_game in_chan out_chan
  | JoinGame -> join_game in_chan out_chan
  | Exit -> ()
(* play in_chan out_chan *)
