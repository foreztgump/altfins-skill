#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "technical_analysis --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_technical_analysis.sh" --help
  [[ "$status" -eq 0 ]]
}

@test "technical_analysis default args returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_technical_analysis.sh"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "technical_analysis --symbol BTC returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_technical_analysis.sh" --symbol BTC
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}
