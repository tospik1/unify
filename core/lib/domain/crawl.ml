type t =
  { base_url : string
  ; endpoints : Endpoint.t list
  ; discovered_at : float
  }

let make ~base_url ~endpoints ~discovered_at =
  { base_url
  ; endpoints
  ; discovered_at
  }

let to_value (c : t) : Integrator_core.Value.t =
  let open Integrator_core.Value in
  VObject
    [ "base_url", VString c.base_url
    ; "discovered_at", VFloat c.discovered_at
    ; "endpoints",
      VArray (List.map Endpoint.to_value c.endpoints)
    ]
