type server_func = in_channel -> out_channel -> unit

val establish_server : server_func -> Unix.sockaddr -> unit
