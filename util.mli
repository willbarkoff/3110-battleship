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
