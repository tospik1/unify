(** endpoint.ml
    Represents a discovered API endpoint
*)

type http_method =
  | GET
  | POST
  | PUT
  | PATCH
  | DELETE
  | OPTIONS
  | HEAD

type t =
  { method_ : http_method
  ; url : string
  ; status : int option
  ; response_shape : Integrator_core.Shape.t option
  ; sample_response : Integrator_core.Value.t option
  }

let string_of_method = function
  | GET -> "GET"
  | POST -> "POST"
  | PUT -> "PUT"
  | PATCH -> "PATCH"
  | DELETE -> "DELETE"
  | OPTIONS -> "OPTIONS"
  | HEAD -> "HEAD"

let make
    ?status
    ?response_shape
    ?sample_response
    ~method_
    ~url
    ()
  =
  { method_
  ; url
  ; status
  ; response_shape
  ; sample_response
  }

(* -------- JSON encoding -------- *)

let to_value (e : t) : Integrator_core.Value.t =
  let open Integrator_core.Value in
  VObject
    (List.filter_map Fun.id
       [ Some ("method", VString (string_of_method e.method_))
       ; Some ("url", VString e.url)
       ; Option.map (fun s -> ("status", VInt s)) e.status
       ; Option.map
           (fun shape ->
              ("response_shape",
               Integrator_core.Shape.to_value shape))
           e.response_shape
       ; Option.map
           (fun v -> ("sample_response", v))
           e.sample_response
       ])
