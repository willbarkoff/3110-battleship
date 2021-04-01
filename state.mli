type t

val create_state : Person.player -> Person.player -> t

val advance_state : t -> int -> string -> t
