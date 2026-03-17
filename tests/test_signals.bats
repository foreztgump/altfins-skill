#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "signals --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_signals.sh" --help
  [[ "$status" -eq 0 ]]
}

@test "signals --list-keys returns JSON array with signalKey field" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_signals.sh" --list-keys
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].signalKey'
}

@test "signals default args returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_signals.sh"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "signals --direction BULLISH --days 1 returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_signals.sh" --direction BULLISH --days 1
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "signals --direction NEUTRAL exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_signals.sh" --direction NEUTRAL
  [[ "$status" -eq 1 ]]
}
