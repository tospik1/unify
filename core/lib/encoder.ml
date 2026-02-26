(** encoder.ml
    Safe encoding from typed OCaml values into Value.t.
    This is the mirror of decoder.ml.
*)

open Value

type 'a encoder = 'a -> Value.t

(* ---------- primitive encoders ---------- *)

let null : unit encoder =
 fun () -> VNull

let bool : bool encoder =
 fun b -> VBool b

let int : int encoder =
 fun i -> VInt i

let float : float encoder =
 fun f -> VFloat f

let string : string encoder =
 fun s -> VString s

(* ---------- composite encoders ---------- *)

let list (e : 'a encoder) : 'a list encoder =
 fun xs ->
  xs
  |> List.map e
  |> fun vs -> VArray vs

let option (e : 'a encoder) : 'a option encoder =
 fun opt ->
  match opt with
  | None -> VNull
  | Some v -> e v

let field (name : string) (e : 'a encoder) (v : 'a) : string * Value.t =
  (name, e v)

let object_ (fields : (string * Value.t) list) : Value.t =
  VObject fields

(* ---------- combinators ---------- *)

let map (f : 'a -> 'b) (e : 'b encoder) : 'a encoder =
 fun v -> e (f v)

(* ---------- helpers for records ---------- *)

let record (fields : 'a -> (string * Value.t) list) : 'a encoder =
 fun v -> VObject (fields v)
