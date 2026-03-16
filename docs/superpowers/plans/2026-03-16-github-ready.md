# GitHub-Ready Release Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring altfins-skill to a clean, testable, documented state ready for public GitHub release.

**Architecture:** Add bats-core test suite with mocked curl (no live API calls), test fixtures matching the OpenAPI schema, README.md for user onboarding, and minor polish (.env.example rename). All tests run via `make check`.

**Tech Stack:** Bash 5+, bats-core 1.13.0, shellcheck, curl, jq

---

## Chunk 1: Test Infrastructure

### Task 1: Create test fixtures

**Files:**
- Create: `tests/fixtures/screener_response.json`
- Create: `tests/fixtures/screener_types_response.json`
- Create: `tests/fixtures/ohlc_snapshot_response.json`
- Create: `tests/fixtures/ohlc_history_response.json`
- Create: `tests/fixtures/analytics_response.json`
- Create: `tests/fixtures/analytics_types_response.json`
- Create: `tests/fixtures/signals_response.json`
- Create: `tests/fixtures/signal_keys_response.json`
- Create: `tests/fixtures/technical_analysis_response.json`
- Create: `tests/fixtures/news_response.json`
- Create: `tests/fixtures/enums_symbols_response.json`
- Create: `tests/fixtures/enums_intervals_response.json`
- Create: `tests/fixtures/enums_permits_response.json`
- Create: `tests/fixtures/error_response.json`

- [ ] **Step 1: Create fixtures directory**

```bash
mkdir -p tests/fixtures tests/helpers
```

- [ ] **Step 2: Create all 14 fixture files**

Each fixture must be valid JSON matching the API schema from `references/openapi.json`. Content arrays have 2-3 items. Paginated responses include `size`, `number`, `sort`, `content`, `totalElements`, `totalPages`, `numberOfElements`, `first`, `last`.

`tests/fixtures/screener_response.json`:
```json
{
  "size": 100,
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

`tests/fixtures/screener_types_response.json`:
```json
[
  {"id": "PERFORMANCE", "friendlyName": "Price change"},
  {"id": "MARKET_CAP", "friendlyName": "Market Cap"}
]
```

`tests/fixtures/ohlc_snapshot_response.json`:
```json
{
  "size": 100,
  "number": 0,
  "sort": [],
  "content": [
    {"symbol": "BTC", "time": "2026-03-16T00:00:00Z", "open": "66800.00", "high": "67500.00", "low": "66200.00", "close": "67234.50", "volume": "1234567890.00"},
    {"symbol": "ETH", "time": "2026-03-16T00:00:00Z", "open": "3400.00", "high": "3480.00", "low": "3380.00", "close": "3456.78", "volume": "987654321.00"}
  ],
  "totalElements": 2,
  "totalPages": 1,
  "numberOfElements": 2,
  "first": true,
  "last": true
}
```

`tests/fixtures/ohlc_history_response.json`:
```json
{
  "size": 100,
  "number": 0,
  "sort": [],
  "content": [
    {"symbol": "BTC", "time": "2026-03-15T00:00:00Z", "open": "65000.00", "high": "66000.00", "low": "64500.00", "close": "65800.00", "volume": "1100000000.00"},
    {"symbol": "BTC", "time": "2026-03-16T00:00:00Z", "open": "65800.00", "high": "67500.00", "low": "65200.00", "close": "67234.50", "volume": "1234567890.00"}
  ],
  "totalElements": 2,
  "totalPages": 1,
  "numberOfElements": 2,
  "first": true,
  "last": true
}
```

`tests/fixtures/analytics_response.json`:
```json
{
  "size": 100,
  "number": 0,
  "sort": [],
  "content": [
    {"symbol": "BTC", "time": "2026-03-15T00:00:00Z", "value": "42.35", "nonNumericalValue": null},
    {"symbol": "BTC", "time": "2026-03-16T00:00:00Z", "value": "45.12", "nonNumericalValue": null}
  ],
  "totalElements": 2,
  "totalPages": 1,
  "numberOfElements": 2,
  "first": true,
  "last": true
}
```

`tests/fixtures/analytics_types_response.json`:
```json
[
  {"id": "RSI14", "friendlyName": "RSI (14)", "isNumerical": true},
  {"id": "SMA50", "friendlyName": "SMA (50)", "isNumerical": true},
  {"id": "SHORT_TERM_TREND", "friendlyName": "Short Term Trend", "isNumerical": false}
]
```

`tests/fixtures/signals_response.json`:
```json
{
  "size": 100,
  "number": 0,
  "sort": [],
  "content": [
    {"timestamp": "2026-03-16T10:30:00Z", "direction": "BULLISH", "signalKey": "EMA_12_50_CROSSOVERS", "signalName": "EMA 12/50 Crossover", "symbol": "BTC", "lastPrice": "67234.50", "marketCap": "1320000000000", "priceChange": "2.15", "symbolName": "Bitcoin"},
    {"timestamp": "2026-03-16T09:15:00Z", "direction": "BEARISH", "signalKey": "SIGNALS_SUMMARY_RSI_14", "signalName": "RSI(14) Overbought", "symbol": "SOL", "lastPrice": "142.30", "marketCap": "65000000000", "priceChange": "-1.80", "symbolName": "Solana"}
  ],
  "totalElements": 2,
  "totalPages": 1,
  "numberOfElements": 2,
  "first": true,
  "last": true
}
```

`tests/fixtures/signal_keys_response.json`:
```json
[
  {"nameBullish": "EMA 12/50 Bullish Crossover", "nameBearish": "EMA 12/50 Bearish Crossover", "trendSensitive": false, "signalType": "MA_CROSSOVER", "signalKey": "EMA_12_50_CROSSOVERS"},
  {"nameBullish": "RSI(14) Oversold", "nameBearish": "RSI(14) Overbought", "trendSensitive": true, "signalType": "MOMENTUM", "signalKey": "SIGNALS_SUMMARY_RSI_14"}
]
```

`tests/fixtures/technical_analysis_response.json`:
```json
{
  "size": 100,
  "number": 0,
  "sort": [],
  "content": [
    {"symbol": "BTC", "friendlyName": "Bitcoin", "updatedDate": "2026-03-16T08:00:00Z", "nearTermOutlook": "Bullish", "patternType": "Ascending Triangle", "patternStage": "Breakout", "description": "BTC broke above resistance at $66,500.", "imgChartUrl": "https://example.com/btc.png", "imgChartUrlDark": "https://example.com/btc-dark.png", "logoUrl": "https://example.com/btc-logo.png"}
  ],
  "totalElements": 1,
  "totalPages": 1,
  "numberOfElements": 1,
  "first": true,
  "last": true
}
```

`tests/fixtures/news_response.json`:
```json
{
  "size": 100,
  "number": 0,
  "sort": [],
  "content": [
    {"messageId": 1001, "sourceId": 1, "content": "Bitcoin surged past $67,000 amid strong institutional demand.", "title": "BTC Breaks $67K", "url": "https://example.com/btc-67k", "sourceName": "CoinDesk", "timestamp": "2026-03-16T12:00:00Z"},
    {"messageId": 1002, "sourceId": 2, "content": "Ethereum Layer 2 adoption accelerates with new partnerships.", "title": "ETH L2 Growth", "url": "https://example.com/eth-l2", "sourceName": "The Block", "timestamp": "2026-03-16T10:00:00Z"}
  ],
  "totalElements": 2,
  "totalPages": 1,
  "numberOfElements": 2,
  "first": true,
  "last": true
}
```

`tests/fixtures/enums_symbols_response.json`:
```json
[
  {"name": "BTC", "friendlyName": "Bitcoin"},
  {"name": "ETH", "friendlyName": "Ethereum"},
  {"name": "SOL", "friendlyName": "Solana"}
]
```

`tests/fixtures/enums_intervals_response.json`:
```json
["MINUTES15", "HOURLY", "HOURS4", "HOURS12", "DAILY"]
```

`tests/fixtures/enums_permits_response.json`:
```json
{"availablePermits": 9500, "monthlyAvailablePermits": 10000}
```

`tests/fixtures/error_response.json`:
```json
{"timestamp": "2026-03-16T00:00:00Z", "status": 400, "error": "Bad Request", "message": "Validation failed", "request": "/api/v2/public/test", "exceptionUID": "test-uid-123", "details": {}, "validations": []}
```

- [ ] **Step 3: Validate all fixtures are valid JSON**

Run: `for f in tests/fixtures/*.json; do jq '.' "$f" > /dev/null && echo "OK: $f" || echo "FAIL: $f"; done`
Expected: All OK

- [ ] **Step 4: Commit fixtures**

```bash
git add tests/fixtures/
git commit -m "test: add API response fixtures for all endpoints"
```

---

### Task 2: Create mock_curl helper

**Files:**
- Create: `tests/helpers/mock_curl.bash`

- [ ] **Step 1: Write mock_curl.bash**

```bash
#!/usr/bin/env bash
# tests/helpers/mock_curl.bash — mock curl for bats tests
#
# Source this file in setup() to override curl with a function that
# returns fixture data based on URL pattern matching.
#
# Control behavior:
#   MOCK_HTTP_CODE=200   (default) — HTTP status code to return
#   FIXTURES_DIR         (required) — path to fixtures directory

MOCK_HTTP_CODE="${MOCK_HTTP_CODE:-200}"

curl() {
  local url=""
  for arg in "$@"; do
    [[ "$arg" == http* ]] && url="$arg"
  done

  local fixture=""
  case "$url" in
    *screener-data/search-requests*) fixture="screener_response.json" ;;
    *screener-data/value-types*)     fixture="screener_types_response.json" ;;
    *ohlcv/snapshot*)                fixture="ohlc_snapshot_response.json" ;;
    *ohlcv/history*)                 fixture="ohlc_history_response.json" ;;
    *analytics/search*)              fixture="analytics_response.json" ;;
    *analytics/types*)               fixture="analytics_types_response.json" ;;
    *signals-feed/search-requests*)  fixture="signals_response.json" ;;
    *signals-feed/signal-keys*)      fixture="signal_keys_response.json" ;;
    *news-summary/search*)           fixture="news_response.json" ;;
    *news-summary/find*)             fixture="news_response.json" ;;
    *technical-analysis/data*)       fixture="technical_analysis_response.json" ;;
    *"/symbols"*)                    fixture="enums_symbols_response.json" ;;
    *"/intervals"*)                  fixture="enums_intervals_response.json" ;;
    *available-permits*)             fixture="enums_permits_response.json" ;;
    *)                               fixture="error_response.json" ;;
  esac

  cat "${FIXTURES_DIR}/${fixture}"
  printf "\n%s" "$MOCK_HTTP_CODE"
}
export -f curl
```

- [ ] **Step 2: Verify it sources without error**

Run: `bash -c 'FIXTURES_DIR=tests/fixtures source tests/helpers/mock_curl.bash && echo "OK"'`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add tests/helpers/mock_curl.bash
git commit -m "test: add mock_curl helper for bats tests"
```

---

## Chunk 2: Library Tests

### Task 3: Create test_lib.bats

**Files:**
- Create: `tests/test_lib.bats`

- [ ] **Step 1: Write test_lib.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  # Override HOME so cache writes go to temp dir
  export HOME="${BATS_TEST_TMPDIR}"

  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
  source "${BATS_TEST_DIRNAME}/../scripts/_lib.sh"
}

# --- show_help ---

@test "show_help exits 0" {
  run show_help "test" "description" "usage" "options"
  [[ "$status" -eq 0 ]]
}

# --- check_http_status ---

@test "check_http_status returns 0 on HTTP 200" {
  run check_http_status 200 '{}' "test action"
  [[ "$status" -eq 0 ]]
}

@test "check_http_status returns 1 on HTTP 401" {
  run check_http_status 401 '{}' "test action"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"unauthorized"* ]]
}

@test "check_http_status returns 1 on HTTP 403" {
  run check_http_status 403 '{}' "test action"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"forbidden"* ]]
}

@test "check_http_status returns 1 on HTTP 429" {
  run check_http_status 429 '{}' "test action"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"rate limit"* ]]
}

@test "check_http_status returns 1 on HTTP 500 with message" {
  run check_http_status 500 '{"message":"internal error"}' "test action"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"internal error"* ]]
}

@test "check_http_status returns 1 on invalid code" {
  run check_http_status "abc" '{}' "test action"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"invalid HTTP response"* ]]
}

# --- validate_time_interval ---

@test "validate_time_interval accepts DAILY" {
  run validate_time_interval DAILY
  [[ "$status" -eq 0 ]]
}

@test "validate_time_interval accepts MINUTES15" {
  run validate_time_interval MINUTES15
  [[ "$status" -eq 0 ]]
}

@test "validate_time_interval accepts HOURLY" {
  run validate_time_interval HOURLY
  [[ "$status" -eq 0 ]]
}

@test "validate_time_interval accepts HOURS4" {
  run validate_time_interval HOURS4
  [[ "$status" -eq 0 ]]
}

@test "validate_time_interval accepts HOURS12" {
  run validate_time_interval HOURS12
  [[ "$status" -eq 0 ]]
}

@test "validate_time_interval rejects invalid interval" {
  run validate_time_interval WEEKLY
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"invalid time interval"* ]]
}

# --- validate_signal_direction ---

@test "validate_signal_direction accepts BULLISH" {
  run validate_signal_direction BULLISH
  [[ "$status" -eq 0 ]]
}

@test "validate_signal_direction accepts BEARISH" {
  run validate_signal_direction BEARISH
  [[ "$status" -eq 0 ]]
}

@test "validate_signal_direction accepts empty string" {
  run validate_signal_direction ""
  [[ "$status" -eq 0 ]]
}

@test "validate_signal_direction rejects invalid direction" {
  run validate_signal_direction NEUTRAL
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"invalid signal direction"* ]]
}

# --- iso_date ---

@test "iso_date 0 returns today in ISO format" {
  run iso_date 0
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T00:00:00\.000Z$ ]]
}

@test "iso_date with no args defaults to today" {
  run iso_date
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T00:00:00\.000Z$ ]]
}

# --- format_number ---

@test "format_number formats a decimal" {
  run format_number "1234.5678" 2
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"1234.57"* || "$output" == *"1,234.57"* ]]
}

@test "format_number returns N/A for null" {
  run format_number "null"
  [[ "$output" == "N/A" ]]
}

@test "format_number returns N/A for empty" {
  run format_number ""
  [[ "$output" == "N/A" ]]
}

# --- cache_key_for ---

@test "cache_key_for is deterministic" {
  key1=$(cache_key_for "symbols")
  key2=$(cache_key_for "symbols")
  [[ "$key1" == "$key2" ]]
}

@test "cache_key_for differs for different input" {
  key1=$(cache_key_for "symbols")
  key2=$(cache_key_for "intervals")
  [[ "$key1" != "$key2" ]]
}

# --- cache_set / cache_get ---

@test "cache_set and cache_get round-trip" {
  local key
  key=$(cache_key_for "test-roundtrip")
  cache_set "$key" '{"test": true}'
  run cache_get "$key"
  [[ "$status" -eq 0 ]]
  [[ "$(echo "$output" | jq -r '.test')" == "true" ]]
}

@test "cache_get returns 1 for missing key" {
  run cache_get "nonexistent-key-12345"
  [[ "$status" -eq 1 ]]
}

# --- make_checked_request (with mock) ---

@test "make_checked_request returns body on 200" {
  run make_checked_request "GET" "/symbols" "list symbols"
  [[ "$status" -eq 0 ]]
  [[ "$(echo "$output" | jq -r '.[0].name')" == "BTC" ]]
}

@test "make_checked_request returns 1 on error status" {
  MOCK_HTTP_CODE=401
  export MOCK_HTTP_CODE
  run make_checked_request "GET" "/symbols" "list symbols"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"unauthorized"* ]]
}
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `bats tests/test_lib.bats`
Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add tests/test_lib.bats
git commit -m "test: add _lib.sh unit tests (25 tests)"
```

---

## Chunk 3: Script Smoke Tests

### Task 4: Create script smoke tests

**Files:**
- Create: `tests/test_screener.bats`
- Create: `tests/test_ohlc.bats`
- Create: `tests/test_analytics.bats`
- Create: `tests/test_signals.bats`
- Create: `tests/test_technical_analysis.bats`
- Create: `tests/test_news.bats`
- Create: `tests/test_enums.bats`

All script test files follow the same pattern. Each tests:
1. `--help` exits 0
2. Missing required args exits 1
3. Valid args with mocked curl returns JSON
4. Invalid options rejected

- [ ] **Step 1: Write test_screener.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "screener --help exits 0" {
  run scripts/altfins_screener.sh --help
  [[ "$status" -eq 0 ]]
}

@test "screener --types returns JSON array" {
  run scripts/altfins_screener.sh --types
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].id' > /dev/null
}

@test "screener with defaults returns paginated response" {
  run scripts/altfins_screener.sh
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "screener with filters returns response" {
  run scripts/altfins_screener.sh --min-mcap 1000000000 --interval DAILY
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "screener rejects invalid interval" {
  run scripts/altfins_screener.sh --interval WEEKLY
  [[ "$status" -eq 1 ]]
}
```

- [ ] **Step 2: Write test_ohlc.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "ohlc --help exits 0" {
  run scripts/altfins_ohlc.sh --help
  [[ "$status" -eq 0 ]]
}

@test "ohlc no args exits 0 with help" {
  run scripts/altfins_ohlc.sh
  [[ "$status" -eq 0 ]]
}

@test "ohlc snapshot with symbols returns JSON" {
  run scripts/altfins_ohlc.sh snapshot --symbols '["BTC","ETH"]'
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "ohlc snapshot without --symbols fails" {
  run scripts/altfins_ohlc.sh snapshot
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"--symbols is required"* ]]
}

@test "ohlc history with symbol returns JSON" {
  run scripts/altfins_ohlc.sh history --symbol BTC --days 7
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "ohlc history without --symbol fails" {
  run scripts/altfins_ohlc.sh history
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"--symbol is required"* ]]
}

@test "ohlc rejects invalid mode" {
  run scripts/altfins_ohlc.sh badmode
  [[ "$status" -eq 1 ]]
}
```

- [ ] **Step 3: Write test_analytics.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "analytics --help exits 0" {
  run scripts/altfins_analytics.sh --help
  [[ "$status" -eq 0 ]]
}

@test "analytics --list-types returns JSON array" {
  run scripts/altfins_analytics.sh --list-types
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].id' > /dev/null
}

@test "analytics with symbol and type returns JSON" {
  run scripts/altfins_analytics.sh --symbol BTC --type RSI14 --days 7
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "analytics without --symbol fails" {
  run scripts/altfins_analytics.sh --type RSI14
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"--symbol is required"* ]]
}

@test "analytics without --type fails" {
  run scripts/altfins_analytics.sh --symbol BTC
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"--type is required"* ]]
}
```

- [ ] **Step 4: Write test_signals.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "signals --help exits 0" {
  run scripts/altfins_signals.sh --help
  [[ "$status" -eq 0 ]]
}

@test "signals --list-keys returns JSON array" {
  run scripts/altfins_signals.sh --list-keys
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].signalKey' > /dev/null
}

@test "signals with defaults returns JSON" {
  run scripts/altfins_signals.sh
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "signals with --direction BULLISH returns JSON" {
  run scripts/altfins_signals.sh --direction BULLISH --days 1
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "signals rejects invalid direction" {
  run scripts/altfins_signals.sh --direction NEUTRAL
  [[ "$status" -eq 1 ]]
}
```

- [ ] **Step 5: Write test_technical_analysis.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "technical_analysis --help exits 0" {
  run scripts/altfins_technical_analysis.sh --help
  [[ "$status" -eq 0 ]]
}

@test "technical_analysis with defaults returns JSON" {
  run scripts/altfins_technical_analysis.sh
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "technical_analysis with --symbol BTC returns JSON" {
  run scripts/altfins_technical_analysis.sh --symbol BTC
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}
```

- [ ] **Step 6: Write test_news.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "news --help exits 0" {
  run scripts/altfins_news.sh --help
  [[ "$status" -eq 0 ]]
}

@test "news no args exits 0 with help" {
  run scripts/altfins_news.sh
  [[ "$status" -eq 0 ]]
}

@test "news search returns JSON" {
  run scripts/altfins_news.sh search --days 7
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "news find returns JSON" {
  run scripts/altfins_news.sh find --days 1
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content' > /dev/null
}

@test "news rejects invalid mode" {
  run scripts/altfins_news.sh badmode
  [[ "$status" -eq 1 ]]
}
```

- [ ] **Step 7: Write test_enums.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "enums --help exits 0" {
  run scripts/altfins_enums.sh --help
  [[ "$status" -eq 0 ]]
}

@test "enums no args exits 0 with help" {
  run scripts/altfins_enums.sh
  [[ "$status" -eq 0 ]]
}

@test "enums symbols returns JSON array" {
  run scripts/altfins_enums.sh symbols
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].name' > /dev/null
}

@test "enums intervals returns JSON array" {
  run scripts/altfins_enums.sh intervals
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0]' > /dev/null
}

@test "enums permits returns JSON" {
  run scripts/altfins_enums.sh permits
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.availablePermits' > /dev/null
}

@test "enums rejects unknown command" {
  run scripts/altfins_enums.sh badcommand
  [[ "$status" -eq 1 ]]
}
```

- [ ] **Step 8: Run all script tests**

Run: `bats tests/test_screener.bats tests/test_ohlc.bats tests/test_analytics.bats tests/test_signals.bats tests/test_technical_analysis.bats tests/test_news.bats tests/test_enums.bats`
Expected: All pass

- [ ] **Step 9: Commit**

```bash
git add tests/test_screener.bats tests/test_ohlc.bats tests/test_analytics.bats tests/test_signals.bats tests/test_technical_analysis.bats tests/test_news.bats tests/test_enums.bats
git commit -m "test: add smoke tests for all 7 API scripts"
```

---

## Chunk 4: Format Tests

### Task 5: Create test_format_results.bats

**Files:**
- Create: `tests/test_format_results.bats`

Note: This script does NOT call curl. Tests pipe fixture JSON directly — no mock needed.

- [ ] **Step 1: Write test_format_results.bats**

```bash
#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  # format_results sources _lib.sh for show_help, but does not call curl
  export ALTFINS_API_KEY="test-key-for-bats"
  export HOME="${BATS_TEST_TMPDIR}"
}

@test "format --help exits 0" {
  run scripts/altfins_format_results.sh --help
  [[ "$status" -eq 0 ]]
}

@test "format without --type fails" {
  run scripts/altfins_format_results.sh
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"--type is required"* ]]
}

@test "format screener summary shows symbols" {
  run scripts/altfins_format_results.sh --type screener "$FIXTURES_DIR/screener_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"ETH"* ]]
  [[ "$output" == *"Total: 2"* ]]
}

@test "format screener csv produces header" {
  run scripts/altfins_format_results.sh --type screener --format csv "$FIXTURES_DIR/screener_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"symbol,name,lastPrice"* ]]
}

@test "format ohlc summary shows candle data" {
  run scripts/altfins_format_results.sh --type ohlc "$FIXTURES_DIR/ohlc_history_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"Total: 2"* ]]
}

@test "format analytics summary shows values" {
  run scripts/altfins_format_results.sh --type analytics "$FIXTURES_DIR/analytics_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"42.35"* || "$output" == *"45.12"* ]]
}

@test "format signals summary shows direction" {
  run scripts/altfins_format_results.sh --type signals "$FIXTURES_DIR/signals_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BULLISH"* ]]
  [[ "$output" == *"BTC"* ]]
}

@test "format ta summary shows outlook" {
  run scripts/altfins_format_results.sh --type ta "$FIXTURES_DIR/technical_analysis_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"Bullish"* ]]
}

@test "format news summary shows titles" {
  run scripts/altfins_format_results.sh --type news "$FIXTURES_DIR/news_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC Breaks"* ]]
}

@test "format --top 1 limits output" {
  run scripts/altfins_format_results.sh --type screener --top 1 "$FIXTURES_DIR/screener_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  # ETH should not appear in content (may appear in total count)
  local lines
  lines=$(echo "$output" | grep -c "ETH" || true)
  [[ "$lines" -eq 0 ]]
}

@test "format rejects invalid type" {
  run scripts/altfins_format_results.sh --type badtype "$FIXTURES_DIR/screener_response.json"
  [[ "$status" -eq 1 ]]
}

@test "format rejects invalid JSON" {
  run bash -c 'echo "not json" | scripts/altfins_format_results.sh --type screener'
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"invalid JSON"* ]]
}
```

- [ ] **Step 2: Run format tests**

Run: `bats tests/test_format_results.bats`
Expected: All pass

- [ ] **Step 3: Commit**

```bash
git add tests/test_format_results.bats
git commit -m "test: add format_results tests (13 tests)"
```

---

### Task 6: Run full test suite and verify

- [ ] **Step 1: Run make check**

Run: `make check`
Expected: shellcheck passes, all bats tests pass

- [ ] **Step 2: Fix any failures**

If tests fail, debug and fix. Common issues:
- `run` in bats captures stdout+stderr — some assertions may need adjustment
- Scripts that `exit 0` in `show_help` — `run` captures that correctly
- Mock curl URL patterns must match actual URLs constructed in scripts

- [ ] **Step 3: Report test count**

Run: `bats tests/*.bats 2>&1 | tail -1`
Expected: Something like `XX tests, 0 failures`

---

## Chunk 5: README and Polish

### Task 7: Create README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

```markdown
# altfins-skill

Bash scripts for querying the [altFINS Crypto Data & Analytics API](https://altfins.com/crypto-market-and-analytical-data-api/). Designed as an AI agent skill — gives LLMs structured access to 150+ technical indicators, 130+ trading signals, OHLCV data, news summaries, and expert technical analysis across 2,200+ crypto assets.

## Features

- **Screener** — filter 2,200+ cryptos by price, volume, market cap, RSI, MACD, trends
- **OHLCV** — snapshot (multi-coin) or historical candle data across 5 time intervals
- **Analytics** — historical data for 150+ indicators (SMA, EMA, RSI, MACD, Bollinger, etc.)
- **Signals** — 130+ trading signals with bullish/bearish direction filtering
- **Technical Analysis** — curated expert trade setups for top 50+ coins
- **News** — AI-generated crypto news summaries
- **Reference data** — symbols, intervals, API credit balance

## Prerequisites

- **Linux** (macOS: `stat -c` in caching is not portable — contributions welcome)
- `curl`
- `jq`
- An [altFINS API key](https://altfins.com/crypto-market-and-analytical-data-api/)

## Installation

```bash
git clone https://github.com/foreztgump/altfins-skill.git
cd altfins-skill

# Set your API key
export ALTFINS_API_KEY='your_key_here'

# Option A: install script (symlinks to ~/.local/bin)
./install.sh

# Option B: run directly from repo
scripts/altfins_enums.sh symbols | jq length
```

## Quick Start

```bash
# Screen for oversold large caps
scripts/altfins_screener.sh --min-mcap 1000000000 --max-rsi14 30 \
  | scripts/altfins_format_results.sh --type screener --top 10

# Get BTC price history (last 90 days)
scripts/altfins_ohlc.sh history --symbol BTC --days 90 \
  | scripts/altfins_format_results.sh --type ohlc

# Check RSI(14) for ETH
scripts/altfins_analytics.sh --symbol ETH --type RSI14 --days 30 \
  | scripts/altfins_format_results.sh --type analytics

# Today's bullish signals
scripts/altfins_signals.sh --direction BULLISH --days 1 \
  | scripts/altfins_format_results.sh --type signals --top 20

# Expert technical analysis for BTC
scripts/altfins_technical_analysis.sh --symbol BTC \
  | scripts/altfins_format_results.sh --type ta --format full

# Recent crypto news
scripts/altfins_news.sh search --days 3 \
  | scripts/altfins_format_results.sh --type news --top 10

# Check API credit balance
scripts/altfins_enums.sh permits
```

## Scripts

| Script | Purpose |
|--------|---------|
| `altfins_screener.sh` | Screen/filter cryptos by indicators, price, volume, trends |
| `altfins_ohlc.sh` | OHLCV price data — `snapshot` or `history` mode |
| `altfins_analytics.sh` | Historical data for 150+ technical indicators |
| `altfins_signals.sh` | Trading signals feed — 130+ signal types |
| `altfins_technical_analysis.sh` | Expert trade setups for top 50+ coins |
| `altfins_news.sh` | AI-generated crypto news summaries |
| `altfins_enums.sh` | Reference data: symbols, intervals, API permits |
| `altfins_format_results.sh` | Format JSON output into summary, full, or CSV |

Every script supports `--help` for full usage details.

## Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `ALTFINS_API_KEY` | Yes | Your altFINS API key |

Cache is stored at `~/.config/altfins-skill/cache/` with a 5-minute TTL.

## API Coverage

Full API reference: [references/api-reference.md](references/api-reference.md)

Covers all 16 endpoints of the [altFINS Public API v2](https://altfins.com/crypto-market-and-analytical-data-api/documentation/).

## Development

```bash
make lint    # shellcheck
make test    # bats tests
make check   # both
```

## License

MIT
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with install, usage, and scripts reference"
```

---

### Task 8: Minor polish

**Files:**
- Rename: `.env` → `.env.example`
- Modify: `.gitignore`

- [ ] **Step 1: Rename .env to .env.example**

```bash
git mv .env .env.example
```

- [ ] **Step 2: Update .gitignore**

Ensure `.env` is excluded (already is) and `.env.example` is NOT excluded (already isn't — pattern is exact `.env` not `*.env`). No change needed to `.gitignore`.

- [ ] **Step 3: Commit**

```bash
git add .env.example .gitignore
git commit -m "chore: rename .env to .env.example"
```

---

### Task 9: Final verification

- [ ] **Step 1: Run full check**

Run: `make check`
Expected: 0 shellcheck warnings, all bats tests pass

- [ ] **Step 2: Verify git status is clean**

Run: `git status`
Expected: Nothing untracked except `.claude/` directory

- [ ] **Step 3: Verify no secrets**

Run: `grep -r "afns_sk_" . --include='*.sh' --include='*.json' --include='*.md' --include='*.yaml' || echo "No secrets found"`
Expected: "No secrets found"

- [ ] **Step 4: Commit all project scaffolding files**

Stage and commit any remaining untracked project files (scripts, SKILL.md, CLAUDE.md, CODE_PRINCIPLES.md, .coderabbit.yaml, openspec/, references/, Makefile, install.sh, LICENSE) that were created during project init but not yet committed.

```bash
git add scripts/ SKILL.md CLAUDE.md CODE_PRINCIPLES.md .coderabbit.yaml openspec/ references/ Makefile install.sh LICENSE .gitignore skills/
git commit -m "feat: initial altfins-skill project — bash scripts wrapping altFINS Crypto Analytics API

8 scripts + shared library covering 16 API endpoints:
screener, OHLC, analytics, signals, technical analysis, news, enums.
Includes SKILL.md agent definition, full API reference, and test suite."
```

- [ ] **Step 5: Verify final state**

Run: `git log --oneline`
Expected: Clean commit history with descriptive messages
