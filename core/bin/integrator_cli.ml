open Integrator_core
open Integrator_core_domain
open Integrator_core_export

let () =
  if Array.length Sys.argv <> 2 then (
    prerr_endline "Usage: integrator <crawl.json>";
    exit 1
  );

  let input = Sys.argv.(1) in

  let value =
    Yojson.Safe.from_file input
    |> Json.of_yojson
  in

  match Crawl_decoder.crawl value with
  | Error e ->
      prerr_endline (Error.to_string e);
      exit 1
  | Ok crawl ->
      let openapi = Openapi.of_crawl crawl in
      Json.to_yojson openapi
      |> Yojson.Safe.pretty_to_string
      |> print_endline
