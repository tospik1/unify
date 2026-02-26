(** shape.ml
    Structural description of values inferred from samples
*)

type t =
  | SNull
  | SBool
  | SInt
  | SFloat
  | SString
  | SArray of t
  | SObject of (string * t) list

(* -------- Inference from values -------- *)

let rec of_value (v : Value.t) : t =
  match v with
  | Value.VNull -> SNull
  | Value.VBool _ -> SBool
  | Value.VInt _ -> SInt
  | Value.VFloat _ -> SFloat
  | Value.VString _ -> SString
  | Value.VArray xs ->
      SArray
        (match xs with
         | [] -> SNull
         | x :: _ -> of_value x)
  | Value.VObject fields ->
      SObject
        (List.map
           (fun (k, v) -> (k, of_value v))
           fields)

(* -------- Serialization to Value -------- *)

let rec to_value (s : t) : Value.t =
  let open Value in
  match s with
  | SNull -> VString "null"
  | SBool -> VString "bool"
  | SInt -> VString "int"
  | SFloat -> VString "float"
  | SString -> VString "string"
  | SArray inner ->
      VObject
        [ "type", VString "array"
        ; "items", to_value inner
        ]
  | SObject fields ->
      VObject
        [ "type", VString "object"
        ; "fields",
          VObject
            (List.map
               (fun (k, v) -> (k, to_value v))
               fields)
        ]

(* -------- Pretty-printing -------- *)

let rec to_string (s : t) : string =
  match s with
  | SNull -> "null"
  | SBool -> "bool"
  | SInt -> "int"
  | SFloat -> "float"
  | SString -> "string"
  | SArray inner ->
      "array<" ^ to_string inner ^ ">"
  | SObject fields ->
      let inner =
        fields
        |> List.map (fun (k, v) -> k ^ ": " ^ to_string v)
        |> String.concat ", "
      in
      "{ " ^ inner ^ " }"
