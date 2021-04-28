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
  | Error

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
  | Error -> print_endline "Error"

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
  player1Writer : Async.Writer.t;
  player2Writer : Async.Writer.t;
}

let games = Hashtbl.create expected_load

let players = Hashtbl.create (expected_load * 2)

let players_game_id p : string =
  p |> Async.Socket.Address.Inet.to_string |> Hashtbl.find players

let players_game p : game = p |> players_game_id |> Hashtbl.find games

let players_state p = (players_game p).state

let read_wait_time = Core.Time.Span.of_sec 0.1

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

let handler (input : in_channel) (output : out_channel) =
  try
    let msg = input |> read_message in
    print_message msg
  with
  | End_of_file ->
      write_message output Error
      (* TODO: maybe log an error too? the client likely disconnected *)
  | Failure _ -> write_message output Error
  | Invalid -> write_message output Error

let listen_and_serve p =
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

let rec network_debug_acc in_chan out_chan =
  let open ANSITerminal in
  Util.plfs [ ([ ANSITerminal.Bold ], ">  ") ];
  let input = read_line () in
  input |> write_string out_chan;
  (try
     let msg = in_chan |> read_message in
     Util.plfs [ ([ black; on_green ], "OK "); ([], " ") ];
     msg |> print_message;
     print_newline ()
   with e ->
     Util.plfs
       [
         ([ white; on_red ], "EXN");
         ([], " " ^ Printexc.to_string e ^ "\n");
       ]);
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
