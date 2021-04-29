exception Invalid

let expected_load = 5

let max_param_length = 0b11111111

type message =
  | GetGamecode
  | Gamecode of string
  | Join of string
  | Joined of bool
  | PassState of State.t
  | Error of string

let new_game p1 = [ p1 ]

let games = Hashtbl.create expected_load

let get_game = Hashtbl.find games

let read_message chan : message = Marshal.from_channel chan

let write_message chan (msg : message) =
  Marshal.to_channel chan msg [];
  flush chan

let rec handler_acc gc input output =
  try
    let msg = input |> read_message in
    match msg with
    | PassState s ->
        write_message
          (List.nth (get_game gc) (State.get_current_player_number s))
          (PassState s);
        if not (State.finished_game s) then handler_acc gc input output
    | _ ->
        Error "Invalid message" |> write_message output;
        handler_acc gc input output
  with
  | End_of_file ->
      write_message output (Error "EOF")
      (* TODO: maybe log an error too? the client likely disconnected *)
  | Failure f ->
      write_message output (Error ("A failure occured: " ^ f))
  | Invalid -> write_message output (Error "Couldn't parse request")

let rec create_gamecode (p1 : out_channel) : string =
  let new_gamecode =
    String.init 8 (fun _ -> Char.chr (Random.int 26 + 97))
  in
  if Hashtbl.mem games new_gamecode then
    (* uh oh... a collision! *)
    create_gamecode p1
  else begin
    Hashtbl.add games new_gamecode (new_game p1);
    new_gamecode
  end

let join_gamecode (p2 : out_channel) (gc : string) : bool =
  try
    let game = get_game gc in
    if List.length game < 2 || List.length game > 2 then false
    else
      let new_game = p2 :: game in
      Hashtbl.remove games gc;
      Hashtbl.add games gc new_game;
      true
  with e ->
    Printexc.raw_backtrace_to_string (Printexc.get_raw_backtrace ())
    |> print_endline;
    false

let handler (input : in_channel) (output : out_channel) =
  let message = input |> read_message in
  try
    match message with
    | GetGamecode ->
        let gamecode = output |> create_gamecode in
        let response = Gamecode gamecode in
        response |> write_message output;
        handler_acc gamecode input output
    | Join gc ->
        if join_gamecode output gc then begin
          Joined true |> write_message output;
          handler_acc gc input output
        end
        else
          (* the game doesn't exist :( *)
          write_message output (Error "Game doesn't exist")
    | _ -> write_message output (Error "You must join a game first.")
    (* You need to join a game first, silly! *)
  with
  | End_of_file ->
      write_message output (Error "EOF")
      (* TODO: maybe log an error too? the client likely disconnected *)
  | Failure f -> write_message output (Error ("Failure: " ^ f))
  | Invalid -> write_message output (Error "Invalid")

let listen_and_serve p =
  Random.self_init ();
  let addr = Unix.inet_addr_loopback in
  let inet_addr = Unix.ADDR_INET (addr, p) in
  ANSITerminal.erase ANSITerminal.Screen;
  ANSITerminal.set_cursor 1 1;
  Util.print_text_centered [ ([], "Battleship") ];
  print_newline ();
  Util.plfs
    [
      ([], "Serving at ");
      ( [ ANSITerminal.blue; ANSITerminal.Underlined ],
        Unix.string_of_inet_addr addr ^ ":" ^ string_of_int p );
    ];
  print_newline ();
  Unix.establish_server handler inet_addr

let compose_menu =
  [
    Menu.prompt "GetGamecode" (fun () -> GetGamecode);
    Menu.prompt "Gamecode" (fun () -> Gamecode (Menu.ask "gamecode"));
    Menu.prompt "Join" (fun () -> Join (Menu.ask "gamecode"));
    Menu.prompt "Joined" (fun () -> Joined (Menu.ask_bool "success"));
  ]

(** [network_debug_compose ()] allows the user to use the terminal to
    compose a message to be sent in Network debug mode.*)
let network_debug_compose () =
  (Menu.show_menu "Compose a message" compose_menu) ()

let rec network_debug_acc in_chan out_chan =
  let open ANSITerminal in
  network_debug_compose () |> write_message out_chan;
  (try
     let msg = in_chan |> read_message in
     Util.plfs [ ([ black; on_green ], "OK\n"); ([], " ") ];
     print_newline ()
   with e ->
     Util.plfs
       [
         ([ white; on_red ], "EXN\n");
         ([], " " ^ Printexc.to_string e ^ "\n");
       ]);
  read_line () |> ignore;
  network_debug_acc in_chan out_chan

let network_debug p =
  let addr = Unix.inet_addr_loopback in
  let inet_addr = Unix.ADDR_INET (addr, p) in
  ANSITerminal.erase ANSITerminal.Screen;
  ANSITerminal.set_cursor 1 1;
  Util.print_text_centered
    [ ([ ANSITerminal.blue; ANSITerminal.Underlined ], "Battleship") ];
  Util.print_text_centered [ ([], "This is network debug mode.") ];
  Util.print_hr [];
  let in_chan, out_chan = Unix.open_connection inet_addr in
  network_debug_acc in_chan out_chan
