(** An instance of the game, Battleship

    This module stores a state of the game, defines the methods to
    transition to a new state, and checks if the game is complete. *)

(** A instance of the game *)
type t

(** [create_state person1 person2] creates a state of type [t] *)
val create_state : Person.player -> Person.player -> t

(** [get_current_player state] gets the current player in the state. *)
val get_current_player : t -> Person.player

(** [get_opponent state] gets the opponent player in the state. *)
val get_opponent : t -> Person.player

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

(** [finished_game t] determines if the current game, [t] is over. *)
val finished_game : t -> bool

(** [attack t pos] performs an attack on the given position, [pos]. *)
val attack : t -> Battleship.position -> t
