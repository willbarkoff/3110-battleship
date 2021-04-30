type server_func = in_channel -> out_channel -> unit

val establish_vmem_server : server_func -> Unix.sockaddr -> unit
