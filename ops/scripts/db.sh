#!/usr/bin/env sh
set -eu

STACK_ENV="${STACK_ENV:-dev}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)
STACK_COMPOSE_FILE="${ROOT_DIR}/ops/compose/compose.yml"
STACK_ENV_FILE="${ROOT_DIR}/env/${STACK_ENV}/stack/compose.env"

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing file: $1" >&2
    exit 1
  fi
}

run_compose() {
  require_file "$STACK_ENV_FILE"
  docker compose --env-file "$STACK_ENV_FILE" -f "$STACK_COMPOSE_FILE" "$@"
}

case "${1:-}" in
  seeds)
    shift
    run_compose exec web bundle exec rails db:seed "$@"
    ;;
  projects/clean)
    shift
    run_compose exec web bundle exec rails runner 'Notification.delete_all; VideoTypeSelection.delete_all; Project.delete_all'
    ;;
  console)
    shift
    run_compose exec web bundle exec rails console "$@"
    ;;
  *)
    echo "Usage: db.sh {seeds|projects/clean|console}" >&2
    exit 1
    ;;
esac
