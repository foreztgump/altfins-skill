# Project Guidelines

## Code Quality
Mandatory: SRP, no magic values, descriptive names, error handling on all curl/jq calls,
set -euo pipefail in every script, no duplication, YAGNI, KISS.
Prefer: deep modules (simple CLI interface, complex API handling hidden), composition via
sourced helper functions. See CODE_PRINCIPLES.md for full details.

## Behavioral Rules
- Never guess API endpoints, parameter names, or enum values — always verify against references/api-reference.md or references/openapi.json.
- Always use Tavily MCP tools for web research. Do NOT use built-in WebSearch or WebFetch tools.
- All JSON payloads MUST be built with `jq` — never use string interpolation for user input. This prevents injection.
- API key must never be logged or echoed. Use `${ALTFINS_API_KEY:?Set ALTFINS_API_KEY}` pattern.
- altFINS API returns strings for numeric values (prices, indicators) — do not assume they are numbers in jq.
- Default time interval is DAILY. Valid: MINUTES15, HOURLY, HOURS4, HOURS12, DAILY.
- One API credit = 100 returned value items, rounded up. Keep page sizes reasonable.
- HTTP 401 = bad API key. HTTP 403 = plan doesn't include endpoint. HTTP 429 = rate limit.
- Scripts output JSON to stdout, human-readable errors to stderr. Never mix.
- Each script must support `--help` flag and exit 0 when invoked with it.
- All POST endpoints use paginated responses with `page`, `size`, `sort` query params and content array in response.

## Tools
- **OpenSpec**: Spec before code. `/opsx:new` → `/opsx:ff` → review → implement → `/opsx:verify` → `/opsx:archive`
- **Context7**: Look up library docs before writing code. `resolve-library-id` → `query-docs`.
- **Tavily**: 5 tools for all web research — `tavily_search`, `tavily_extract`, `tavily_research`, `tavily_crawl`, `tavily_map`.
- **OpenMemory**: Persistent context across sessions. Query at session start, store at key checkpoints.
- **LSP**: bash-language-server via boostvolt marketplace. Use for navigation. Requires `ENABLE_LSP_TOOL=1`.
- **Superpowers**: TDD, local code review. `superpowers:code-reviewer` before every commit.
- **CodeRabbit**: PR-level review (triggers automatically on PR).

## Research Protocol
Before writing code: references/api-reference.md (local) → references/openapi.json (local) → Tavily (API changes) → OpenMemory (patterns).

## Workflows
- `/work-local "<description>"` — full pipeline from spec to PR
- `/resume` — pick up where you left off
- `/fix "<bug>"` — debug and fix workflow

## Testing
- Use bats-core for all script tests
- Tests live in `tests/` directory
- Test naming: `test_<script_name>.bats`
- Mock curl responses for unit tests — don't hit real API in CI

## Git
Branch: `feature/short-desc` | Commit: `type(scope): desc` | PR against `main`
