type t = {
  player1 : Person.player;
  player2 : Person.player;
  current_player : int;
}

let create_state person1 person2 =
  { player1 = person1; player2 = person2; current_player = 0 }

let get_current_player s =
  if s.current_player = 1 then s.player1 else s.player2

let get_current_player_number s = s.current_player

let get_opponent s =
  if s.current_player = 0 then s.player1 else s.player2

let toggle_player s =
  { s with current_player = (s.current_player + 1) mod 2 }

let place_ship state pos ship dir ?(debug = false) =
  let board = get_current_player state |> Person.get_board in
  Battleship.place_ship ship pos board dir debug;
  state

let attack s pos ?(debug = false) =
  Battleship.attack pos (get_opponent s |> Person.get_board) debug;
  s

let finished_game s =
  get_opponent s |> Person.get_board |> Battleship.finished_game
