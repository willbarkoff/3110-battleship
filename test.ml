open OUnit2
open Battleship

let attack_test name ships position board expected_output =
  name >:: fun _ ->
  assert_equal expected_output (attack ships position board)

let battleship_test =
  [ (* TODO: add tests for the Battleship module here *) ]

let suite =
  "test suite for Battleship" >::: List.flatten [ battleship_test ]

let _ = run_test_tt_main suite
