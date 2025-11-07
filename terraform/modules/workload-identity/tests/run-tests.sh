#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for fixture in github_actions binding_only; do
  FIXTURE_DIR="${SCRIPT_DIR}/${fixture}"
  echo "==> Validating ${fixture} fixture"
  terraform -chdir="${FIXTURE_DIR}" init -backend=false -input=false >/dev/null
  terraform -chdir="${FIXTURE_DIR}" validate >/dev/null
  echo "    ✔ ${fixture} validated"
  echo
done
