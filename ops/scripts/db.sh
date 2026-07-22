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
  maintenance/reset_project_data)
    shift
    run_compose exec web env DRY_RUN="${DRY_RUN:-}" CONFIRM="${CONFIRM:-}" bundle exec rake maintenance:reset_project_data "$@"
    ;;
  console)
    shift
    run_compose exec web bundle exec rails console "$@"
    ;;
  *)
    echo "Usage: db.sh {seeds|maintenance/reset_project_data|console}" >&2
    exit 1
    ;;
esac
