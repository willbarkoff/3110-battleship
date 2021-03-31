type t = {
  player1 : Person.t;
  player2 : Person.t;
}

let create_state person1 person2 =
  { player1 = person1; player2 = person2 }

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
  if player_check = 1 then
    {
      player1 =
        {
          player =
            {
              board = in_player.player.board;
              ships = in_player.player.ships;
            };
          opponent =
            {
              board = other_player.player.board;
              ships = other_player.player.ships;
            };
        };
      player2 =
        {
          player =
            {
              board = other_player.player.board;
              ships = other_player.player.ships;
            };
          opponent =
            {
              board = in_player.player.board;
              ships = in_player.player.ships;
            };
        };
    }
  else
    {
      player1 =
        {
          player =
            {
              board = other_player.player.board;
              ships = other_player.player.ships;
            };
          opponent =
            {
              board = in_player.player.board;
              ships = in_player.player.ships;
            };
        };
      player2 =
        {
          player =
            {
              board = in_player.player.board;
              ships = in_player.player.ships;
            };
          opponent =
            {
              board = other_player.player.board;
              ships = other_player.player.ships;
            };
        };
    }
