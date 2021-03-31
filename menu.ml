type 'a prompt = {
  title : string;
  value : 'a;
}

let prompt title value = { title; value }

(** [print_prompt i prompt] is a helper function that prints the prompt
    [prompt] with index [i + 1]*)
let print_prompt i prompt =
  ANSITerminal.printf [ ANSITerminal.Underlined ] "%d" (i + 1);
  ANSITerminal.print_string [] ("\t" ^ prompt.title ^ "\n")

(** [print_menu] is a helper function that prints a menu. *)
let print_menu title prompts =
  ANSITerminal.print_string [ ANSITerminal.Bold ] (title ^ "\n");
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
