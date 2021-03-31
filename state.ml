(* type t = { player1 : Person.t; player2 : Person.t; }

   let create_state person1 person2 = { player1 = person1; player2 =
   person2 }

   let advance_state current_state player input = let next_action =
   Person.parse_input input in let new_board = match next_action with |
   Place (ship_string * position * direction) -> Battleship.place_ship
   (Battleship.create_ship ship_string) position player.player_board
   direction | Attack (position) -> Battleship.attack position
   player.player_board | Quit in {player1 = {player_board = new_board;
   opponent_board = current_state.player2.player_board}; player2 =
   {player_board = current_state.player2.player_board; opponent_board =
   new_board}} *)
