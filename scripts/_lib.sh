#!/usr/bin/env bash
# scripts/_lib.sh — shared functions for altFINS API scripts
# Source this file: source "${SCRIPT_DIR}/_lib.sh"
#
# Security summary:
#   - Single external endpoint: https://altfins.com/api/v2/public
#   - Only credential used: ALTFINS_API_KEY (via X-API-KEY header)
#   - Local writes: ~/.config/altfins-skill/ only (cache, history)
#   - No other env vars read, no other network calls

set -euo pipefail

# shellcheck disable=SC2034
readonly LIB_BASE_URL="https://altfins.com/api/v2/public"
readonly LIB_CONFIG_DIR="${HOME}/.config/altfins-skill"
readonly LIB_CACHE_DIR="${LIB_CONFIG_DIR}/cache"
readonly LIB_CACHE_MAX_AGE_SECONDS=300  # 5 minutes default

# Global set by make_api_request for callers to inspect
HTTP_CODE=""

# File used to persist HTTP_CODE across subshells
_LIB_HTTP_CODE_FILE="$(mktemp "${TMPDIR:-/tmp}/.altfins_http_code_XXXXXX")"
trap 'rm -f "$_LIB_HTTP_CODE_FILE"' EXIT

# --------------------------------------------------------------------------
# make_api_request <method> <path> [payload]
# Makes an authenticated API request to altFINS.
# Sets global HTTP_CODE. Outputs response body to stdout.
# Returns 0 always (caller checks HTTP_CODE via check_http_status).
# --------------------------------------------------------------------------
make_api_request() {
  local method="$1"
  local path="$2"
  local payload="${3:-}"
  local api_key="${ALTFINS_API_KEY:?Set ALTFINS_API_KEY}"

  local url="${LIB_BASE_URL}${path}"
  local curl_args=(-s -w "\n%{http_code}" -H "X-API-KEY: ${api_key}" -H "Accept: application/json")

  if [[ "$method" == "POST" ]]; then
    curl_args+=(-X POST -H "Content-Type: application/json" -d "$payload")
  fi

  local response
  if ! response=$(curl "${curl_args[@]}" "$url"); then
    echo "Error: network request failed" >&2
    HTTP_CODE="000"
    echo "$HTTP_CODE" > "$_LIB_HTTP_CODE_FILE"
    echo ""
    return 0
  fi

  HTTP_CODE=$(echo "$response" | tail -1)
  echo "$HTTP_CODE" > "$_LIB_HTTP_CODE_FILE"
  echo "$response" | sed '$d'
  return 0
}

# --------------------------------------------------------------------------
# _read_http_code — read HTTP_CODE from file (use after subshell calls)
# --------------------------------------------------------------------------
_read_http_code() {
  if [[ -f "$_LIB_HTTP_CODE_FILE" ]]; then
    HTTP_CODE=$(cat "$_LIB_HTTP_CODE_FILE")
  fi
}

# --------------------------------------------------------------------------
# check_http_status <http_code> <body> <action_description>
# Returns 0 on 200, 1 on any error. Prints error to stderr.
# --------------------------------------------------------------------------
check_http_status() {
  local http_code="$1"
  local body="$2"
  local action="$3"

  if ! [[ "$http_code" =~ ^[0-9]+$ ]]; then
    echo "Error: ${action} failed (invalid HTTP response)" >&2
    return 1
  fi

  if [[ "$http_code" -eq 200 ]]; then
    return 0
  fi

  if [[ "$http_code" -eq 401 ]]; then
    echo "Error: unauthorized — check your ALTFINS_API_KEY" >&2
    return 1
  fi

  if [[ "$http_code" -eq 403 ]]; then
    echo "Error: forbidden — your plan may not include this endpoint" >&2
    return 1
  fi

  if [[ "$http_code" -eq 429 ]]; then
    echo "Error: rate limit exceeded (HTTP 429). Try again later." >&2
    return 1
  fi

  local message
  message=$(echo "$body" | jq -r '.message // empty' 2>/dev/null)
  if [[ -n "$message" ]]; then
    echo "Error: ${action} failed (HTTP ${http_code}): ${message}" >&2
  else
    echo "Error: ${action} failed (HTTP ${http_code}): ${body:0:200}" >&2
  fi
  return 1
}

# --------------------------------------------------------------------------
# make_checked_request <method> <path> <action_description> [payload]
# Convenience: makes request and checks status in one call.
# Outputs body on success. Returns 1 on error (already printed to stderr).
# --------------------------------------------------------------------------
make_checked_request() {
  local method="$1"
  local path="$2"
  local action="$3"
  local payload="${4:-}"

  local body
  body=$(make_api_request "$method" "$path" "$payload")
  _read_http_code

  if ! check_http_status "$HTTP_CODE" "$body" "$action"; then
    return 1
  fi

  echo "$body"
}

# --------------------------------------------------------------------------
# paginate_request <path> <payload_template> <action> [max_pages]
# Fetches all pages of a paginated POST endpoint.
# payload_template must be valid JSON — page number is injected automatically.
# Outputs merged content array. max_pages defaults to 10.
# --------------------------------------------------------------------------
paginate_request() {
  local path="$1"
  local payload_template="$2"
  local action="$3"
  local max_pages="${4:-10}"

  local page=0
  local all_content="[]"

  while [[ "$page" -lt "$max_pages" ]]; do
    local body
    body=$(make_api_request "POST" "${path}?page=${page}&size=100" "$payload_template")
    _read_http_code

    if ! check_http_status "$HTTP_CODE" "$body" "${action} (page ${page})"; then
      if [[ "$page" -eq 0 ]]; then
        return 1
      fi
      break
    fi

    local page_content
    page_content=$(echo "$body" | jq '.content // []')
    all_content=$(echo "$all_content" "$page_content" | jq -s '.[0] + .[1]')

    local is_last
    is_last=$(echo "$body" | jq '.last // true')
    if [[ "$is_last" == "true" ]]; then
      break
    fi

    page=$((page + 1))
  done

  echo "$all_content"
}

# --------------------------------------------------------------------------
# cache_get <cache_key>
# Returns cached response if fresh (< LIB_CACHE_MAX_AGE_SECONDS). Exit 1 if miss.
# --------------------------------------------------------------------------
cache_get() {
  local cache_key="$1"
  local cache_file="${LIB_CACHE_DIR}/${cache_key}.json"

  if [[ ! -f "$cache_file" ]]; then
    return 1
  fi

  local now_epoch
  now_epoch=$(date -u +%s)
  local file_epoch
  file_epoch=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
  local age=$((now_epoch - file_epoch))

  if [[ "$age" -gt "$LIB_CACHE_MAX_AGE_SECONDS" ]]; then
    rm -f "$cache_file"
    return 1
  fi

  cat "$cache_file"
  return 0
}

# --------------------------------------------------------------------------
# cache_set <cache_key> <json_content>
# Stores response in cache. Atomic write via temp+mv.
# --------------------------------------------------------------------------
cache_set() {
  local cache_key="$1"
  local json_content="$2"

  mkdir -p "$LIB_CACHE_DIR"

  local tmp_file
  tmp_file=$(mktemp "${LIB_CACHE_DIR}/.cache_XXXXXX")

  if ! echo "$json_content" | jq '.' > "$tmp_file" 2>/dev/null; then
    rm -f "$tmp_file"
    return 1
  fi

  mv -f "$tmp_file" "${LIB_CACHE_DIR}/${cache_key}.json"
}

# --------------------------------------------------------------------------
# cache_key_for <string...>
# Generates a deterministic cache key from arguments.
# --------------------------------------------------------------------------
cache_key_for() {
  echo "$*" | md5sum | cut -d' ' -f1
}

# --------------------------------------------------------------------------
# validate_time_interval <interval>
# Returns 0 if valid, 1 if not. Prints error to stderr.
# --------------------------------------------------------------------------
validate_time_interval() {
  local interval="$1"
  case "$interval" in
    MINUTES15|HOURLY|HOURS4|HOURS12|DAILY) return 0 ;;
    *)
      echo "Error: invalid time interval '${interval}'. Must be one of: MINUTES15, HOURLY, HOURS4, HOURS12, DAILY" >&2
      return 1
      ;;
  esac
}

# --------------------------------------------------------------------------
# validate_signal_direction <direction>
# Returns 0 if valid, 1 if not.
# --------------------------------------------------------------------------
validate_signal_direction() {
  local direction="$1"
  case "$direction" in
    BULLISH|BEARISH|"") return 0 ;;
    *)
      echo "Error: invalid signal direction '${direction}'. Must be BULLISH or BEARISH" >&2
      return 1
      ;;
  esac
}

# --------------------------------------------------------------------------
# iso_date <days_ago>
# Outputs ISO 8601 date string for N days ago. 0 = today.
# --------------------------------------------------------------------------
iso_date() {
  local days_ago="${1:-0}"
  date -u -d "${days_ago} days ago" +"%Y-%m-%dT00:00:00.000Z"
}

# --------------------------------------------------------------------------
# format_number <value> [decimals]
# Formats a number with optional decimal places. Handles large numbers.
# --------------------------------------------------------------------------
format_number() {
  local value="$1"
  local decimals="${2:-2}"

  if [[ "$value" == "null" || -z "$value" ]]; then
    echo "N/A"
    return
  fi

  printf "%'.${decimals}f" "$value" 2>/dev/null || echo "$value"
}

# --------------------------------------------------------------------------
# show_help <script_name> <description> <usage> [options]
# Prints formatted help text and exits 0.
# --------------------------------------------------------------------------
show_help() {
  local script_name="$1"
  local description="$2"
  local usage="$3"
  local options="${4:-}"

  cat >&2 <<EOF
${script_name} — ${description}

Usage: ${usage}

${options}
Environment:
  ALTFINS_API_KEY    Required. Your altFINS API key.

EOF
  exit 0
}
