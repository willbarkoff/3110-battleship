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

let games =
  print_endline "CREATE NEW HASHTABLE";
  Hashtbl.create expected_load

let print_games g =
  print_endline (string_of_int (Hashtbl.length g));
  Hashtbl.iter (fun x _ -> print_endline x) g

let get_game =
  print_endline "GET_GAME";
  print_games games;
  Hashtbl.find games

let read_message chan : message = Marshal.from_channel chan

let write_message chan (msg : message) =
  Marshal.to_channel chan msg [];
  flush chan

let rec handler_acc gc input output =
  try
    let msg = input |> read_message in
    flush output;
    print_endline "HANDLER ACC";
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
    Random.self_init ();
    String.init 8 (fun _ -> Char.chr (Random.int 26 + 97))
  in
  if Hashtbl.mem games new_gamecode then
    (* uh oh... a collision! *)
    create_gamecode p1
  else begin
    Hashtbl.add games new_gamecode (new_game p1);
    print_string "CREATE";
    print_games games;
    new_gamecode
  end

let join_gamecode (p2 : out_channel) (gc : string) : bool =
  try
    print_string "JOIN";
    print_games games;
    let game = get_game gc in
    if List.length game < 2 || List.length game > 2 then false
    else
      let new_game = p2 :: game in
      Hashtbl.remove games gc;
      Hashtbl.add games gc new_game;
      true
  with e ->
    Printexc.to_string e |> print_endline;
    Printexc.raw_backtrace_to_string (Printexc.get_raw_backtrace ())
    |> print_endline;
    false

let handler (input : in_channel) (output : out_channel) =
  let message = input |> read_message in
  flush output;
  print_endline "CONNECTION OPENED";
  print_games games;
  try
    match message with
    | GetGamecode ->
        let gamecode = create_gamecode output in
        let response = Gamecode gamecode in
        response |> write_message output;
        print_endline "PRINTING NEW GAMES";
        print_games games;
        handler_acc gamecode input output
    | Join gc ->
        print_endline "PRINTING JOINED GAMES";
        print_games games;
        if join_gamecode output gc then begin
          Joined true |> write_message output;
          handler_acc gc input output
        end
        else
          (* the game doesn't exist :( *)
          write_message output (Error "Game doesn't exist")
    | _ ->
        write_message output (Error "You must\n\n   join a game first.")
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
