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
