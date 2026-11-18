#!/usr/bin/env bash
# pre-commit hook: helm lint --strict + helm template for each chart touched
# by the staged files.
set -euo pipefail

mapfile -t charts < <(printf '%s\n' "$@" | cut -d/ -f1,2 | sort -u)
rc=0
for chart in "${charts[@]}"; do
    [ -f "$chart/Chart.yaml" ] || continue
    values=()
    for f in "$chart"/ci/*.yaml; do [ -e "$f" ] && values+=(-f "$f") && break; done
    helm lint --strict "$chart" "${values[@]}" >/dev/null || { helm lint --strict "$chart" "${values[@]}"; rc=1; }
    helm template "$chart" "${values[@]}" >/dev/null || rc=1
done
exit $rc
