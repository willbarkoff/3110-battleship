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
            board = Person.get_board (Person.get_player player_A);
            ships = Person.get_ships (Person.get_player player_A);
          };
        opponent =
          {
            board = Person.get_board (Person.get_player player_B);
            ships = Person.get_ships (Person.get_player player_B);
          };
      };
    player2 =
      {
        player =
          {
            board = Person.get_board (Person.get_player player_B);
            ships = Person.get_ships (Person.get_player player_B);
          };
        opponent =
          {
            board = Person.get_board (Person.get_player player_A);
            ships = Person.get_ships (Person.get_player player_A);
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
          position
          (Person.get_board (Person.get_player in_player))
          direction
    | Attack position ->
        Battleship.attack
          (Person.get_ships (Person.get_player in_player))
          position
          (Battleship.create_ship "cruiser")
          (Person.get_board (Person.get_player in_player))
    | Quit -> ()
  in
  if player_check = 1 then assign_player in_player other_player
  else assign_player other_player in_player
