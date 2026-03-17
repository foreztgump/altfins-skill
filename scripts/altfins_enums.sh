#!/usr/bin/env bash
set -euo pipefail

# altfins_enums.sh — Get reference data: symbols, intervals, permits
#
# Retrieves common enumeration data from the altFINS API.
# Use this to discover available symbols, time intervals, and API usage limits.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_enums.sh" \
    "Get reference data — symbols, intervals, and API usage permits" \
    "altfins_enums.sh <command>" \
    "Commands:
  symbols             List all available crypto symbols (2200+)
  intervals           List available time intervals
  permits             Show your current API usage limits (remaining permits)
  monthly-permits     Show monthly available permits
  all-permits         Show all available permits (detailed breakdown)
  --help              Show this help

Examples:
  altfins_enums.sh symbols          # Get all tradeable symbols
  altfins_enums.sh permits          # Check your API credit balance
  altfins_enums.sh intervals        # See available time intervals"
}

[[ $# -eq 0 ]] && usage

command="$1"; shift

# Use caching for reference data (symbols, intervals rarely change)
case "$command" in
  symbols)
    cache_key=$(cache_key_for "symbols")
    if cached=$(cache_get "$cache_key" 2>/dev/null); then
      echo "$cached"
    else
      result=$(make_checked_request "GET" "/symbols" "list symbols") || exit 1
      cache_set "$cache_key" "$result"
      echo "$result"
    fi
    ;;

  intervals)
    cache_key=$(cache_key_for "intervals")
    if cached=$(cache_get "$cache_key" 2>/dev/null); then
      echo "$cached"
    else
      result=$(make_checked_request "GET" "/intervals" "list intervals") || exit 1
      cache_set "$cache_key" "$result"
      echo "$result"
    fi
    ;;

  permits)
    make_checked_request "GET" "/available-permits" "get available permits"
    ;;

  monthly-permits)
    make_checked_request "GET" "/monthly-available-permits" "get monthly permits"
    ;;

  all-permits)
    make_checked_request "GET" "/all-available-permits" "get all permits"
    ;;

  --help)
    usage
    ;;

  *)
    echo "Error: unknown command '${command}'" >&2
    echo "Available commands: symbols, intervals, permits, monthly-permits, all-permits" >&2
    exit 1
    ;;
esac
