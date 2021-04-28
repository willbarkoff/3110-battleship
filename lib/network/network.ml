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

let bytes_of_string = Util.explode

(** Implementation notes: [0x01] for [true] and [0x02] for [false]*)
let bytes_of_bool b = [ Char.chr (if b then 1 else 0) ]

(** Implementation notes: Returns two bytes, the first byte is the ASCII
    value of the column, and the second byte is the decimal value of the
    row. *)
let bytes_of_position pos =
  let x, y = pos |> Battleship.get_position in
  [ x; Char.chr y ]

(** Implementation notes:

    - [0x00] is [Battleship.Carrier]
    - [0x01] is [Battleship.Battleship]
    - [0x02] is [Batteship.Cruiser]
    - [0x03] is [Battleship.Submarine]
    - [0x04] is [Battleship.Destroyer] *)
let bytes_of_ship_type = function
  | Battleship.Carrier -> [ Char.chr 0x00 ]
  | Battleship.Battleship -> [ Char.chr 0x01 ]
  | Battleship.Cruiser -> [ Char.chr 0x02 ]
  | Battleship.Submarine -> [ Char.chr 0x03 ]
  | Battleship.Destroyer -> [ Char.chr 0x04 ]

(** Implementation notes:

    - [0x00] is [Battleship.Miss]
    - [0x01] is [Battleship.Hit]
    - [0x02] is [Battleship.Untargeted] *)
let bytes_of_attack_type = function
  | Battleship.Miss -> [ Char.chr 0x00 ]
  | Battleship.Hit -> [ Char.chr 0x01 ]
  | Battleship.Untargeted -> [ Char.chr 0x02 ]

let byte_tile_pos tile =
  let byte_pos =
    bytes_of_position (Battleship.get_tile_position tile)
  in
  (List.nth byte_pos 0, List.nth byte_pos 1)

let byte_tile_attack tile =
  bytes_of_attack_type (Battleship.get_tile_attack tile)

let byte_tile_occupation tile =
  match Battleship.get_tile_occupation tile with
  | Battleship.Occupied ship ->
      let ship_chr = bytes_of_ship_type ship in
      [ Char.chr 0x00 ] @ ship_chr
  | Battleship.Unoccupied -> [ Char.chr 0x01; ' ' ]

let rec insert_lst lst init =
  match lst with [] -> init | h :: t -> insert_lst t (h :: init)

(** Implementation notes:

    - bytes_of_positions returns
      [char position (from A - J); char index (from 1 - 10)]
    - [0x00] is [Battleship.Miss]
    - [0x01] is [Battleship.Hit]
    - [0x02] is [Battleship.Untargeted]
    - [0x00] is [Battleship.Occupied]
    - [0x01] is [Battleship.Unoccupied]
    - [0x00] is [Battleship.Carrier]
    - [0x01] is [Battleship.Battleship]
    - [0x02] is [Batteship.Cruiser]
    - [0x03] is [Battleship.Submarine]
    - [0x04] is [Battleship.Destroyer]

    Method returns flattened board with pos, occupation, and attack type
    (all in terms of bytes) with ' ' to split each position and its
    attributes *)
let bytes_of_board b =
  let board = Array.(concat (to_list b)) in
  let chr_lst =
    Array.fold_left
      (fun init tile ->
        let x, y = byte_tile_pos tile in
        let occupation = byte_tile_occupation tile in
        let attack = byte_tile_attack tile in
        insert_lst attack
          (insert_lst occupation (insert_lst [ x; y ] init)))
      [] board
  in
  List.rev chr_lst

let string_of_bytes c = c |> List.to_seq |> String.of_seq

let bool_of_bytes b =
  if List.length b != 1 then raise Invalid
  else
    let byte = List.nth b 1 |> Char.code in
    if byte = 0 then false else if byte = 1 then true else raise Invalid

let position_of_bytes b =
  if List.length b != 2 then raise Invalid
  else
    let x, y = (List.nth b 0, List.nth b 1) in
    Battleship.create_position (x, Char.code y)

let attack_type_of_bytes b =
  if List.length b != 1 then raise Invalid
  else
    let byte = List.nth b 0 |> Char.code in
    if byte = 0x00 then Battleship.Miss
    else if byte = 0x01 then Battleship.Hit
    else if byte = 0x02 then Battleship.Untargeted
    else raise Invalid

let ship_type_of_bytes byte =
  match byte with
  | 0x00 -> Battleship.Carrier
  | 0x01 -> Battleship.Battleship
  | 0x02 -> Battleship.Cruiser
  | 0x03 -> Battleship.Submarine
  | 0x04 -> Battleship.Destroyer
  | _ -> raise Invalid

let occupation_of_bytes b =
  if List.length b != 2 then raise Invalid
  else
    let occupied, ship =
      (List.nth b 0 |> Char.code, List.nth b 1 |> Char.code)
    in
    match (occupied, ship) with
    | 0x00, s -> Battleship.Occupied (ship_type_of_bytes s)
    | 0x01, _ -> Battleship.Unoccupied
    | _ -> raise Invalid

let board_of_byte_helper lst =
  if List.length lst != 5 then raise Invalid
  else
    let position =
      position_of_bytes [ List.nth lst 0; List.nth lst 1 ]
    in
    let occupation =
      occupation_of_bytes [ List.nth lst 2; List.nth lst 3 ]
    in
    let attack = attack_type_of_bytes [ List.nth lst 4 ] in
    Battleship.create_block_tile position attack occupation

let board_of_bytes chr_lst =
  if List.length chr_lst != 500 then raise (Failure "Length failed")
  else
    let b = ref [||] in
    let arr = ref [||] in
    for i = 0 to (List.length chr_lst / 5) - 1 do
      let block_tile =
        board_of_byte_helper
          [
            List.nth chr_lst (5 * i);
            List.nth chr_lst ((5 * i) + 1);
            List.nth chr_lst ((5 * i) + 2);
            List.nth chr_lst ((5 * i) + 3);
            List.nth chr_lst ((5 * i) + 4);
          ]
      in
      arr := Array.append !arr [| block_tile |];
      if (i + 1) mod 10 = 0 then (
        b := Array.append !b [| !arr |];
        arr := [||])
    done;
    !b

(** [construct_message c params] takes the message with the given code,
    [c] and parameters, [params], and constructs a [char list] of the
    message, formatted for transmission over the wire.*)
let construct_message code parameters =
  Char.chr code
  ::
  List.fold_right
    (fun acc i -> (List.length i |> Char.chr) :: acc)
    parameters []
  @ List.flatten parameters

(** Implementation notes:

    - The first byte of any message is the message code.
    - The byte that follows is the number of parameters, n.
    - The n bytes that follow are the lengths of each parameter, less
      than [max_param_length]

    Message codes:

    - [0x00] represents [Error]
    - [0x01] represents [GetGamecode]
    - [0x02] represents [Gamecode]
    - [0x03] represents [Join]
    - [0x04] represents [Joined]
    - [0x05] represents [Sendboard]
    - [0x06] represents [Movefirst]
    - [0x07] represents [Move]
    - [0x08] represents [MoveResult]
    - [0x09] represents [Gameend]*)
let bytes_of_message = function
  | Error -> construct_message 0x00 []
  | GetGamecode -> construct_message 0x01 []
  | Gamecode gc -> construct_message 0x02 [ bytes_of_string gc ]
  | Join gc -> construct_message 0x03 [ bytes_of_string gc ]
  | Joined success -> construct_message 0x04 [ bytes_of_bool success ]
  | Sendboard board -> construct_message 0x05 [ bytes_of_board board ]
  | Movefirst first -> construct_message 0x06 [ bytes_of_bool first ]
  | Move pos -> construct_message 0x07 [ bytes_of_position pos ]
  | MoveResult (pos, at) ->
      construct_message 0x08
        [ bytes_of_position pos; bytes_of_attack_type at ]
  | Gameend win -> construct_message 0x09 [ bytes_of_bool win ]

let message_of_bytes b =
  if List.length b < 1 then raise Invalid
  else
    let message_code = List.hd b in
    match Char.code message_code with
    | 0x00 -> Error
    | 0x01 -> GetGamecode
    | 0x02 -> Gamecode (string_of_bytes (List.tl b))
    | 0x03 -> Join (string_of_bytes (List.tl b))
    | 0x04 -> Joined (bool_of_bytes (List.tl b))
    | 0x05 -> Sendboard (board_of_bytes (List.tl b))
    | 0x06 -> Movefirst (bool_of_bytes (List.tl b))
    | 0x07 -> Move (position_of_bytes (List.tl b))
    | 0x08 ->
        let message_bytes = List.tl b in
        let pos_byte, at_byte =
          ( [ List.nth message_bytes 0; List.nth message_bytes 1 ],
            [ List.nth message_bytes 2 ] )
        in
        MoveResult
          (position_of_bytes pos_byte, attack_type_of_bytes at_byte)
    | 0x09 -> Gameend (bool_of_bytes (List.tl b))
    | _ -> raise Invalid

type recipient =
  | Sender
  | Opponent

type broadcast = {
  recipient : recipient;
  message : message;
}

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

let listener s m : State.t * broadcast list = failwith "TODO"

let read_wait_time = Core.Time.Span.of_sec 0.1

let send_broadcasts addr =
  List.iter (function
    | { recipient = Sender; message } -> failwith "TODO"
    | { recipient = Opponent; message } -> failwith "TODO")

let update_state new_state id = failwith "TODO"

let parser (_addr : Async.Socket.Address.Inet.t) r w =
  let open Async in
  Reader.read_line r >>| function
  | `Eof -> failwith "Connection terminated"
  | `Ok str ->
      let updated_state, broadcasts =
        str |> Util.explode |> message_of_bytes
        |> listener (players_state _addr)
      in
      failwith "TODO"

let listen_and_serve p =
  let open Core in
  let open Async in
  let run () =
    let%bind server =
      Tcp.Server.create ~on_handler_error:`Raise
        (Tcp.Where_to_listen.of_port p)
        parser
    in
    Tcp.Server.close_finished server
  in
  (* TODO: for some reason unbeknowest to me, this only prints when
     Command.run terminates; however, this is synchronous, so
     command.run hould happen well after this terminates? *)
  Util.plfs
    [
      ([], "Serving at ");
      ( [ ANSITerminal.blue; ANSITerminal.Underlined ],
        "::" ^ string_of_int p );
    ];
  Command.async ~summary:"Battleship server" (Command.Param.return run)
  |> Command.run
