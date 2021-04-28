type 'a prompt = {
  title : string;
  value : 'a;
}

let prompt title value = { title; value }

(** [print_prompt i prompt] is a helper function that prints the prompt
    [prompt] with index [i + 1]*)
let print_prompt i prompt =
  Util.print_text_centered
    [
      ([ ANSITerminal.Underlined ], "(" ^ string_of_int (i + 1) ^ ")");
      ([], " " ^ prompt.title);
    ]

(** [print_menu] is a helper function that prints a menu. *)
let print_menu title prompts =
  Util.print_text_centered [ ([ ANSITerminal.Bold ], title ^ "\n") ];
  List.iteri print_prompt prompts

let print_fail_message () =
  ANSITerminal.print_string [ ANSITerminal.red ]
    "\nThat's not a valid input. Please try again.\n\n"

let show_menu_failure title prompts onfail =
  print_menu title prompts;
  ANSITerminal.print_string [ ANSITerminal.green ] "\n> ";
  let line = read_line () in
  try (List.nth prompts (int_of_string line - 1)).value
  with _ -> onfail line

let rec show_menu title prompts =
  show_menu_failure title prompts (fun _ ->
      print_fail_message ();
      show_menu title prompts)

let ask question =
  ANSITerminal.print_string [ ANSITerminal.green ]
    ("\n " ^ question ^ "> ");
  read_line ()

let ask_int question =
  ANSITerminal.print_string [ ANSITerminal.green ]
    ("\n " ^ question ^ "> ");
  read_int ()

let ask_char question =
  ANSITerminal.print_string [ ANSITerminal.green ]
    ("\n " ^ question ^ "> ");
  read_line () |> Util.explode |> List.hd

let ask_bool question =
  let answer = ask question in
  answer = "yes" || answer = "y" || answer = "true" || answer = "t"
