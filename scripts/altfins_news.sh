#!/usr/bin/env bash
set -euo pipefail

# altfins_news.sh — Get AI-generated crypto news summaries
#
# Two modes:
#   search: Get paginated news summaries with date filtering
#   find:   Find a specific news summary by criteria

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_news.sh" \
    "Get AI-generated crypto news summaries" \
    "altfins_news.sh <mode> [options]" \
    "Modes:
  search    Get paginated news summaries
  find      Find a specific news summary

Search Options:
  --from <iso-date>       Start date in ISO 8601 format
  --to <iso-date>         End date in ISO 8601 format
  --days <n>              Shorthand: fetch last N days (default: 7)
  --page <n>              Page number (default: 0)
  --size <n>              Page size (default: 20)
  --all                   Fetch all pages

Find Options:
  --from <iso-date>       Start date in ISO 8601 format
  --to <iso-date>         End date in ISO 8601 format
  --days <n>              Shorthand: fetch last N days (default: 1)
  --help                  Show this help"
}

[[ $# -eq 0 ]] && usage

mode="$1"; shift

case "$mode" in
  search)
    from_date=""
    to_date=""
    days=7
    page=0
    size=20
    fetch_all=false

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --from)  from_date="$2"; shift 2 ;;
        --to)    to_date="$2"; shift 2 ;;
        --days)  days="$2"; shift 2 ;;
        --page)  page="$2"; shift 2 ;;
        --size)  size="$2"; shift 2 ;;
        --all)   fetch_all=true; shift ;;
        --help)  usage ;;
        *) echo "Error: unknown option '$1'" >&2; exit 1 ;;
      esac
    done

    if [[ -z "$from_date" ]]; then
      from_date=$(iso_date "$days")
    fi
    if [[ -z "$to_date" ]]; then
      to_date=$(iso_date 0)
    fi

    payload=$(jq -n \
      --arg from "$from_date" \
      --arg to "$to_date" \
      '{fromDate: $from, toDate: $to}')

    if [[ "$fetch_all" == true ]]; then
      paginate_request "/news-summary/search-requests" "$payload" "news summary search"
    else
      make_checked_request "POST" "/news-summary/search-requests?page=${page}&size=${size}" "news summary search" "$payload"
    fi
    ;;

  find)
    from_date=""
    to_date=""
    days=1

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --from)  from_date="$2"; shift 2 ;;
        --to)    to_date="$2"; shift 2 ;;
        --days)  days="$2"; shift 2 ;;
        --help)  usage ;;
        *) echo "Error: unknown option '$1'" >&2; exit 1 ;;
      esac
    done

    if [[ -z "$from_date" ]]; then
      from_date=$(iso_date "$days")
    fi
    if [[ -z "$to_date" ]]; then
      to_date=$(iso_date 0)
    fi

    payload=$(jq -n \
      --arg from "$from_date" \
      --arg to "$to_date" \
      '{fromDate: $from, toDate: $to}')

    make_checked_request "POST" "/news-summary/find-summary" "find news summary" "$payload"
    ;;

  *)
    echo "Error: unknown mode '${mode}'. Use 'search' or 'find'" >&2
    exit 1
    ;;
esac
