#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
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
