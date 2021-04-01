type t

val create_state : Person.t -> Person.t -> t

val advance_state : t -> int -> string -> t
