module type BattleshipSig = sig
  type ship_type =
    | Carrier
    | Battleship
    | Cruiser
    | Submarine
    | Destroyer

  type board

  type ship

  type block_tile

  type ships

  type position

  type direction =
    | Left
    | Right
    | Up
    | Down

  type attack_type =
    | Hit
    | Miss
    | Untargeted

  type block_occupation

  exception ShipCollision

  val board : unit -> board

  val place_ship : ship -> position -> board -> direction -> unit

  val attack : ships -> position -> board -> unit

  val finished_game : ships -> bool

  val print_board : board -> unit
end

module type PersonSig = sig
  type t

  type position = char * int

  type action =
    | Place of string * position
    | Attack of position
    | Quit

  exception Empty

  exception Malformed

  val parse_input : string -> action
end

module BattleshipCheck : BattleshipSig = Battleship

module PersonCheck : PersonSig = Person
