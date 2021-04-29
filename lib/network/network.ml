exception Invalid

let expected_load = 5

let max_param_length = 0b11111111

type message =
  | GetGamecode
  | Gamecode of string
  | Join of string
  | Joined of bool
  | Sendboard of Battleship.board
  | Movefirst of bool
  | Move of Battleship.position
  | MoveResult of Battleship.position * Battleship.attack_type
  | Gameend of bool
  | Error of string

let print_message = function
  | GetGamecode -> print_endline "GetGamecode"
  | Gamecode s -> print_endline ("Gamecode(\"" ^ s ^ "\")")
  | Join s -> print_endline ("Join(\"" ^ s ^ "\")")
  | Joined b -> print_endline ("Joined(" ^ string_of_bool b ^ ")")
  | Sendboard b ->
      let open Battleship in
      print_endline "Sendboard(";
      b |> get_player_board |> print_board;
      print_endline ")"
  | Movefirst b -> print_endline ("Movefirst(" ^ string_of_bool b ^ ")")
  | Move p ->
      let open Battleship in
      print_endline ("Move(" ^ string_of_position p ^ ")")
  | MoveResult (p, at) ->
      let open Battleship in
      print_endline
        ("MoveResult(" ^ string_of_position p ^ ","
        ^ string_of_attack_type at
        ^ ")")
  | Gameend b -> print_endline ("Gameend(" ^ string_of_bool b ^ ")")
  | Error s -> print_endline ("Error(\"" ^ s ^ "\")")

type recipient =
  | Sender
  | Opponent

type broadcast = {
  recipient : recipient;
  message : message;
}

(* TODO: This is the thing that needs to be implemented. *)
let listener s m : State.t * broadcast list = failwith "TODO"

let recipient b = b.recipient

let message b = b.message

type game = {
  state : State.t;
  player1OutChannel : out_channel;
  player2OutChannel : out_channel;
}

let new_game p1 =
  {
    state =
      State.create_state
        (Person.create_player (Battleship.board ()) [])
        (Person.create_player (Battleship.board ()) []);
    player1OutChannel = p1;
    player2OutChannel =
      p1
      (* We just set player2 out channel to be player 1's temporarily.
         We cahnge this in join_game*);
  }

let games = Hashtbl.create expected_load

let get_game = Hashtbl.find games

(* let send_broadcasts addr = List.iter (function | { recipient =
   Sender; message } -> failwith "TODO" | { recipient = Opponent;
   message } -> failwith "TODO") *)

let update_state new_state id = failwith "TODO"

let write_string chan s =
  output_string chan s;
  flush chan

let read_message chan : message = Marshal.from_channel chan

let write_message chan (msg : message) =
  Marshal.to_channel chan msg [];
  flush chan

let handler_acc gc input output =
  try
    let msg = input |> read_message in
    print_message msg
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
    if game.player1OutChannel <> game.player2OutChannel then false
    else
      let new_game = { game with player2OutChannel = p2 } in
      Hashtbl.remove games gc;
      Hashtbl.add games gc new_game;
      true
  with e ->
    Printexc.raw_backtrace_to_string (Printexc.get_raw_backtrace ())
    |> print_endline;
    false

let handler (input : in_channel) (output : out_channel) =
  let message = input |> read_message in
  message |> print_message;
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
    Menu.prompt "Sendboard" (fun () -> failwith "Unimplemented");
    Menu.prompt "Movefirst" (fun () ->
        Movefirst (Menu.ask_bool "move first"));
    Menu.prompt "Move" (fun () ->
        Move
          (Battleship.create_position
             (Menu.ask_char "pos (char)", Menu.ask_int "pos (int)")));
    Menu.prompt "Gameend" (fun () -> Gameend (Menu.ask_bool "win"));
    Menu.prompt "Error" (fun () -> Error (Menu.ask "error"));
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
     msg |> print_message;
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
