open OUnit2

let battleship_test =
  [
    ( "sample test" >:: fun _ ->
      assert_equal ~printer:string_of_int 2 (1 + 1) );
  ]

let suite =
  "test suite for Battleship" >::: List.flatten [ battleship_test ]

let _ = run_test_tt_main suite
