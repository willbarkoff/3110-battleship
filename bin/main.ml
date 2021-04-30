open Util
open Ui

let title = "Battleship"

(** [~^/] is an operator that appends a newline to a string. For
    example, [~^/"Hello"] becomes ["Hello\n"] *)
let ( ~^/ ) a = a ^ "\n"

let authors =
  [ "Will Barkoff"; "Brian Ling"; "Tanay Menezes"; "Travis Zhang" ]

type main_menu_opt =
  | NewGame
  | Multiplayer
  | Quit

let main_menu =
  [
    Menu.prompt "New game" NewGame;
    Menu.prompt "Multiplayer" Multiplayer;
    Menu.prompt "Quit" Quit;
  ]

let print_title () =
  ANSITerminal.set_cursor 1 1;
  Util.print_text_centered
    [ ([ ANSITerminal.Bold; ANSITerminal.blue ], title) ];
  Util.print_text_centered
    [ ([], "By " ^ pretty_string_of_list authors) ];
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

let rec play s =
  let moved =
    s |> show_player_board |> attack ~debug:false |> show_opponent_board
  in
  if State.finished_game moved then finish moved
  else moved |> toggle_player |> play

let new_game () =
  State.create_state
    (Person.create_player (Battleship.board ()) [])
    (Person.create_player (Battleship.board ()) [])
  |> place_ships |> toggle_player |> place_ships |> play

let network_port = 1234

let client_port = 1234

let rec show_main_menu () =
  let inet_addr =
    Unix.ADDR_INET (Unix.inet_addr_loopback, client_port)
  in
  if not (Unix.isatty Unix.stdin) then begin
    print_endline "Currently, this game is only supported on ttys";
    exit 1
  end
  else begin
    ANSITerminal.erase ANSITerminal.Screen;
    print_title ();
    Util.print_hr [];
    print_newline ();
    match Menu.show_menu "Main menu" main_menu with
    | NewGame ->
        new_game ();
        show_main_menu ()
    | Multiplayer ->
        Client.play_internet_game inet_addr;
        show_main_menu ()
    | Quit -> quit ()
  end

let _ =
  let usage_message = "battleship [-l]" in
  let local = ref false in

  let speclist = [ ("-l", Arg.Set local, "Play locally") ] in

  Arg.parse speclist (fun _ -> ()) usage_message;
  if !local then show_main_menu ()
  else Server.listen_and_serve network_port
