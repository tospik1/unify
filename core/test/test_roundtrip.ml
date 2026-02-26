open Integrator_core

let assert_ok = function
  | Ok _ -> ()
  | Error e -> failwith (Error.to_string e)

let () =
  (* Encoder / Decoder roundtrip *)
  let v =
    Value.VObject [
      ("id", Value.VInt 1);
      ("name", Value.VString "Alice");
      ("active", Value.VBool true);
    ]
  in

  let open Decoder in
  let id = field "id" int v in
  assert_ok id;

  (* JSON roundtrip *)
  let json = Json.to_yojson v in
  let v' = Json.of_yojson json in
  assert (v = v');

  (* Shape inference *)
  let s = Shape.of_value v in
  Printf.printf "Shape: %s\n" (Shape.to_string s)
