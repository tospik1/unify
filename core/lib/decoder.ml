(** decoder.ml
    Decoder combinators for Value.t → typed domain values
*)

type 'a decoder = Value.t -> ('a, Error.t) result

(* ---------- Helpers ---------- *)

let actual_type = function
  | Value.VNull -> "null"
  | Value.VBool _ -> "bool"
  | Value.VInt _ -> "int"
  | Value.VFloat _ -> "float"
  | Value.VString _ -> "string"
  | Value.VArray _ -> "array"
  | Value.VObject _ -> "object"

(* ---------- Primitive decoders ---------- *)

let value : Value.t decoder =
 fun v -> Ok v

let int : int decoder = function
  | Value.VInt i -> Ok i
  | v ->
      Error
        (Error.type_mismatch
           "int"
           (actual_type v))

let bool : bool decoder = function
  | Value.VBool b -> Ok b
  | v ->
      Error
        (Error.type_mismatch
           "bool"
           (actual_type v))

let string : string decoder = function
  | Value.VString s -> Ok s
  | v ->
      Error
        (Error.type_mismatch
           "string"
           (actual_type v))

(* ---------- Structured decoders ---------- *)

let list (d : 'a decoder) : 'a list decoder = function
  | Value.VArray xs ->
      let rec aux acc = function
        | [] -> Ok (List.rev acc)
        | x :: xs -> (
            match d x with
            | Ok v -> aux (v :: acc) xs
            | Error e -> Error e)
      in
      aux [] xs
  | v ->
      Error
        (Error.type_mismatch
           "array"
           (actual_type v))

let field (name : string) (d : 'a decoder) : 'a decoder =
 fun v ->
  match v with
  | Value.VObject fields -> (
      match List.assoc_opt name fields with
      | Some v' -> d v'
      | None ->
          Error
            (Error.missing_field
               ~location:(Field name)
               name))
  | v ->
      Error
        (Error.type_mismatch
           "object"
           (actual_type v))

(* ---------- Combinators ---------- *)

let map (f : 'a -> 'b) (d : 'a decoder) : 'b decoder =
 fun v ->
  match d v with
  | Ok x -> Ok (f x)
  | Error e -> Error e

let bind (d : 'a decoder) (f : 'a -> 'b decoder) : 'b decoder =
 fun v ->
  match d v with
  | Ok x -> f x v
  | Error e -> Error e

let optional (d : 'a decoder) : 'a option decoder =
 fun v ->
  match d v with
  | Ok x -> Ok (Some x)
  | Error _ -> Ok None

(* ---------- Syntax sugar ---------- *)

module Let_syntax = struct
  let ( let* ) = bind
end
