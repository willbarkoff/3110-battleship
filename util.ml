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
