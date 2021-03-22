(* type board = Array.make_matrix 10 10 (0,0) *)

(* LIST [(0, 0), (0, 1), ...] [(1, 0), (1, 1), ...] *)

type board = ()

type ship = ()

type hit_or_miss = ()

exception UnknownShip of ship
