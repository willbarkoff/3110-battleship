type t = {
  player_board : Battleship.board;
  oppponent_board : Battleship.board;
}

type position = char * int

type direction =
  | Left
  | Right
  | Up
  | Down

type action =
  | Place of string * position * direction
  | Attack of position
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

(** [explode s] takes the string [s] and returns it as a list of chars.
    inspired by
    https://stackoverflow.com/questions/10068713/string-to-list-of-char *)
let explode s = List.init (String.length s) (String.get s)

let location_of_string_list s =
  try
    (List.hd (explode (List.hd s)), int_of_string (List.hd (List.tl s)))
  with _ -> raise Malformed

let direction_of_string_list s =
  try
    match List.hd (List.tl (List.tl s)) with
    | "Left" -> Left
    | "Right" -> Right
    | "Down" -> Down
    | "Up" -> Up
    | _ -> raise Malformed
  with _ -> raise Malformed

let create_place_command = function
  | h :: t ->
      Place (h, location_of_string_list t, direction_of_string_list t)
  | _ -> raise Malformed

let create_attack_command = function
  | [] -> raise Malformed
  | lst -> Attack (location_of_string_list lst)

(** [parse_input input] turns the string [input] into an [action]
    corresponding to that input *)
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
