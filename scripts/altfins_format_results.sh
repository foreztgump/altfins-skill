#!/usr/bin/env bash
set -euo pipefail

# altfins_format_results.sh — Format altFINS JSON results for human consumption
#
# Transforms raw JSON API responses into readable summaries.
# Reads from file or stdin (pipe from other scripts).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

usage() {
  show_help "altfins_format_results.sh" \
    "Format altFINS JSON results into human-readable output" \
    "altfins_format_results.sh --type <type> [options] [file]" \
    "Options:
  --type <type>           Result type: screener|ohlc|analytics|signals|ta|news (required)
  --top <n>               Show only top N results (default: all)
  --format <fmt>          Output format: summary|full|csv (default: summary)
  --help                  Show this help

Examples:
  scripts/altfins_screener.sh ... | scripts/altfins_format_results.sh --type screener --top 10
  scripts/altfins_signals.sh ... | scripts/altfins_format_results.sh --type signals --top 5
  scripts/altfins_format_results.sh --type ohlc --format csv results.json"
}

# Defaults
result_type=""
top=0
format="summary"
input_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)    result_type="$2"; shift 2 ;;
    --top)     top="$2"; shift 2 ;;
    --format)  format="$2"; shift 2 ;;
    --help)    usage ;;
    -*)
      echo "Error: unknown option '$1'" >&2
      exit 1 ;;
    *)
      input_file="$1"; shift ;;
  esac
done

if [[ -z "$result_type" ]]; then
  echo "Error: --type is required" >&2
  exit 1
fi

# Read input from file or stdin
if [[ -n "$input_file" ]]; then
  input=$(cat "$input_file")
else
  input=$(cat)
fi

# Validate JSON
if ! echo "$input" | jq '.' > /dev/null 2>&1; then
  echo "Error: invalid JSON input" >&2
  exit 1
fi

# Extract content array from paginated response
content=$(echo "$input" | jq 'if .content then .content else . end')
total=$(echo "$input" | jq '.totalElements // (if type == "array" then length else 1 end)')

# Apply top limit
if [[ "$top" -gt 0 ]]; then
  content=$(echo "$content" | jq --argjson n "$top" '
    if type == "array" then .[:$n] else . end
  ')
fi

case "${result_type}" in
  screener)
    case "$format" in
      summary)
        echo "$content" | jq -r '
          if type == "array" then
            .[] | "[\(.symbol)] \(.name) — $\(.lastPrice // "N/A")"
          else
            "[\(.symbol)] \(.name) — $\(.lastPrice // "N/A")"
          end'
        echo ""
        echo "Total: ${total} assets"
        ;;
      full)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "=== \(.symbol) — \(.name) ===",
          "  Price: $\(.lastPrice // "N/A")",
          (if .additionalData then
            (.additionalData | to_entries[] | "  \(.key): \(.value)")
          else empty end),
          ""'
        echo "Total: ${total} assets"
        ;;
      csv)
        echo "symbol,name,lastPrice"
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "\(.symbol),\(.name // "" | gsub(","; " ")),\(.lastPrice // "")"'
        ;;
    esac
    ;;

  ohlc)
    case "$format" in
      summary)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "[\(.symbol)] \(.time // "N/A") O:\(.open // "N/A") H:\(.high // "N/A") L:\(.low // "N/A") C:\(.close // "N/A") V:\(.volume // "N/A")"'
        echo ""
        echo "Total: ${total} candles"
        ;;
      csv)
        echo "symbol,time,open,high,low,close,volume"
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "\(.symbol),\(.time),\(.open),\(.high),\(.low),\(.close),\(.volume)"'
        ;;
      *)
        echo "$content" | jq '.'
        ;;
    esac
    ;;

  analytics)
    case "$format" in
      summary)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "[\(.symbol)] \(.time // "N/A") = \(.value // .nonNumericalValue // "N/A")"'
        echo ""
        echo "Total: ${total} data points"
        ;;
      csv)
        echo "symbol,time,value,nonNumericalValue"
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "\(.symbol),\(.time),\(.value // ""),\(.nonNumericalValue // "")"'
        ;;
      *)
        echo "$content" | jq '.'
        ;;
    esac
    ;;

  signals)
    case "$format" in
      summary)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "[\(.symbol)] \(.direction) — \(.signalName) @ $\(.lastPrice // "N/A") (\(.timestamp // "N/A" | split("T")[0] // .))"'
        echo ""
        echo "Total: ${total} signals"
        ;;
      full)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "=== \(.symbol) (\(.symbolName // .symbol)) ===",
          "  Signal: \(.signalName)",
          "  Direction: \(.direction)",
          "  Price: $\(.lastPrice // "N/A")",
          "  Market Cap: $\(.marketCap // "N/A")",
          "  Price Change: \(.priceChange // "N/A")%",
          "  Time: \(.timestamp // "N/A")",
          ""'
        echo "Total: ${total} signals"
        ;;
      csv)
        echo "symbol,direction,signalName,lastPrice,marketCap,priceChange,timestamp"
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "\(.symbol),\(.direction),\(.signalName // "" | gsub(","; " ")),\(.lastPrice // ""),\(.marketCap // ""),\(.priceChange // ""),\(.timestamp // "")"'
        ;;
    esac
    ;;

  ta)
    case "$format" in
      summary)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "[\(.symbol)] \(.friendlyName // .symbol) — \(.nearTermOutlook // "N/A") | Pattern: \(.patternType // "N/A") (\(.patternStage // "N/A")) | Updated: \(.updatedDate // "N/A" | split("T")[0] // .)"'
        echo ""
        echo "Total: ${total} analyses"
        ;;
      full)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "=== \(.symbol) — \(.friendlyName // .symbol) ===",
          "  Outlook: \(.nearTermOutlook // "N/A")",
          "  Pattern: \(.patternType // "N/A") (\(.patternStage // "N/A"))",
          "  Updated: \(.updatedDate // "N/A")",
          "  Chart: \(.imgChartUrl // "N/A")",
          "",
          "  \(.description // "No description available")",
          "",
          "---",
          ""'
        echo "Total: ${total} analyses"
        ;;
      *)
        echo "$content" | jq '.'
        ;;
    esac
    ;;

  news)
    case "$format" in
      summary)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "[\(.sourceName // "Unknown")] \(.title // "No title") (\(.timestamp // "N/A" | split("T")[0] // .))"'
        echo ""
        echo "Total: ${total} articles"
        ;;
      full)
        echo "$content" | jq -r '
          if type == "array" then .[] else . end |
          "=== \(.title // "No title") ===",
          "  Source: \(.sourceName // "Unknown")",
          "  Date: \(.timestamp // "N/A")",
          "  URL: \(.url // "N/A")",
          "",
          "  \(.content // "No content available")",
          "",
          "---",
          ""'
        echo "Total: ${total} articles"
        ;;
      *)
        echo "$content" | jq '.'
        ;;
    esac
    ;;

  *)
    echo "Error: unknown type '${result_type}'. Use: screener, ohlc, analytics, signals, ta, news" >&2
    exit 1
    ;;
esac
