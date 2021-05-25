exception Invalid

type game = out_channel list

let _ = Random.self_init ()

(** The expected load is the number of expected concurrent games,
    initally. It is so that we know the size that the [games] Hashtbl
    should start at. *)
let expected_load = 10

(** The length of a gamecode *)
let gamecode_size = 6

(** The alphabet to be used when generating gamecodes. It's a list of
    strings rather than a list of characters, which means you could do
    some cool things with this, like make each one an animal or
    something. If only I were creative.*)
let gamecode_alphabet =
  Util.explode
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  |> List.map (fun chr -> String.make 1 chr)

let generate_gamecode () =
  List.init gamecode_size (fun _ ->
      Random.int (List.length gamecode_alphabet))
  |> List.fold_left
       (fun acc num -> List.nth gamecode_alphabet num ^ acc)
       ""

let new_game p1 = [ p1 ]

let games = Hashtbl.create expected_load

type message =
  | PassState of State.t
  | Error of string

type communication_message =
  | BroadcastState of int * State.t
  | AddMeToGame of string * out_channel
  | CMNullMessage

type main_message =
  | GetNumPlayers
  | NumPlayers of int
  | MMNullMessage

let internal_chan : communication_message Event.channel =
  Event.new_channel ()

let main_chan : main_message Event.channel = Event.new_channel ()

let print_games (g : (string, game) Hashtbl.t) : unit =
  print_endline (string_of_int (Hashtbl.length g));
  Hashtbl.iter (fun x _ -> print_endline x) g

let rec print_list = function
  | [] ->
      print_string "";
      ""
  | h :: t ->
      print_string (h ^ " " ^ print_list t);
      ""

(* let print_key_games = games |> Map.keys |> print_list *)

let read_message chan : message = Marshal.from_channel chan

let write_message chan (msg : message) =
  Marshal.to_channel chan msg [];
  flush chan

let check_intern_chan players =
  match
    Event.receive internal_chan
    |> Event.poll
    |> Option.value ~default:CMNullMessage
  with
  | BroadcastState (whom, what) ->
      PassState what |> write_message (List.nth !players whom)
  | AddMeToGame (code, chan) ->
      Hashtbl.replace games code (Hashtbl.find games code @ [ chan ])
  | _ -> ()

let check_main_chan players =
  match
    Event.receive main_chan |> Event.poll
    |> Option.value ~default:MMNullMessage
  with
  | GetNumPlayers ->
      NumPlayers (List.length !players)
      |> Event.send main_chan |> Event.sync
  | _ -> ()

let spawn_communication_manager () =
  print_endline "CREATED THREAD";
  Thread.create
    (fun _ ->
      let players = ref [] in
      while true do
        check_intern_chan players;
        check_main_chan players
      done)
    ()
  |> ignore

let rec handler player_num input output code =
  try
    let msg = input |> read_message in
    print_endline "GOT MESSAGE";
    begin
      match msg with
      | PassState s ->
          Event.send internal_chan
            (BroadcastState ((player_num + 1) mod 2, s))
          |> Event.sync
      | _ -> Error "Invalid message" |> write_message output
    end;
    handler player_num input output code
  with
  | End_of_file ->
      write_message output (Error "EOF")
      (* TODO: maybe log an error too? the client likely disconnected *)
  | Failure f ->
      write_message output (Error ("A failure occured: " ^ f))
  | Invalid -> write_message output (Error "Couldn't parse request")

let setup_handler (input : in_channel) (output : out_channel) =
  Event.send main_chan GetNumPlayers |> Event.sync;
  match Event.receive main_chan |> Event.sync with
  | NumPlayers n ->
      if n = 0 then begin
        let code = generate_gamecode () in
        AddMeToGame (code, output)
        |> Event.send internal_chan
        |> Event.sync;
        print_endline "PLAYER 0 JOINED";
        handler 0 input output code
      end
      else if n = 1 then begin
        let gc = "5" in
        AddMeToGame (gc, output)
        |> Event.send internal_chan
        |> Event.sync;
        print_endline "PLAYER 1 JOINED";
        handler 1 input output gc
      end
      else Error "The game is full" |> write_message output
  | _ ->
      failwith "The state handler responded with an invalid response."

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
  spawn_communication_manager ();
  Fancyserver.establish_server setup_handler inet_addr
