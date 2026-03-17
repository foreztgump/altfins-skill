#!/usr/bin/env bash
set -euo pipefail

# altfins_ohlc.sh — Get OHLCV price data (snapshot or historical)
#
# Retrieves Open/High/Low/Close/Volume data from the altFINS API.
# Two modes: snapshot (latest) or historical (date range).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_ohlc.sh" \
    "Get OHLCV price data — snapshot or historical" \
    "altfins_ohlc.sh <mode> [options]" \
    "Modes:
  snapshot    Get latest OHLCV data for one or more symbols
  history     Get historical OHLCV data for a single symbol

Snapshot Options:
  --symbols <json>        JSON array of symbols, e.g. '[\"BTC\",\"ETH\"]' (required)
  --interval <interval>   MINUTES15|HOURLY|HOURS4|HOURS12|DAILY (default: DAILY)

History Options:
  --symbol <symbol>       Single symbol, e.g. BTC (required)
  --interval <interval>   MINUTES15|HOURLY|HOURS4|HOURS12|DAILY (default: DAILY)
  --from <iso-date>       Start date in ISO 8601 format
  --to <iso-date>         End date in ISO 8601 format
  --days <n>              Shorthand: fetch last N days (default: 30)
  --page <n>              Page number (default: 0)
  --size <n>              Page size (default: 100)
  --all                   Fetch all pages (up to 10 pages)
  --help                  Show this help"
}

[[ $# -eq 0 ]] && usage

mode="$1"; shift

case "$mode" in
  snapshot)
    symbols=""
    interval="DAILY"

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --symbols)   symbols="$2"; shift 2 ;;
        --interval)  interval="$2"; shift 2 ;;
        --help)      usage ;;
        *) echo "Error: unknown option '$1'" >&2; exit 1 ;;
      esac
    done

    if [[ -z "$symbols" ]]; then
      echo "Error: --symbols is required for snapshot mode" >&2
      exit 1
    fi

    validate_time_interval "$interval"

    payload=$(jq -n \
      --argjson symbols "$symbols" \
      --arg interval "$interval" \
      '{symbols: $symbols, timeInterval: $interval}')

    make_checked_request "POST" "/ohlcv/snapshot-requests" "OHLC snapshot" "$payload"
    ;;

  history)
    symbol=""
    interval="DAILY"
    from_date=""
    to_date=""
    days=30
    page=0
    size=100
    fetch_all=false

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --symbol)    symbol="$2"; shift 2 ;;
        --interval)  interval="$2"; shift 2 ;;
        --from)      from_date="$2"; shift 2 ;;
        --to)        to_date="$2"; shift 2 ;;
        --days)      days="$2"; shift 2 ;;
        --page)      page="$2"; shift 2 ;;
        --size)      size="$2"; shift 2 ;;
        --all)       fetch_all=true; shift ;;
        --help)      usage ;;
        *) echo "Error: unknown option '$1'" >&2; exit 1 ;;
      esac
    done

    if [[ -z "$symbol" ]]; then
      echo "Error: --symbol is required for history mode" >&2
      exit 1
    fi

    validate_time_interval "$interval"

    # Default date range: last N days
    if [[ -z "$from_date" ]]; then
      from_date=$(iso_date "$days")
    fi
    if [[ -z "$to_date" ]]; then
      to_date=$(iso_date 0)
    fi

    payload=$(jq -n \
      --arg symbol "$symbol" \
      --arg interval "$interval" \
      --arg from "$from_date" \
      --arg to "$to_date" \
      '{symbol: $symbol, timeInterval: $interval, from: $from, to: $to}')

    if [[ "$fetch_all" == true ]]; then
      paginate_request "/ohlcv/history-requests" "$payload" "OHLC history"
    else
      make_checked_request "POST" "/ohlcv/history-requests?page=${page}&size=${size}" "OHLC history" "$payload"
    fi
    ;;

  *)
    echo "Error: unknown mode '${mode}'. Use 'snapshot' or 'history'" >&2
    exit 1
    ;;
esac
