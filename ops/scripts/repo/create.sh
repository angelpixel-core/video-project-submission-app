#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../../.." && pwd)

load_env_file() {
  [ -f "$1" ] || return 0
  set -a
  . "$1"
  set +a
}

load_env_file "${ROOT_DIR}/ops/repo/create.env"
load_env_file "${ROOT_DIR}/ops/repo/create.local.env"

REPO_PROVIDER="${REPO_PROVIDER:-github}"
REPO_HOST="${REPO_HOST:-github.com}"
REPO_WEB_BASE_URL="${REPO_WEB_BASE_URL:-https://${REPO_HOST}}"
REPO_API_BASE_URL="${REPO_API_BASE_URL:-}"

OWNER="${OWNER:-${REPO_OWNER:-}}"
NAME="${NAME:-${REPO_NAME:-}}"
DESCRIPTION="${DESCRIPTION:-${REPO_DESCRIPTION:-}}"
LICENSE="${LICENSE:-${REPO_LICENSE:-}}"
PRIVATE="${PRIVATE:-${REPO_PRIVATE:-true}}"
PUBLIC="${PUBLIC:-${REPO_PUBLIC:-false}}"

usage() {
  cat <<'EOF'
Usage: sh ops/scripts/repo/create.sh

Defaults are loaded from ops/repo/create.env and ops/repo/create.local.env.
This profile is repository provisioning metadata, not an application runtime env.
You can override them with OWNER, NAME, DESCRIPTION, LICENSE, PRIVATE, PUBLIC, REPO_PROVIDER, REPO_HOST, REPO_WEB_BASE_URL, REPO_API_BASE_URL, and REPO_GIT_REMOTE_URL.

Creates or configures a repository using the selected provider adapter.
EOF
}

if [ -z "$OWNER" ] || [ -z "$NAME" ]; then
  usage >&2
  exit 1
fi

if [ "$PRIVATE" = "true" ] && [ "$PUBLIC" = "true" ]; then
  echo "PRIVATE and PUBLIC cannot both be true" >&2
  exit 1
fi

REPO="${OWNER}/${NAME}"
HOMEPAGE="${REPO_WEB_BASE_URL}/${REPO}"
REPO_GIT_REMOTE_URL="${REPO_GIT_REMOTE_URL:-${REPO_WEB_BASE_URL}/${REPO}.git}"

command -v gh >/dev/null 2>&1 || {
  echo "gh is required" >&2
  exit 1
}

case "$REPO_PROVIDER" in
  github)
    command -v gh >/dev/null 2>&1 || {
      echo "gh is required for REPO_PROVIDER=github" >&2
      exit 1
    }

    if gh repo view "$REPO" >/dev/null 2>&1; then
      echo "Repository already exists: $REPO"
    else
      if [ "$PUBLIC" = "true" ] || [ "$PRIVATE" = "false" ]; then
        set -- repo create "$REPO" --homepage "$HOMEPAGE" --public
      else
        set -- repo create "$REPO" --homepage "$HOMEPAGE" --private
      fi

      if [ -n "$DESCRIPTION" ]; then
        set -- "$@" --description "$DESCRIPTION"
      fi

      if [ -n "$LICENSE" ]; then
        set -- "$@" --license "$LICENSE"
      fi

      gh "$@"
    fi

    ;;
  gitlab|bitbucket)
    echo "REPO_PROVIDER=$REPO_PROVIDER is not implemented yet" >&2
    exit 1
    ;;
  *)
    echo "Unsupported REPO_PROVIDER: $REPO_PROVIDER" >&2
    exit 1
    ;;
esac

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE_URL="${REPO_GIT_REMOTE_URL:-${REPO_WEB_BASE_URL}/${REPO}.git}"

  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REMOTE_URL"
  else
    git remote add origin "$REMOTE_URL"
  fi

  echo "Configured origin -> $REMOTE_URL"
else
  echo "Not inside a git repository; skipping remote configuration"
fi
