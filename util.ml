let pretty_string_of_list lst =
  let rec pretty_string_asst acc oxford_comma = function
    | [] -> acc
    | [ h ] ->
        if oxford_comma then acc ^ ", and " ^ h else acc ^ " and " ^ h
    | h :: t ->
        pretty_string_asst
          ((if String.length acc > 1 then h ^ ", " else h) ^ acc)
          oxford_comma t
  in
  pretty_string_asst "" (List.length lst > 2) lst

let print_board_legend () =
  ANSITerminal.print_string [ ANSITerminal.red ] "H\t";
  ANSITerminal.print_string [] "Hit\t";
  ANSITerminal.print_string [ ANSITerminal.green ] "\tS\t";
  ANSITerminal.print_string [] "Untargeted ship\n";
  ANSITerminal.print_string [ ANSITerminal.blue ] "•\t";
  ANSITerminal.print_string [] "Miss\t";
  ANSITerminal.print_string [] "\t•\t";
  ANSITerminal.print_string [] "Untargeted square\n\n"

let print_lots_of_fancy_strings =
  List.iter (fun (format, str) -> ANSITerminal.print_string format str)

let plfs = print_lots_of_fancy_strings

let explode s = List.init (String.length s) (String.get s)

let get_terminal_size () =
  ANSITerminal.save_cursor ();
  ANSITerminal.set_cursor 999999 999999;
  let pos = ANSITerminal.pos_cursor () in
  ANSITerminal.restore_cursor ();
  pos

let print_text_centered plfs_spec =
  let length =
    List.fold_left (fun acc (_, t) -> acc + String.length t) 0 plfs_spec
  in
  let width, _ = get_terminal_size () in
  let whitespace = width - length in
  let padding = whitespace / 2 in
  let padding_str = String.make padding ' ' in
  print_string padding_str;
  plfs plfs_spec;
  print_string padding_str
