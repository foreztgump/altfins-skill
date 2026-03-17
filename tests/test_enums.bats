#!/usr/bin/env bats

setup() {
  export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
  export ALTFINS_API_KEY="test-key-for-bats"
  export MOCK_HTTP_CODE=200
  export HOME="${BATS_TEST_TMPDIR}"
  source "${BATS_TEST_DIRNAME}/helpers/mock_curl.bash"
}

@test "enums --help exits 0" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_enums.sh" --help
  [[ "$status" -eq 0 ]]
}

@test "enums no args exits 0 (shows help)" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_enums.sh"
  [[ "$status" -eq 0 ]]
}

@test "enums symbols returns JSON array with name field" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_enums.sh" symbols
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0].name'
}

@test "enums intervals returns JSON array" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_enums.sh" intervals
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.[0]'
}

@test "enums permits returns JSON with availablePermits" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_enums.sh" permits
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.availablePermits'
}

@test "enums badcommand exits 1" {
  run bash "${BATS_TEST_DIRNAME}/../scripts/altfins_enums.sh" badcommand
  [[ "$status" -eq 1 ]]
}
