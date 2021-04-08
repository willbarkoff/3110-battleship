type board

exception Invalid

let max_param_length = 0b11111111

type message =
  | GetGamecode
  | Gamecode of string
  | Join of string
  | Joined of bool
  | Sendboard of board
  | Movefirst of bool
  | Move of Battleship.position
  | MoveResult of Battleship.position * Battleship.attack_type
  | Gameend of bool
  | Error

type responder = message -> bool

type listener = message -> responder -> bool

let bytes_of_string = Util.explode

(** Implementation notes: [0x01] for [true] and [0x02] for [false]*)
let bytes_of_bool b = [ Char.chr (if b then 1 else 0) ]

let bytes_of_board b = failwith "TODO"

(** Implementation notes: Returns two bytes, the first byte is the ASCII
    value of the column, and the second byte is the decimal value of the
    row. *)
let bytes_of_position pos =
  let x, y = pos |> Battleship.get_position in
  [ x; Char.chr y ]

(** Implementation notes:

    - [0x00] is [Battleship.Miss]
    - [0x01] is [Battleship.Hit]
    - [0x02] is [Battleship.Untargeted]*)
let bytes_of_attack_type = function
  | Battleship.Miss -> [ Char.chr 0x00 ]
  | Battleship.Hit -> [ Char.chr 0x01 ]
  | Battleship.Untargeted -> [ Char.chr 0x02 ]

let string_of_bytes c = c |> List.to_seq |> String.of_seq

let bool_of_bytes b =
  if List.length b != 1 then raise Invalid
  else
    let byte = List.nth b 1 |> Char.code in
    if byte = 0 then false else if byte = 1 then true else raise Invalid

let board_of_bytes b = failwith "TODO"

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

let message_of_bytes b = failwith "TODO"

let listen_and_serve p l =
  let open Core in
  let open Async in
  let run () =
    let%bind server =
      Tcp.Server.create ~on_handler_error:`Raise
        (Tcp.Where_to_listen.of_port p) (fun _addr r w ->
          Pipe.transfer ~f:Fn.id (Reader.pipe r) (Writer.pipe w))
    in
    Tcp.Server.close_finished server
  in
  Command.async ~summary:"Battleship server" (Command.Param.return run)
  |> Command.run
