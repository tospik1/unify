(** result.ml
    Domain-specific result type and combinators for the Integrator core.
    No exceptions. Errors are always explicit and structured.
*)

type 'a t = ('a, Error.t) result

(* ---------- Constructors ---------- *)

let ok (v : 'a) : 'a t =
  Ok v

let error (e : Error.t) : 'a t =
  Error e

(* ---------- Basic combinators ---------- *)

let map (r : 'a t) (f : 'a -> 'b) : 'b t =
  match r with
  | Ok v -> Ok (f v)
  | Error e -> Error e

let map_error (r : 'a t) (f : Error.t -> Error.t) : 'a t =
  match r with
  | Ok v -> Ok v
  | Error e -> Error (f e)

let bind (r : 'a t) (f : 'a -> 'b t) : 'b t =
  match r with
  | Ok v -> f v
  | Error e -> Error e

let ( let* ) = bind
let ( let+ ) r f = map r f

(* ---------- Error enrichment ---------- *)

let with_location (loc : Error.location) (r : 'a t) : 'a t =
  map_error r (fun e -> { e with location = loc })

let with_context (ctx : (string * string) list) (r : 'a t) : 'a t =
  map_error r (fun e -> { e with context = e.context @ ctx })

let with_severity (severity : Error.severity) (r : 'a t) : 'a t =
  map_error r (fun e -> { e with severity })

(* ---------- Lifting helpers ---------- *)

let from_option
    ?location
    ?context
    ~error
    (opt : 'a option)
  : 'a t
  =
  match opt with
  | Some v -> Ok v
  | None ->
      Error (
        Error.make
          ?location
          ?context
          error
          "Expected value, got none"
      )

let from_bool
    ?location
    ?context
    ~error
    (cond : bool)
  : unit t
  =
  if cond then Ok ()
  else
    Error (
      Error.make
        ?location
        ?context
        error
        "Condition failed"
    )

(* ---------- Traversal ---------- *)

let rec all (lst : 'a t list) : 'a list t =
  match lst with
  | [] -> Ok []
  | x :: xs ->
      let* v = x in
      let* vs = all xs in
      Ok (v :: vs)

let rec traverse (lst : 'a list) (f : 'a -> 'b t) : 'b list t =
  match lst with
  | [] -> Ok []
  | x :: xs ->
      let* v = f x in
      let* vs = traverse xs f in
      Ok (v :: vs)

(* ---------- Folding ---------- *)

let fold_left
    (f : 'acc -> 'a -> 'acc t)
    (init : 'acc)
    (lst : 'a list)
  : 'acc t
  =
  let rec loop acc = function
    | [] -> Ok acc
    | x :: xs ->
        let* acc' = f acc x in
        loop acc' xs
  in
  loop init lst

(* ---------- Utilities ---------- *)

let is_ok = function
  | Ok _ -> true
  | Error _ -> false

let is_error = function
  | Ok _ -> false
  | Error _ -> true

let get_or_default default = function
  | Ok v -> v
  | Error _ -> default
