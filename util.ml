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
