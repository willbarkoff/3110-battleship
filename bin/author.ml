let hours_worked = 75

let _ =
  if hours_worked >= 0 then
    Util.plfs
      [
        ([ ANSITerminal.green ], "✓ ");
        ([], "You spent ");
        ([ ANSITerminal.Bold ], string_of_int hours_worked ^ " hours");
        ([], " on this submission.\n");
      ]
  else
    Util.plfs
      [
        ([ ANSITerminal.red ], "X ");
        ([], "The variable ");
        ([ ANSITerminal.Bold ], "hours_worked");
        ([], " is unset. Set it before submitting.\n");
      ];
  exit 1
