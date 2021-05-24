type player = {
  board : Battleship.board;
  ships : Battleship.ship list;
}

let create_player board ships = { board; ships }

let get_board p = p.board

let get_ships p = p.ships
