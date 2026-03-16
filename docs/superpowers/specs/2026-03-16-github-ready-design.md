# altfins-skill: GitHub-Ready Release — Design Spec

**Date:** 2026-03-16
**Approach:** Minimal (Approach A) — ship what's needed for a credible GitHub public repo
**Status:** Draft

## Goal

Bring altfins-skill from scaffolding to a clean, testable, documented GitHub-ready state. Users should be able to clone, set their API key, and start querying crypto data immediately.

## Scope

### In Scope
1. **README.md** — install guide, usage examples, prerequisites
2. **Test suite** — bats-core smoke tests + _lib.sh unit tests
3. **Test fixtures** — mock JSON responses for each endpoint type
4. **Minor polish** — .env → .env.example, .gitignore completeness

### Out of Scope
- Plugin marketplace registration (.claude-plugin/)
- Multi-platform install script
- Advanced screener filters (crossovers, candlestick patterns)
- CI/CD pipeline (GitHub Actions)
- Dedicated package.sh script
- CHANGELOG.md

## Design

### 1. README.md

Sections:
- **Title + one-line description**
- **Features** — bullet list of what the skill covers (150+ indicators, 130+ signals, etc.)
- **Prerequisites** — curl, jq, ALTFINS_API_KEY
- **Installation** — clone + run install.sh or manual symlink
- **Quick Start** — 5-6 common usage examples (one per script category)
- **Scripts Reference** — table of all scripts with purpose and mode
- **Configuration** — env var setup, cache directory
- **API Coverage** — link to references/api-reference.md
- **License** — MIT

Target: ~120 lines. No fluff.

### 2. Test Suite

**Framework:** bats-core (already specified in CLAUDE.md)

**Directory structure:**
```
tests/
├── fixtures/
│   ├── screener_response.json
│   ├── ohlc_snapshot_response.json
│   ├── ohlc_history_response.json
│   ├── analytics_response.json
│   ├── signals_response.json
│   ├── technical_analysis_response.json
│   ├── news_response.json
│   ├── enums_symbols_response.json
│   ├── enums_intervals_response.json
│   └── error_response.json
├── helpers/
│   └── mock_curl.bash
├── test_lib.bats
├── test_screener.bats
├── test_ohlc.bats
├── test_analytics.bats
├── test_signals.bats
├── test_technical_analysis.bats
├── test_news.bats
├── test_enums.bats
└── test_format_results.bats
```

**Test strategy:**

**mock_curl.bash:** A helper that overrides `curl` with a bash function. Based on the URL/payload, returns the appropriate fixture JSON with a configurable HTTP status code. This avoids hitting the real API.

```bash
# Pattern: mock curl returns fixture based on URL match
curl() {
  local url=""
  for arg in "$@"; do url="$arg"; done
  case "$url" in
    *screener-data/search*) cat "$FIXTURES_DIR/screener_response.json" ;;
    *ohlc/snapshot*)        cat "$FIXTURES_DIR/ohlc_snapshot_response.json" ;;
    # ... etc
  esac
  echo ""  # HTTP status code line
  echo "200"
}
export -f curl
```

**test_lib.bats:** Unit tests for _lib.sh functions:
- `make_api_request` sets HTTP_CODE correctly
- `check_http_status` returns 0 on 200, 1 on errors, prints correct messages for 401/403/429
- `make_checked_request` combines both correctly
- `validate_time_interval` accepts valid, rejects invalid
- `validate_signal_direction` accepts BULLISH/BEARISH, rejects garbage
- `iso_date` produces correct ISO format
- `cache_get`/`cache_set` round-trip works
- `cache_key_for` is deterministic
- `show_help` exits 0

**test_<script>.bats:** Smoke tests per script:
- `--help` exits 0 and prints usage
- Missing required args exits 1 with error message
- Valid args with mocked curl produces JSON output
- Invalid interval/direction rejected

**test_format_results.bats:** Format tests:
- Each type (screener, ohlc, analytics, signals, ta, news) produces expected summary output
- `--top N` limits output
- `--format csv` produces CSV headers
- Invalid JSON input exits 1
- Missing `--type` exits 1

**Test count estimate:** ~60-80 tests across 9 files.

### 3. Test Fixtures

Minimal but realistic JSON. Each fixture is a valid paginated response matching the actual API schema from references/openapi.json. Content arrays have 2-3 items each — enough to test formatting without bloat.

Example fixture structure (screener):
```json
{
  "size": 10,
  "number": 0,
  "sort": [{"direction": "DESC", "property": "lastPrice", "ignoreCase": false, "nullHandling": "NATIVE"}],
  "content": [
    {"symbol": "BTC", "name": "Bitcoin", "lastPrice": "67234.50", "additionalData": {}},
    {"symbol": "ETH", "name": "Ethereum", "lastPrice": "3456.78", "additionalData": {}}
  ],
  "totalElements": 2,
  "totalPages": 1,
  "numberOfElements": 2,
  "first": true,
  "last": true
}
```

### 4. Minor Polish

- Rename `.env` → `.env.example` (template, not real secrets)
- Ensure `.gitignore` excludes `.env` but not `.env.example`
- Verify all scripts have consistent header comments

## Success Criteria

1. `make check` passes (shellcheck + bats)
2. All 9 test files pass with mocked curl (no real API calls)
3. README.md provides clear path from clone to first query
4. Repository is clean for `git push` — no secrets, no temp files

## Dependencies

- bats-core installed (`sudo apt install bats` or from GitHub)
- No API key needed for tests (all mocked)
