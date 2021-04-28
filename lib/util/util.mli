(** Util provides utility functions used throughout the battleship
    implementation. *)

(** [pretty_string_of_list lst] returns a string representation of [lst]
    using standard english conventions.

    [pretty_string_of_list \["item"\]] returns ["item"].

    [pretty_string_of_list \["apples"; "bananas"\]] returns
    ["apples and bananas"]

    [pretty_string_of_list \["apples"; "oranges"; "grapes"; "bananas"\]]
    returns ["apples, oranges, grapes, and bananas"] *)
val pretty_string_of_list : string list -> string

(** [print_board_legend ()] prints a legend for the board. It includes
    symbolds to represent:

    - a hit
    - a miss
    - an untargeted ship
    - an untargeted part of water *)
val print_board_legend : unit -> unit

(** [print_lots_of_fancy_strings s] prints the list of strings and
    format styles s *)
val print_lots_of_fancy_strings :
  (ANSITerminal.style list * string) list -> unit

(** [plfs s] is an alias for [print_lots_of_fancy_strings s] *)
val plfs : (ANSITerminal.style list * string) list -> unit

(** [explode s] takes the string [s] and returns it as a list of chars.
    inspired by
    https://stackoverflow.com/questions/10068713/string-to-list-of-char *)
val explode : string -> char list

(** [implode lst] takes the list of characters [lst] and returns it as a
    string. *)
val implode : char list -> string

(** [get_terminal_size ()] returns the size of the current terminal,
    assuming it is a tty.*)
val get_terminal_size : unit -> int * int

(** [print_text_centered] is [print_lots_of_fancy_strings], but the text
    is printed centered in the terminal.

    @param preceding_newline determines if a preceding newline should be
    printed (defaults to [false])
    @param succeeding_newline determines if a succeeding newline should
    be printed (defaults to [true])*)
val print_text_centered :
  ?preceding_newline:bool ->
  ?succeeding_newline:bool ->
  (ANSITerminal.style list * string) list ->
  unit

(** [print_hr styles] prints a horizontal line across the screen with
    the specified styles, [styles].

    @param preceding_newline determines if a preceding newline should be
    printed (defaults to [false])
    @param succeeding_newline determines if a succeeding newline should
    be printed (defaults to [true])
    @param print_char is the character that should be printed (defaults
    to ['-'])*)
val print_hr :
  ?preceding_newline:bool ->
  ?succeeding_newline:bool ->
  ?print_char:char ->
  ANSITerminal.style list ->
  unit
