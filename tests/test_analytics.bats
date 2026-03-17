#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "analytics --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_analytics.sh" --help
  [[ "$status" -eq 0 ]]
}

@test "analytics --list-types returns JSON array with id field" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_analytics.sh" --list-types
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].id'
}

@test "analytics --symbol BTC --type RSI14 --days 7 returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_analytics.sh" --symbol BTC --type RSI14 --days 7
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "analytics without --symbol exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_analytics.sh" --type RSI14
  [[ "$status" -eq 1 ]]
}

@test "analytics without --type exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_analytics.sh" --symbol BTC
  [[ "$status" -eq 1 ]]
}
