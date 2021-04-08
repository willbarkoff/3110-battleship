(** selectlocation helps with the UI of our game.

    This module allows us to take in a certain input (based on what is
    requested) and call neccessary commands to transition to a new state
    in the game.*)

(** Places a ship onto a player's board and returns a new state *)
val place : State.t -> Battleship.ship -> State.t

(** Reads the position from the terminal and converts it to a position
    usable by the game *)
val read_pos : unit -> Battleship.position

(** Reads a direction from the terminal and converts it to a direction
    usable by the game *)
val read_orientation : unit -> Battleship.direction
