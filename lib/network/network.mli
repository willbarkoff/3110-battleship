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

(** {3 Converters}

    Messages must be in the format of [bytes]. Therefore, we need to be
    able to convert every [message] to [bytes] and [bytes] to
    [message]s. Note that *)

(** [message_of_bytes m] converts the given message, [m], into [bytes]. *)
val bytes_of_message : message -> char list

(** [message_of_bytes b] converts the given bytes, [b], into a
    [message].

    @raise Invalid if [b] does not form a valid message *)
val message_of_bytes : char list -> message

(** {4 Parameter converters}

    These functions convert message parameters to bytes and vice versa.*)

(** [max_param_length] represents the maximum parameter length. *)
val max_param_length : int

(** [bytes_of_string s] returns the [bytes] representation of a
    [string], [s].

    @raise Invalid if [String.length s >= max_param_length]*)
val bytes_of_string : string -> char list

(** [bytes_of_bool b] returns the [char list] representation a [bool],
    [b].*)
val bytes_of_bool : bool -> char list

(** [bytes_of_board b] returns the [char list] representation of a
    [board], [b]*)
val bytes_of_board : Battleship.board -> char list

(** [bytes_of_position p] returns the [char list] representation of a
    [position], [p]*)
val bytes_of_position : Battleship.position -> char list

(** [bytes_of_attack_type a] returns the [char list] representation of
    an [attack_type], [a]*)
val bytes_of_attack_type : Battleship.attack_type -> char list

(** [string_of_bytes s] returns the [string] representation of the given
    [char list], [b]*)
val string_of_bytes : char list -> string

(** [bool_of_bytes b] returns the [bool] representation of the given
    [char list], b.

    @raise Invalid if [b] cannot be represented as a [bool].*)
val bool_of_bytes : char list -> bool

(** [board_of_bytes b] returns the [board] representation of the given
    [char list], [b].

    @raise Invalid if [b] cannot be represented as a [board].*)
val board_of_bytes : char list -> Battleship.board

(** [position_of_bytes b] returns the [Battleship.position]
    representation of the given [char list], [b].

    @raise Invalid if [b] cannot be represented as a
    [Battleship.position].*)
val position_of_bytes : char list -> Battleship.position

(** [attack_type_of_bytes b] returns the [Battleship.attack_type]
    representation of the given [char list], [b].

    @raise Invalid if [b] cannot be represented as a
    [Battleship.attack_type].*)
val attack_type_of_bytes : char list -> Battleship.attack_type

(** {2 Listeners} *)

(** a [responder] is a function that sends a message *)
type responder = message -> bool

(** a [listener] is a function that listens for messages.contents

    @return [true] if everything went well, [false] otherwise.*)
type listener = message -> responder -> bool

(** [listen_and_serve p l] is a function that listens on port [p] and
    handles messages with the [listener] [l].*)
val listen_and_serve : int -> listener -> unit
