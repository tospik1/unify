open Integrator_core
open Integrator_core.Decoder
open Integrator_core.Result

let http_method : Endpoint.http_method decoder =
 fun v ->
  match string v with
  | Ok "GET" -> Ok Endpoint.GET
  | Ok "POST" -> Ok POST
  | Ok "PUT" -> Ok PUT
  | Ok "PATCH" -> Ok PATCH
  | Ok "DELETE" -> Ok DELETE
  | Ok "OPTIONS" -> Ok OPTIONS
  | Ok "HEAD" -> Ok HEAD
  | Ok s ->
      Error
        (Error.decode_error
           ("Unknown HTTP method: " ^ s))
  | Error e -> Error e

let sample_decoder =
 fun v ->
  match field "status_code" int v with
  | Error e -> Error e
  | Ok status ->
      let body =
        match field "body" value v with
        | Ok b -> Some b
        | Error _ -> None
      in
      Ok (status, body)

let endpoint : Endpoint.t decoder =
 fun v ->
  match field "endpoint" string v with
  | Error e -> Error e
  | Ok url -> (
      match field "method" http_method v with
      | Error e -> Error e
      | Ok method_ -> (
          match field "samples" (list sample_decoder) v with
          | Error e -> Error e
          | Ok samples ->
              let status =
                match samples with
                | (s, _) :: _ -> Some s
                | [] -> None
              in

              let sample_response =
                match samples with
                | (_, Some v) :: _ -> Some v
                | _ -> None
              in

              let response_shape =
                match sample_response with
                | Some v -> Some (Shape.of_value v)
                | None -> None
              in

              Ok
                { Endpoint.method_
                ; url
                ; status
                ; response_shape
                ; sample_response
                }
        ))
