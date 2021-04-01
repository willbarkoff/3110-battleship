open OUnit2
open Battleship

let battleship_test =
  [ (* TODO: add tests for the Battleship module here *) ]

let suite =
  "test suite for Battleship" >::: List.flatten [ battleship_test ]

let _ = run_test_tt_main suite
