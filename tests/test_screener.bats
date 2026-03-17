#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "screener --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_screener.sh" --help
  [[ "$status" -eq 0 ]]
}

@test "screener --types returns JSON array with id field" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_screener.sh" --types
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].id'
}

@test "screener default args returns paginated response with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_screener.sh"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "screener --min-mcap 1000000000 --interval DAILY returns response" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_screener.sh" --min-mcap 1000000000 --interval DAILY
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "screener --interval WEEKLY exits 1 (invalid interval)" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_screener.sh" --interval WEEKLY
  [[ "$status" -eq 1 ]]
}
