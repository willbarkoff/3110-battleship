open Util

let title = "Battleship"

(** [~^/] is an operator that appends a newline to a string. For
    example, [~^/"Hello"] becomes ["Hello\n"] *)
let ( ~^/ ) a = a ^ "\n"

let authors =
  [ "Will Barkoff"; "Brian Ling"; "Tanay Menezes"; "Travis Zhang" ]

type main_menu_opt =
  | NewGame
  | Quit

let main_menu =
  [ Menu.prompt "New game" NewGame; Menu.prompt "Quit" Quit ]

let print_title () =
  ANSITerminal.set_cursor 1 1;
  ANSITerminal.print_string
    [ ANSITerminal.Bold; ANSITerminal.blue ]
    ~^/title;
  ANSITerminal.print_string [] ~^/("By " ^ pretty_string_of_list authors);
  ANSITerminal.print_string [] "\n\n"

let quit () =
  ANSITerminal.print_string [ ANSITerminal.blue ]
    "Thanks for playing!\n";
  exit 0

let _ =
  if not (Unix.isatty Unix.stdin) then begin
    print_endline "Currently, this game is only supported on ttys";
    exit 1
  end
  else begin
    ANSITerminal.erase ANSITerminal.Screen;
    print_title ();
    match Menu.show_menu "Main menu" main_menu with
    | NewGame -> failwith "Newgame"
    | Quit -> quit ()
  end
