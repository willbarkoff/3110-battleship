module type BattleshipSig = sig
  type board

  type ship

  type hit_or_miss

  exception UnknownShip of ship
end

module BattleshipCheck : BattleshipSig = Battleship
