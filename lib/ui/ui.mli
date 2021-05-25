(** [show_player_board s] shows the current player's board. It returns
    [s] when the player is finished viewing the board.*)
val show_player_board : State.t -> State.t

(** [show_opponent_board s] shows the opposing player's board. It
    returns [s] when the player is finished viewing the board.*)
val show_opponent_board : State.t -> State.t

(** [attack s] prompts the play to attack, and updates the state [s]
    accordingly *)
val attack : State.t -> State.t

(** [finish s] Displays a screen explaining that the game is finished *)
val finish : State.t -> unit

(** [print_error_message] prints a message that something went wrong. *)
val print_error_message : unit -> unit
