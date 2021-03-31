(** [pretty_string_of_list lst] returns a string representation of [lst]
    using standard english conventions.

    [pretty_string_of_list \["item"\]] returns ["item"].

    [pretty_string_of_list \["apples"; "bananas"]] returns ["apples and
    bananas"]

    [pretty_string_of_list ["apples"; "oranges"; "grapes"; "bananas"]]
    returns ["apples, oranges, grapes, and bananas"]*)
val pretty_string_of_list : string list -> string
