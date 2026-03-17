#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "ohlc snapshot --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh" snapshot --help
  [[ "$status" -eq 0 ]]
}

@test "ohlc no args exits 0 (shows help)" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh"
  [[ "$status" -eq 0 ]]
}

@test "ohlc snapshot --symbols returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh" snapshot --symbols '["BTC","ETH"]'
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "ohlc snapshot without --symbols exits 1 with required" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh" snapshot
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"required"* ]]
}

@test "ohlc history --symbol BTC --days 7 returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh" history --symbol BTC --days 7
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "ohlc history without --symbol exits 1 with required" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh" history
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"required"* ]]
}

@test "ohlc badmode exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_ohlc.sh" badmode
  [[ "$status" -eq 1 ]]
}
