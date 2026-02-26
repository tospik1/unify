(** json.ml
    Bridge between Yojson.Safe and Value.t
    Supports only standard JSON constructs.
*)

open Value

module J = Yojson.Safe

let rec of_yojson (j : J.t) : Value.t =
  match j with
  | `Null -> VNull
  | `Bool b -> VBool b
  | `Int i -> VInt i
  | `Intlit s -> VInt (int_of_string s)
  | `Float f -> VFloat f
  | `String s -> VString s
  | `List xs ->
      VArray (List.map of_yojson xs)
  | `Assoc fields ->
      fields
      |> List.map (fun (k, v) -> (k, of_yojson v))
      |> fun fs -> VObject fs

let rec to_yojson (v : Value.t) : J.t =
  match v with
  | VNull -> `Null
  | VBool b -> `Bool b
  | VInt i -> `Int i
  | VFloat f -> `Float f
  | VString s -> `String s
  | VArray xs ->
      `List (List.map to_yojson xs)
  | VObject fields ->
      fields
      |> List.map (fun (k, v) -> (k, to_yojson v))
      |> fun fs -> `Assoc fs
