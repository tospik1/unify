open Integrator_core
open Integrator_core_domain

let schema_of_shape (s : Shape.t) : Value.t =
  let rec aux = function
    | Shape.SNull ->
        Value.VObject [ ("type", Value.VString "null") ]
    | Shape.SBool ->
        Value.VObject [ ("type", Value.VString "boolean") ]
    | Shape.SInt ->
        Value.VObject [ ("type", Value.VString "integer") ]
    | Shape.SFloat ->
        Value.VObject [ ("type", Value.VString "number") ]
    | Shape.SString ->
        Value.VObject [ ("type", Value.VString "string") ]
    | Shape.SArray inner ->
        Value.VObject
          [
            ("type", Value.VString "array");
            ("items", aux inner);
          ]
    | Shape.SObject fields ->
        Value.VObject
          [
            ("type", Value.VString "object");
            ( "properties",
              Value.VObject
                (List.map
                   (fun (k, v) -> (k, aux v))
                   fields) );
          ]
  in
  aux s

let endpoint (e : Endpoint.t) : string * Value.t =
  let path = e.url in

  let method_name =
    Endpoint.string_of_method e.method_
    |> String.lowercase_ascii
  in

  let response_schema =
    match e.response_shape with
    | Some s -> schema_of_shape s
    | None -> Value.VObject []
  in

  ( path,
    Value.VObject
      [
        ( method_name,
          Value.VObject
            [
              ( "responses",
                Value.VObject
                  [
                    ( "200",
                      Value.VObject
                        [
                          ("description", Value.VString "Success");
                          ( "content",
                            Value.VObject
                              [
                                ( "application/json",
                                  Value.VObject
                                    [ ("schema", response_schema) ] );
                              ] );
                        ] );
                  ] );
            ] );
      ] )

let of_crawl (c : Crawl.t) : Value.t =
  Value.VObject
    [
      ("openapi", Value.VString "3.0.0");
      ( "info",
        Value.VObject
          [
            ("title", Value.VString "Discovered API");
            ("version", Value.VString "0.1.0");
          ] );
      ( "paths",
        Value.VObject
          (List.map endpoint c.endpoints) );
    ]
