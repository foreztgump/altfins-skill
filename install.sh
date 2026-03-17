#!/usr/bin/env bash
set -euo pipefail

# install.sh — Install altfins-skill scripts and verify prerequisites

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "altfins-skill installer"
echo "======================="
echo ""

# Check prerequisites
errors=0

if ! command -v curl &>/dev/null; then
  echo "[FAIL] curl not found. Install: sudo apt install curl"
  errors=$((errors + 1))
else
  echo "[OK]   curl $(curl --version | head -1 | awk '{print $2}')"
fi

if ! command -v jq &>/dev/null; then
  echo "[FAIL] jq not found. Install: sudo apt install jq"
  errors=$((errors + 1))
else
  echo "[OK]   jq $(jq --version)"
fi

if [[ -z "${ALTFINS_API_KEY:-}" ]]; then
  echo "[WARN] ALTFINS_API_KEY not set. Add to your shell profile:"
  echo "       export ALTFINS_API_KEY='your_key_here'"
else
  echo "[OK]   ALTFINS_API_KEY is set"
fi

echo ""

if [[ "$errors" -gt 0 ]]; then
  echo "Please install missing prerequisites and re-run."
  exit 1
fi

# Make scripts executable
chmod +x "${SCRIPT_DIR}"/scripts/altfins_*.sh
echo "Scripts made executable."

# Create symlinks
mkdir -p ~/.local/bin
for f in "${SCRIPT_DIR}"/scripts/altfins_*.sh; do
  name=$(basename "$f")
  ln -sf "$f" ~/.local/bin/"$name"
done
echo "Symlinked to ~/.local/bin/"

# Create config directory
mkdir -p ~/.config/altfins-skill/cache
echo "Config directory created at ~/.config/altfins-skill/"

echo ""
echo "Installation complete!"
echo "Ensure ~/.local/bin is in your PATH."
echo ""
echo "Test with: altfins_enums.sh symbols | jq length"
