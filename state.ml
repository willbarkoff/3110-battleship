type t = {
  player1 : Person.t;
  player2 : Person.t;
}

let create_state person1 person2 =
  { player1 = person1; player2 = person2 }

let assign_player (player_A : Person.t) (player_B : Person.t) =
  {
    player1 =
      {
        player =
          {
            board = player_A.player.board;
            ships = player_A.player.ships;
          };
        opponent =
          {
            board = player_B.player.board;
            ships = player_B.player.ships;
          };
      };
    player2 =
      {
        player =
          {
            board = player_B.player.board;
            ships = player_B.player.ships;
          };
        opponent =
          {
            board = player_A.player.board;
            ships = player_A.player.ships;
          };
      };
  }

let advance_state current_state (player_check : int) input =
  assert (player_check = 1 || player_check = 2);
  let in_player =
    if player_check = 1 then current_state.player1
    else current_state.player2
  in
  let other_player =
    if player_check = 1 then current_state.player2
    else current_state.player1
  in
  let next_action = Person.parse_input input in
  let () =
    match next_action with
    | Place (ship_string, position, direction) ->
        Battleship.place_ship
          (Battleship.create_ship ship_string)
          position in_player.player.board direction
    | Attack position ->
        Battleship.attack in_player.player.ships position
          (Battleship.create_ship "cruiser")
          in_player.player.board
    | Quit -> ()
  in
  if player_check = 1 then assign_player in_player other_player
  else assign_player other_player in_player
