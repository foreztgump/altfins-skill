#!/usr/bin/env bash
set -euo pipefail

# altfins_screener.sh — Screen and filter crypto assets by technical indicators
#
# Uses the altFINS Screener endpoint to find coins matching criteria like
# price performance, volume, market cap, moving averages, RSI, MACD, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_screener.sh" \
    "Screen crypto assets by technical indicators and market data" \
    "altfins_screener.sh [options]" \
    "Options:
  --symbols <json>        JSON array of symbols, e.g. '[\"BTC\",\"ETH\"]' (default: all)
  --interval <interval>   Time interval: MINUTES15|HOURLY|HOURS4|HOURS12|DAILY (default: DAILY)
  --display <json>        JSON array of data types to include in response
  --min-price <n>         Minimum last price filter
  --max-price <n>         Maximum last price filter
  --min-mcap <n>          Minimum market cap filter
  --max-mcap <n>          Maximum market cap filter
  --min-volume <n>        Minimum volume filter
  --min-rsi14 <n>         Minimum RSI(14) filter
  --max-rsi14 <n>         Maximum RSI(14) filter
  --min-change-1d <n>     Minimum 1-day price change (%)
  --min-change-1w <n>     Minimum 1-week price change (%)
  --coin-type <type>      LEVERAGED|STABLE|REGULAR (default: REGULAR)
  --category <json>       JSON array of coin categories to filter
  --page <n>              Page number (default: 0)
  --size <n>              Page size (default: 50)
  --types                 List available screener data types instead of searching
  --help                  Show this help"
}

# Defaults
symbols="[]"
interval="DAILY"
display_types='[]'
numeric_filters="[]"
coin_type=""
category=""
page=0
size=50
list_types=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --symbols)     symbols="$2"; shift 2 ;;
    --interval)    interval="$2"; shift 2 ;;
    --display)     display_types="$2"; shift 2 ;;
    --min-price)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"LAST_PRICE","gteFilter":$v}]')
      shift 2 ;;
    --max-price)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"LAST_PRICE","lteFilter":$v}]')
      shift 2 ;;
    --min-mcap)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"MARKET_CAP","gteFilter":$v}]')
      shift 2 ;;
    --max-mcap)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"MARKET_CAP","lteFilter":$v}]')
      shift 2 ;;
    --min-volume)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"VOLUME","gteFilter":$v}]')
      shift 2 ;;
    --min-rsi14)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"RSI14","gteFilter":$v}]')
      shift 2 ;;
    --max-rsi14)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"RSI14","lteFilter":$v}]')
      shift 2 ;;
    --min-change-1d)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"PRICE_CHANGE_1D","gteFilter":$v}]')
      shift 2 ;;
    --min-change-1w)
      numeric_filters=$(echo "$numeric_filters" | jq --argjson v "$2" '. + [{"numericFilterType":"PRICE_CHANGE_1W","gteFilter":$v}]')
      shift 2 ;;
    --coin-type)   coin_type="$2"; shift 2 ;;
    --category)    category="$2"; shift 2 ;;
    --page)        page="$2"; shift 2 ;;
    --size)        size="$2"; shift 2 ;;
    --types)       list_types=true; shift ;;
    --help)        usage ;;
    *)
      echo "Error: unknown option '$1'" >&2
      exit 1 ;;
  esac
done

# List available screener data types
if [[ "$list_types" == true ]]; then
  make_checked_request "GET" "/screener-data/value-types" "list screener data types"
  exit $?
fi

validate_time_interval "$interval"

# Build request payload
payload=$(jq -n \
  --argjson symbols "$symbols" \
  --arg interval "$interval" \
  --argjson display "$display_types" \
  --argjson numeric "$numeric_filters" \
  '{
    symbols: $symbols,
    timeInterval: $interval,
    displayType: $display,
    numericFilters: $numeric
  }')

# Add optional filters
if [[ -n "$coin_type" ]]; then
  payload=$(echo "$payload" | jq --arg ct "$coin_type" '. + {coinTypeFilter: $ct}')
fi
if [[ -n "$category" ]]; then
  payload=$(echo "$payload" | jq --argjson cat "$category" '. + {coinCategoryFilter: $cat}')
fi

make_checked_request "POST" "/screener-data/search-requests?page=${page}&size=${size}" "screener search" "$payload"
