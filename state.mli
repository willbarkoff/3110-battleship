type t

val create_state : Person.player -> Person.player -> t

val advance_state : t -> string -> t

(** [get_current_player state] gets the current player in the state. *)
val get_current_player : t -> Person.player

(** [place_ship s position ship direction] places a ship in the given
    direction for the current player.*)
val place_ship :
  t ->
  Battleship.position ->
  Battleship.ship ->
  Battleship.direction ->
  t

(** [toggle_player state] toggles the player in the given state*)
val toggle_player : t -> t
