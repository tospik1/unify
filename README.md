Unify — Automated API Discovery & Contract Inference
Unify is a tool that discovers unknown API endpoints from a website and automatically generates an OpenAPI specification from real observed responses.
It combines:
• A Python-based endpoint explorer
• A strongly-typed OCaml inference engine
• Automatic OpenAPI 3.0 generation
What Problem Does This Solve?
Many systems use multiple services, have incomplete or outdated documentation, mix JSON/XML or unknown response formats, and change over time without version control.
Unify allows you to crawl an API surface, collect real responses, infer response schemas, and generate an OpenAPI specification automatically.
This enables:
• Contract validation
• SDK generation
• Change detection
• API governance
• Documentation bootstrapping
Architecture Overview
1) Explorer (Python)
Responsible for discovering endpoints. It expands common API paths, tries multiple HTTP methods, collects response samples, and produces structured crawl JSON.
2) Core (OCaml)
Responsible for strong typing and schema inference. It provides a unified Value.t data model, a structured error system, a decoder DSL, shape inference, domain modeling, and OpenAPI export logic.
3) Export Layer
Transforms inferred shapes into OpenAPI 3.0 compliant JSON.
Pipeline Overview
Seed URL → Explorer (Python) → crawl.json → OCaml Core → Schema Inference → OpenAPI Generation → openapi.json
How to Use
Step 1: Crawl
python -m explorer_pkg https://api.example.com --max-endpoints 15 --retries 3 --timeout 4 --methods GET,POST --output crawl.json
Step 2: Generate OpenAPI
dune exec integrator ../explorer/crawl.json > openapi.json
Current Capabilities
• Endpoint discovery via heuristic path expansion
• Multi-method probing (GET, POST, etc.)
• Response shape inference
• Structured error reporting
• OpenAPI 3.0 output
• Modular and extensible design
Current Limitations
• No deep JavaScript-based endpoint extraction yet
• No multi-sample schema merging
• No automatic auth discovery
• No schema diffing between runs
Design Philosophy
Unify separates concerns between dynamic discovery (Python), static type enforcement (OCaml), and interoperability/export (OpenAPI). This ensures flexibility, type safety, and long-term maintainability.
Roadmap
• JavaScript-based endpoint extraction
• Auth-aware crawling
• Schema merging across samples
• Change detection between crawls
• SDK generation (TypeScript, Python)
• Confidence scoring for discovered endpoints
Ethics & Usage
Unify should only be used on systems you own or are authorized to analyze. API discovery may resemble security scanning. Always obtain proper authorization.
Purpose
Unify explores whether undocumented APIs can be reverse-engineered into structured contracts using layered inference and strong typing. It sits at the intersection of API governance, contract inference, developer tooling, and automated integration systems.
