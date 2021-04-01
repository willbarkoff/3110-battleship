type t = {
  player1 : Person.player;
  player2 : Person.player;
  current_player : int;
}

let create_state person1 person2 =
  { player1 = person1; player2 = person2; current_player = 0 }

let get_current_player s =
  if s.current_player = 1 then s.player1 else s.player2

let toggle_player s =
  { s with current_player = (s.current_player + 1) mod 2 }

let advance_state current_state input =
  assert (
    current_state.current_player = 0 || current_state.current_player = 1);
  let current_player =
    if current_state.current_player = 0 then current_state.player1
    else current_state.player2
  in
  let next_action = Person.parse_input input in
  let () =
    match next_action with
    | Place (ship_string, position, direction) ->
        Battleship.place_ship
          (Battleship.create_ship ship_string)
          position
          (Person.get_board current_player)
          direction
    | Attack position ->
        Battleship.attack
          (Person.get_ships current_player)
          position
          (Battleship.create_ship "cruiser")
          (Person.get_board current_player)
    | Quit -> ()
  in
  {
    current_state with
    current_player = (current_state.current_player + 1) mod 2;
  }

let place_ship state pos ship = failwith "TODO"
