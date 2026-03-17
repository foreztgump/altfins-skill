#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "news search --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_news.sh" search --help
  [[ "$status" -eq 0 ]]
}

@test "news no args exits 0 (shows help)" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_news.sh"
  [[ "$status" -eq 0 ]]
}

@test "news search --days 7 returns JSON with .content" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_news.sh" search --days 7
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "news find --days 1 returns JSON" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_news.sh" find --days 1
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.content'
}

@test "news badmode exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_news.sh" badmode
  [[ "$status" -eq 1 ]]
}
