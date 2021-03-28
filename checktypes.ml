module type BattleshipSig = sig
  type board

  type ship

  type block_tile

  type ships

  type position

  type direction

  type attack_type

  type block_occupation

  val board : unit -> board

  val place_ship : ship -> position -> board -> direction -> unit

  val attack : ships -> position -> board -> board

  val finished_game : ships -> bool
end

module BattleshipCheck : BattleshipSig = Battleship
