open Unix

(* The code in this file is highly inspired by the Unix library in
   OCaml's core. It has a few modifications to enable shared memory of
   forks at runtime.contents
   https://github.com/ocaml/ocaml/blob/trunk/otherlibs/unix/unix.ml *)

type server_func = in_channel -> out_channel -> unit

let _exit = exit

let rec accept_non_intr s =
  try accept ~cloexec:true s
  with Unix_error (EINTR, _, _) -> accept_non_intr s

let rec waitpid_non_intr pid =
  try waitpid [] pid
  with Unix_error (EINTR, _, _) -> waitpid_non_intr pid

(* external spawn : string -> string array -> string array option ->
   bool -> int array -> int = "unix_spawn" *)

let establish_server server_fun sockaddr =
  let sock =
    socket ~cloexec:true (domain_of_sockaddr sockaddr) SOCK_STREAM 0
  in
  setsockopt sock SO_REUSEADDR true;
  bind sock sockaddr;
  listen sock 5;
  while true do
    let s, _caller = accept_non_intr sock in
    (* The "double fork" trick, the process which calls server_fun will
       not leave a zombie process *)
    Thread.create
      (fun _ ->
        let inchan = in_channel_of_descr s in
        let outchan = out_channel_of_descr s in
        server_fun inchan outchan;
        (* Do not close inchan nor outchan, as the server_fun could have
           done it already, and we are about to exit anyway (PR#3794) *)
        exit 0)
      ()
    |> ignore
    (* Reclaim the child *)
  done
