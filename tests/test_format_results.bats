#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export HOME="${BATS_TEST_TMPDIR}"
}

# --- 1. --help exits 0 ---
@test "format_results --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" --help
  [[ "$status" -eq 0 ]]
}

# --- 2. Without --type exits 1 with 'required' ---
@test "format_results without --type exits 1 with 'required'" {
  run scripts/altfins_format_results.sh
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"required"* ]]
}

# --- 3. Screener summary shows BTC, ETH, and Total: 2 ---
@test "screener summary shows BTC, ETH, and Total: 2" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type screener "${FIXTURES_DIR}/screener_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"ETH"* ]]
  [[ "$output" == *"Total: 2"* ]]
}

# --- 4. Screener CSV produces correct header ---
@test "screener CSV produces header 'symbol,name,lastPrice'" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type screener --format csv "${FIXTURES_DIR}/screener_response.json"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "symbol,name,lastPrice" ]]
}

# --- 5. OHLC summary shows BTC and Total: 2 ---
@test "ohlc summary shows BTC and Total: 2" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type ohlc "${FIXTURES_DIR}/ohlc_history_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"Total: 2"* ]]
}

# --- 6. Analytics summary shows BTC and a numeric value ---
@test "analytics summary shows BTC and a value like 42.35 or 45.12" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type analytics "${FIXTURES_DIR}/analytics_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"42.35"* || "$output" == *"45.12"* ]]
}

# --- 7. Signals summary shows BULLISH and BTC ---
@test "signals summary shows BULLISH and BTC" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type signals "${FIXTURES_DIR}/signals_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BULLISH"* ]]
  [[ "$output" == *"BTC"* ]]
}

# --- 8. TA summary shows BTC and Bullish ---
@test "ta summary shows BTC and Bullish" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type ta "${FIXTURES_DIR}/technical_analysis_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" == *"Bullish"* ]]
}

# --- 9. News summary shows 'BTC Breaks' ---
@test "news summary shows 'BTC Breaks'" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type news "${FIXTURES_DIR}/news_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC Breaks"* ]]
}

# --- 10. --top 1 limits output to only BTC, not ETH ---
@test "--top 1 limits screener output — BTC present, ETH absent" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type screener --top 1 "${FIXTURES_DIR}/screener_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"BTC"* ]]
  [[ "$output" != *"ETH"* ]]
}

# --- 11. Invalid type exits 1 ---
@test "invalid type 'badtype' exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type badtype "${FIXTURES_DIR}/screener_response.json"
  [[ "$status" -eq 1 ]]
}

# --- 12. Invalid JSON input exits 1 ---
@test "invalid JSON input exits 1" {
  local script="${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh"
  run bash -c "echo 'not json' | bash '${script}' --type screener"
  [[ "$status" -eq 1 ]]
}

# --- 13. Signals full format shows Signal: and Direction: ---
@test "signals full format shows 'Signal:' and 'Direction:'" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_format_results.sh" \
    --type signals --format full "${FIXTURES_DIR}/signals_response.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Signal:"* ]]
  [[ "$output" == *"Direction:"* ]]
}
