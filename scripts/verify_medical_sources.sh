#!/usr/bin/env bash
# Verifies every URL in MedicalSourceCatalog.swift against the live web:
# HTTP 200, no redirect (url_effective == literal), host belongs to the entry's
# publisher, and the page is not a soft 404 (who.int answers 200 with <title>404).
set -uo pipefail

CATALOG="$(cd "$(dirname "$0")/.." && pwd)/Momsy/Core/MedicalSources/Data/MedicalSourceCatalog.swift"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

host_for() {
  case "$1" in
    who) echo "www.who.int" ;;
    nhs) echo "www.nhs.uk" ;;
    aap) echo "www.healthychildren.org" ;;
    *)   echo "" ;;
  esac
}

failures=0
checked=0
publisher=""

# Entries list `publisher: .x` before `url: URL(string: "…")`, so the last seen
# publisher owns the next URL.
while IFS= read -r line; do
  if [[ "$line" =~ publisher:\ \.([a-zA-Z]+) ]]; then
    publisher="${BASH_REMATCH[1]}"
  fi
  if [[ "$line" =~ URL\(string:\ \"([^\"]+)\"\) ]]; then
    url="${BASH_REMATCH[1]}"
    checked=$((checked + 1))
    expected_host="$(host_for "$publisher")"
    host="$(echo "$url" | sed -E 's#^https://([^/]+)/.*#\1#')"
    result="$(curl -sSL -A "$UA" -o "$TMP" -w "%{http_code} %{url_effective}" --max-time 20 "$url" 2>/dev/null)"
    code="${result%% *}"
    effective="${result#* }"
    title="$(tr '\n' ' ' < "$TMP" | grep -oE '<title>[^<]*' | head -1 | sed -E 's/<title>[[:space:]]*//')"

    reason=""
    [[ "$url" == https://* ]] || reason="not https"
    [[ -z "$reason" && -z "$expected_host" ]] && reason="publisher .$publisher must not have a URL"
    [[ -z "$reason" && "$host" != "$expected_host" ]] && reason="host $host != $expected_host (.$publisher)"
    [[ -z "$reason" && "$code" != "200" ]] && reason="HTTP $code"
    [[ -z "$reason" && "$effective" != "$url" ]] && reason="redirects to $effective"
    [[ -z "$reason" && "$title" =~ ^(404|Page not found) ]] && reason="soft 404 (title: $title)"

    if [[ -n "$reason" ]]; then
      echo "FAIL $url — $reason"
      failures=$((failures + 1))
    else
      echo "ok   $code $url"
    fi
  fi
done < "$CATALOG"

echo "Checked $checked URL(s), $failures failure(s)."
[[ $checked -gt 0 && $failures -eq 0 ]]
