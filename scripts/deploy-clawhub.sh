#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Deploy (publish) skills/pricewin-deal-finder to ClawHub.
#
# Why this script: the ClawHub web form (clawhub.ai/submit) only accepts a
# SKILL.md at the source root, so this monorepo must publish via the CLI with an
# explicit path. The script also builds a clean bundle (git-tracked files only)
# so node_modules / native binaries never reach the upload.
#
# Auth (never commit the token):
#   export CLAWHUB_TOKEN=clh_xxx          # preferred, or
#   echo clh_xxx > .clawhub.token         # gitignored fallback
#
# Usage:
#   scripts/deploy-clawhub.sh --dry-run   # build + verify, no upload
#   scripts/deploy-clawhub.sh             # publish (version from package.json)
#   SKILL_VERSION=0.7.1 scripts/deploy-clawhub.sh   # override version (re-deploys must bump)
# ----------------------------------------------------------------------------
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SKILL_DIR="skills/pricewin-deal-finder"
REGISTRY="${CLAWHUB_REGISTRY:-https://clawhub.ai}"

DRY_RUN=0
case "${1:-}" in
  -n|--dry-run) DRY_RUN=1 ;;
  "") ;;
  *) echo "Unknown arg: $1 (use --dry-run or no arg)" >&2; exit 2 ;;
esac

# --- resolve token --------------------------------------------------------
if [[ -z "${CLAWHUB_TOKEN:-}" && -f .clawhub.token ]]; then
  CLAWHUB_TOKEN="$(tr -d '[:space:]' < .clawhub.token)"
fi
if [[ "$DRY_RUN" == 0 && -z "${CLAWHUB_TOKEN:-}" ]]; then
  echo "ERROR: CLAWHUB_TOKEN not set. export CLAWHUB_TOKEN=clh_... or create .clawhub.token" >&2
  exit 1
fi

# --- version --------------------------------------------------------------
VERSION="${SKILL_VERSION:-$(node -p "require('./$SKILL_DIR/package.json').version")}"

# --- build clean bundle (tracked files only → no node_modules) ------------
WORK="$(mktemp -d)"
STAGE="$WORK/pricewin-deal-finder"
mkdir -p "$STAGE"
git archive "HEAD:$SKILL_DIR" | tar -x -C "$STAGE"
cleanup() { rm -rf "$WORK"; [[ -n "${CFG:-}" ]] && rm -f "$CFG"; }
trap cleanup EXIT

if find "$STAGE" -name node_modules -type d | grep -q .; then
  echo "ERROR: bundle unexpectedly contains node_modules — aborting" >&2
  exit 1
fi

echo "Skill:   pricewin-deal-finder"
echo "Version: $VERSION"
echo "Bundle:  $STAGE ($(du -sh "$STAGE" | cut -f1))"
echo "Files:   $(find "$STAGE" -type f | wc -l | tr -d ' ')"

if [[ "$DRY_RUN" == 1 ]]; then
  echo "--- [dry-run] bundle contents ---"
  (cd "$STAGE" && find . -type f | sort)
  echo "[dry-run] OK — would publish to $REGISTRY as version $VERSION"
  exit 0
fi

# --- headless auth via temp config (does not touch your global clawhub login)
CFG="$(mktemp)"
printf '{"registry":"%s","token":"%s"}\n' "$REGISTRY" "$CLAWHUB_TOKEN" > "$CFG"
export CLAWHUB_CONFIG_PATH="$CFG"

echo "--- publishing to ClawHub ---"
npx --yes clawhub@0.21.0 skill publish "$STAGE" --version "$VERSION"
echo "✅ published pricewin-deal-finder@$VERSION → $REGISTRY"
