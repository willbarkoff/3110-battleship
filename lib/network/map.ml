(** AF: [[(k1, v1); (k2, v2); ...; (kn, vn)]] is the map {k1:v1, k2:v2,
    ..., kn:vn}. If a key appears more than once in the list, then in
    the map it is bound to the left-most occurrence in the list. For
    example, [[(k, v1); (k, v2)]] represents the map {k:v1}. The empty
    list represents the empty map. RI: none. *)
type ('k, 'v) t = ('k * 'v) list

(** Efficiency: O(1) *)
let insert k v m = m := (k, v) :: !m

(** Efficiency: O(n) *)
let find k m = List.assoc_opt k !m

let mem k m = List.mem_assoc k !m

(** Efficiency: O(n) *)
let remove k lst = lst := List.filter (fun (k', _) -> k <> k') !lst

let empty () : ('k, 'v) t ref = ref []

(** Efficiency: O(1) *)
let of_list lst = !lst

(* * [keys m] is a set-like list of the keys in [m]. Efficiency: O(n log
   n). *)
let keys m = !m |> List.map fst |> List.sort_uniq Stdlib.compare

(** [binding m k] is [(k, v)], where [v] is the value that [k] binds in
    [m]. Requires: [k] is a key in [m]. Efficiency: O(n) *)
(* let binding m k = (k, List.assoc k m) *)

(** Efficiency: O(n^2) *)
(* let bindings m = List.map (binding m) (keys m) *)
(* [keys m] is O(n log n) and produces a list of length O(n). [binding
   m] is O(1) to just partially apply. Calling [binding m] on every
   element of [keys m] is O(n) work for each of O(n) elements. Total:
   O(n log n) + O(n)*O(n), which is O(n^2). *)
