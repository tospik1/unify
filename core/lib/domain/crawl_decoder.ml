open Integrator_core
open Integrator_core.Decoder
open Integrator_core.Result

let crawl : Crawl.t decoder =
 fun v ->
  let* base_url = field "base_url" string v in
  let* endpoints =
    field "endpoints"
      (list Endpoint_decoder.endpoint)
      v
  in
  Ok
    { Crawl.base_url
    ; endpoints
    ; discovered_at = Unix.time ()
    }
