(** [('k, 'v) t] is the type of maps that bind keys of type ['k] to
    values of type ['v]. *)
type ('k, 'v) t

(** [insert k v m] is the same map as [m], but with an additional
    binding from [k] to [v]. If [k] was already bound in [m], that
    binding is replaced by the binding to [v] in the new map. *)
val insert : 'k -> 'v -> ('k, 'v) t ref -> unit

(** [find k m] is [Some v] if [k] is bound to [v] in [m], and [None] if
    not. *)
val find : 'k -> ('k, 'v) t ref -> 'v option

val mem : 'k -> ('k, 'v) t ref -> bool

(** [remove k m] is the same map as [m], but without any binding of [k].
    If [k] was not bound in [m], then the map is unchanged. *)
val remove : 'k -> ('k, 'v) t ref -> unit

(** [empty] is the empty map *)
val empty : unit -> ('k, 'v) t ref

(** [of_list lst] is a map containing the same bindings as association
    list [lst]. Requires: [lst] does not contain any duplicate keys. *)
val of_list : ('k * 'v) list ref -> ('k, 'v) t

(** [bindings m] is an association list containing the same bindings as
    [m]. There are no duplicate keys in the list. *)
(* val bindings : ('k, 'v) t -> ('k * 'v) list *)
