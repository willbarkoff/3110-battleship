open Sdl

let pretty_string_of_list lst =
  let rec pretty_string_asst acc oxford_comma = function
    | [] -> acc
    | [ h ] ->
        if oxford_comma then acc ^ ", and " ^ h else acc ^ " and " ^ h
    | h :: t ->
        pretty_string_asst
          ((if String.length acc > 1 then h ^ ", " else h) ^ acc)
          oxford_comma t
  in
  pretty_string_asst "" (List.length lst > 2) lst

let print_board_legend () =
  ANSITerminal.print_string [ ANSITerminal.red ] "H\t";
  ANSITerminal.print_string [] "Hit\t";
  ANSITerminal.print_string [ ANSITerminal.blue ] "•\t";
  ANSITerminal.print_string [] "Miss\t\n";
  ANSITerminal.print_string [] "•\t";
  ANSITerminal.print_string [] "Untargeted square\n\n"

let print_lots_of_fancy_strings strs =
  List.iter
    (fun (format, str) -> ANSITerminal.print_string format str)
    strs;
  flush stdout

let plfs = print_lots_of_fancy_strings

let explode s = List.init (String.length s) (String.get s)

let implode lst =
  String.init (List.length lst - 1) (fun i -> List.nth lst i)

let get_terminal_size () =
  ANSITerminal.save_cursor ();
  ANSITerminal.set_cursor 999999 999999;
  let pos = ANSITerminal.pos_cursor () in
  ANSITerminal.restore_cursor ();
  pos

let print_text_centered
    ?(preceding_newline = false)
    ?(succeeding_newline = true)
    plfs_spec =
  let length =
    List.fold_left (fun acc (_, t) -> acc + String.length t) 0 plfs_spec
  in
  let width, _ = get_terminal_size () in
  let whitespace = width - length in
  let padding = whitespace / 2 in
  let padding_str = String.make padding ' ' in
  if preceding_newline then print_newline ();
  print_string padding_str;
  plfs plfs_spec;
  print_string padding_str;
  if succeeding_newline then print_newline ()

let print_hr
    ?(preceding_newline = false)
    ?(succeeding_newline = true)
    ?(print_char = '-')
    styles =
  if preceding_newline then print_newline ();
  ANSITerminal.print_string styles
    (String.make (fst (get_terminal_size ())) print_char);
  if succeeding_newline then print_newline ()

(** This method is highly inspired by
    https://github.com/fccm/OCamlSDL2/blob/master/examples/ex_simple_wav.ml.
    Our method includes an extra [time] parameter that specifies how
    long to play the .wav audio file for. *)
let load_and_play_audio file time =
  (* Initialize a particular audio driver *)
  Sdl.init [ `AUDIO ];
  let wav_spec = Audio.new_audio_spec () in
  let wav_buffer, wav_len =
    Audio.load_wav ~filename:file ~spec:wav_spec
  in
  let device = Audio.open_audio_device_simple wav_spec in
  Audio.queue_audio device wav_buffer wav_len;
  Audio.unpause_audio_device device;
  Timer.delay ~ms:time;
  Audio.close_audio_device device;
  Audio.free_audio_spec wav_spec;
  Audio.free_wav wav_buffer;

  Sdl.quit ()
