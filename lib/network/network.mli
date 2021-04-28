(** Network holds networking related features for the battleship game. *)

(** {1 Message} *)

(** [message] represents the type of message sent to or from the server.*)
type message =
  | GetGamecode
      (** [GetGamecode] represents a request from the client to the
          server for a gamecode, used for joining the game.*)
  | Gamecode of string
      (** [Gamecode s] represents a response from the server with the
          gamecode, [s], assigned to the new game. *)
  | Join of string
      (** [Join s] represents the request to the server to join the game
          with the given code, [s]. *)
  | Joined of bool
      (** [Joined success] represents the confirmation response from the
          server of the request to join the game. If [success] is
          [true], then the game was joined successfully. Otherwise, the
          game was not joined successfully.*)
  | Sendboard of Battleship.board
      (** [Sendboard b] sends the given board, [b] to the server.*)
  | Movefirst of bool
      (** [Movefirst first] is a response from the server once both
          boards have been received. If [first] is true, this player
          moves first.*)
  | Move of Battleship.position
      (** [Move pos] represents the request to attack a specific
          position, [pos].*)
  | MoveResult of Battleship.position * Battleship.attack_type
      (** [MoveResult (pos, res)] represents the result of a move. It is
          sent only if the game does not end as a result of the move.
          [pos] represents the position of the move, and [res]
          represents the result of the move, either a [Battleship.Hit]
          or a [Battleship.Miss]*)
  | Gameend of bool
      (** [Gameend win] is sent if the previous move resulted in the end
          of the game. [win] is [true] if the player has won, and
          [false] if the player has lost.*)
  | Error
      (** [Error] is a message from the server that means that something
          went wrong.*)

(** {1 Listener} *)

(** A [recipient] is someone who should receive a message, either the
    [Sender], or the person who the [Sender] is playing against, the
    [Opponent].*)
type recipient =
  | Sender
  | Opponent

(** A [broadcast] designates a recipient and a message.*)
type broadcast

(** [recipient b] gets the recipient from the broadcast, [b] *)
val recipient : broadcast -> recipient

(** [message b] gets the message from the broadcast, [b] *)
val message : broadcast -> message

(** a [listener] is a function that listens for messages, manages state,
    and determines how to respond to them, and updates the state
    accordingly.

    @return [s * b] where [s] is the updated game state, and [b] is a
    list of broadcasts to send. *)
val listener : State.t -> message -> State.t * broadcast list

(** [listen_and_serve p l] is a function that listens on port [p] and
    handles messages with the [listener] [l].*)
val listen_and_serve : int -> unit

(** [network_debug p] provides a REPL for testing the network
    interfaces. It tests them on port [p]. *)
val network_debug : int -> unit
