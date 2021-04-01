type t

val create_state : Person.player -> Person.player -> t

val advance_state : t -> string -> t

(** [get_current_player state] gets the current player in the state. *)
val get_current_player : t -> Person.player

val place_ship : t -> Battleship.position -> Battleship.ship -> t
