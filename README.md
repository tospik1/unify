# Unify — Automated API Discovery & Contract Inference

Unify is a tool that discovers unknown API endpoints from a website and automatically generates an OpenAPI specification from real observed responses.

It combines:

- 🔍 A Python-based endpoint explorer
- 🧠 A strongly-typed OCaml inference engine
- 📄 Automatic OpenAPI 3.0 generation

The goal is to turn undocumented or partially documented APIs into structured, machine-readable contracts.

---

## 🚀 What Problem Does This Solve?

Many systems:

- Use multiple services
- Have incomplete or outdated documentation
- Mix JSON, XML, or unknown response formats
- Change over time without version control

Unify allows you to:

1. Crawl an API surface starting from a base URL
2. Collect real responses
3. Infer response schemas
4. Generate an OpenAPI specification automatically

This enables:
- Contract validation
- SDK generation
- Change detection
- API governance
- Documentation bootstrapping

---

## 🏗 Architecture

The system is split into clear layers:

### 1️⃣ Explorer (Python)

Responsible for discovering endpoints.

It:
- Expands common API paths
- Tries multiple HTTP methods
- Collects response samples
- Produces structured crawl JSON

Output example:

```json
{
  "base_url": "https://example.com",
  "endpoints": [
    {
      "endpoint": "https://example.com/api/users",
      "method": "GET",
      "samples": [
        {
          "status_code": 200,
          "body": { "id": 1, "name": "Alice" }
        }
      ]
    }
  ]
}
