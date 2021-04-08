(** menu handles all the UI of the game, including converting input from
    the user to information the game can use. *)

(** ['a prompt] represents a menu item of type ['a]. *)
type 'a prompt

(** [prompt title value] creates a menu item called [title] with the
    value [value] *)
val prompt : string -> 'a -> 'a prompt

(** [show_menu title prompts] shows the menu with title [title] and
    prompts [prompts]. *)
val show_menu : string -> 'a prompt list -> 'a

(** [show_menu title prompts handler] shows the menu with title [title]
    and prompts [prompts] and passes the invalid input to [handler] on
    an invalid input.*)
val show_menu_failure : string -> 'a prompt list -> (string -> 'a) -> 'a
