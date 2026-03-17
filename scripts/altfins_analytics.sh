#!/usr/bin/env bash
set -euo pipefail

# altfins_analytics.sh — Get historical analytics data for a crypto symbol
#
# Retrieves time-series data for any of 150+ technical indicators from altFINS.
# Examples: SMA, EMA, RSI, MACD, Bollinger Bands, trend data, fundamentals.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_analytics.sh" \
    "Get historical analytics/indicator data for a crypto symbol" \
    "altfins_analytics.sh [options]" \
    "Options:
  --symbol <symbol>       Crypto symbol, e.g. BTC (required)
  --type <analytics_type> Analytics type, e.g. RSI14, SMA50, MACD (required)
  --interval <interval>   MINUTES15|HOURLY|HOURS4|HOURS12|DAILY (default: DAILY)
  --from <iso-date>       Start date in ISO 8601 format
  --to <iso-date>         End date in ISO 8601 format
  --days <n>              Shorthand: fetch last N days (default: 30)
  --page <n>              Page number (default: 0)
  --size <n>              Page size (default: 100)
  --all                   Fetch all pages
  --list-types            List all available analytics types
  --help                  Show this help

Common Analytics Types:
  Price:       DOLLAR_PRICE, LAST_PRICE, HIGH, LOW
  Performance: PRICE_CHANGE_1D, PRICE_CHANGE_1W, PRICE_CHANGE_1M
  SMA:         SMA5, SMA10, SMA20, SMA50, SMA100, SMA200
  EMA:         EMA9, EMA12, EMA26, EMA50, EMA100, EMA200
  RSI:         RSI9, RSI14, RSI25
  MACD:        MACD, MACD_SIGNAL_LINE, MACD_HISTOGRAM
  Stochastic:  STOCH, STOCH_SLOW, STOCH_RSI
  Trends:      SHORT_TERM_TREND, MEDIUM_TERM_TREND, LONG_TERM_TREND
  Volatility:  ATR, BOLLINGER_BAND_LOWER, BOLLINGER_BAND_UPPER
  Volume:      VOLUME, VOLUME_AVG, VOLUME_RELATIVE, OBV
  Fundamental: TVL, TOTAL_REVENUE, MARKET_CAP, MARKET_CAP_SALES"
}

# Defaults
symbol=""
analytics_type=""
interval="DAILY"
from_date=""
to_date=""
days=30
page=0
size=100
fetch_all=false
list_types=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --symbol)      symbol="$2"; shift 2 ;;
    --type)        analytics_type="$2"; shift 2 ;;
    --interval)    interval="$2"; shift 2 ;;
    --from)        from_date="$2"; shift 2 ;;
    --to)          to_date="$2"; shift 2 ;;
    --days)        days="$2"; shift 2 ;;
    --page)        page="$2"; shift 2 ;;
    --size)        size="$2"; shift 2 ;;
    --all)         fetch_all=true; shift ;;
    --list-types)  list_types=true; shift ;;
    --help)        usage ;;
    *)
      echo "Error: unknown option '$1'" >&2
      exit 1 ;;
  esac
done

# List available analytics types
if [[ "$list_types" == true ]]; then
  make_checked_request "GET" "/analytics/types" "list analytics types"
  exit $?
fi

# Validate required params
if [[ -z "$symbol" ]]; then
  echo "Error: --symbol is required" >&2
  exit 1
fi
if [[ -z "$analytics_type" ]]; then
  echo "Error: --type is required (e.g. RSI14, SMA50, MACD)" >&2
  exit 1
fi

validate_time_interval "$interval"

# Default date range
if [[ -z "$from_date" ]]; then
  from_date=$(iso_date "$days")
fi
if [[ -z "$to_date" ]]; then
  to_date=$(iso_date 0)
fi

payload=$(jq -n \
  --arg symbol "$symbol" \
  --arg interval "$interval" \
  --arg type "$analytics_type" \
  --arg from "$from_date" \
  --arg to "$to_date" \
  '{symbol: $symbol, timeInterval: $interval, analyticsType: $type, from: $from, to: $to}')

if [[ "$fetch_all" == true ]]; then
  paginate_request "/analytics/search-requests" "$payload" "analytics history"
else
  make_checked_request "POST" "/analytics/search-requests?page=${page}&size=${size}" "analytics history" "$payload"
fi
