(** error.ml
    Structured error model for the Integrator core.
*)

type location =
  | Unknown
  | Url of string
  | Endpoint of string
  | Field of string
  | Index of int

type severity =
  | Info
  | Warning
  | Error
  | Fatal

type kind =
  | Decode_error
  | Type_mismatch
  | Missing_field
  | Invalid_value
  | Unsupported_format
  | Network_error
  | Timeout
  | Internal_error

type t = {
  kind : kind;
  severity : severity;
  message : string;
  location : location;
  context : (string * string) list;
}

(* ---------- Constructors ---------- *)

let make
    ?(severity = Error)
    ?(location = Unknown)
    ?(context = [])
    kind
    message
  =
  {
    kind;
    severity;
    message;
    location;
    context;
  }

let decode_error ?location ?context message =
  make ?location ?context Decode_error message

let type_mismatch ?location ?context expected actual =
  make
    ?location
    ?context
    Type_mismatch
    (Printf.sprintf "Type mismatch: expected %s, got %s" expected actual)

let missing_field ?location ?context field =
  make
    ?location
    ?context
    Missing_field
    (Printf.sprintf "Missing required field: %s" field)

let invalid_value ?location ?context message =
  make
    ?location
    ?context
    Invalid_value
    message

let unsupported_format ?location ?context format =
  make
    ?location
    ?context
    Unsupported_format
    (Printf.sprintf "Unsupported format: %s" format)

let network_error ?location ?context message =
  make
    ?location
    ?context
    Network_error
    message

let timeout ?location ?context () =
  make
    ?location
    ?context
    Timeout
    "Request timed out"

let internal_error ?location ?context message =
  make
    ~severity:Fatal
    ?location
    ?context
    Internal_error
    message

(* ---------- Pretty printing ---------- *)

let string_of_location = function
  | Unknown -> "unknown"
  | Url u -> "url:" ^ u
  | Endpoint e -> "endpoint:" ^ e
  | Field f -> "field:" ^ f
  | Index i -> "index:" ^ string_of_int i

let string_of_severity = function
  | Info -> "info"
  | Warning -> "warning"
  | Error -> "error"
  | Fatal -> "fatal"

let string_of_kind = function
  | Decode_error -> "decode_error"
  | Type_mismatch -> "type_mismatch"
  | Missing_field -> "missing_field"
  | Invalid_value -> "invalid_value"
  | Unsupported_format -> "unsupported_format"
  | Network_error -> "network_error"
  | Timeout -> "timeout"
  | Internal_error -> "internal_error"

let to_string (e : t) =
  let ctx =
    match e.context with
    | [] -> ""
    | lst ->
        lst
        |> List.map (fun (k, v) -> k ^ "=" ^ v)
        |> String.concat ", "
        |> fun s -> " [" ^ s ^ "]"
  in
  Printf.sprintf
    "%s (%s) at %s: %s%s"
    (string_of_kind e.kind)
    (string_of_severity e.severity)
    (string_of_location e.location)
    e.message
    ctx
