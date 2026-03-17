#!/usr/bin/env bash
set -euo pipefail

# altfins_technical_analysis.sh — Get curated expert technical analysis
#
# Retrieves structured trade setups for 50+ major cryptocurrencies including
# entry zones, exit targets, stop-loss levels, and technical reasoning.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_technical_analysis.sh" \
    "Get curated technical analysis with trade setups for top 50+ coins" \
    "altfins_technical_analysis.sh [options]" \
    "Options:
  --symbol <symbol>       Filter by symbol, e.g. BTC (default: all coins)
  --page <n>              Page number (default: 0)
  --size <n>              Page size (default: 20)
  --help                  Show this help

Response includes for each coin:
  - nearTermOutlook: current outlook assessment
  - patternType: identified chart pattern
  - patternStage: current stage of pattern
  - description: detailed technical analysis text
  - imgChartUrl: chart image URL
  - updatedDate: when analysis was last updated"
}

# Defaults
symbol=""
page=0
size=20

while [[ $# -gt 0 ]]; do
  case "$1" in
    --symbol)  symbol="$2"; shift 2 ;;
    --page)    page="$2"; shift 2 ;;
    --size)    size="$2"; shift 2 ;;
    --help)    usage ;;
    *)
      echo "Error: unknown option '$1'" >&2
      exit 1 ;;
  esac
done

# Build query string
query="page=${page}&size=${size}"
if [[ -n "$symbol" ]]; then
  query="${query}&symbol=${symbol}"
fi

make_checked_request "GET" "/technical-analysis/data?${query}" "technical analysis"
