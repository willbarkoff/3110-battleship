type t = {
  player_board : Battleship.board;
  oppponent_board : Battleship.board;
}

type action =
  | Place of Battleship.ship_type * Battleship.block_tile
  | Attack of Battleship.block_tile
  | Quit

(** Raised when an empty command is parsed. *)
exception Empty

(** Raised when a malformed command is encountered. *)
exception Malformed

let rec remove_empty (lst : string list) =
  match lst with
  | [] -> raise Empty
  | h :: t ->
      if String.equal "" h then remove_empty t else h :: remove_empty t

let create_place_command lst =
  match lst with _ -> failwith "Unimplemented"

let create_attack_command lst =
  match lst with _ -> failwith "Unimplemented"

let parse_input input =
  let words = String.split_on_char ' ' input in
  let no_empty = remove_empty words in
  match no_empty with
  | [] -> raise Empty
  | h :: t -> (
      match h with
      | "place" -> create_place_command t
      | "attack" -> create_attack_command t
      | "quit" -> Quit
      | _ -> raise Malformed)
