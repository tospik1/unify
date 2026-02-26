(** value.ml
    Universal, schema-less data representation.
*)

type t =
  | VNull
  | VBool of bool
  | VInt of int
  | VFloat of float
  | VString of string
  | VArray of t list
  | VObject of (string * t) list

(* Backward-compatible alias *)
type value = t

let rec to_string = function
  | VNull -> "null"
  | VBool b -> string_of_bool b
  | VInt i -> string_of_int i
  | VFloat f -> string_of_float f
  | VString s -> "\"" ^ s ^ "\""
  | VArray xs ->
      xs
      |> List.map to_string
      |> String.concat ", "
      |> fun s -> "[" ^ s ^ "]"
  | VObject fields ->
      fields
      |> List.map (fun (k, v) -> k ^ ": " ^ to_string v)
      |> String.concat ", "
      |> fun s -> "{" ^ s ^ "}"
