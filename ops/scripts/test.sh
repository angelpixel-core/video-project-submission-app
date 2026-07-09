#!/usr/bin/env sh
set -eu

TEST_ENV="${TEST_ENV:-test}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)
TEST_STACK_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/stack/compose.env"
TEST_APP_CORE_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/app/core.env"
TEST_APP_DB_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/app/db.env"

IMAGE_NAME="${IMAGE_NAME:-video-project-submission-app:test}"

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing file: $1" >&2
    exit 1
  fi
}

load_env_file() {
  file="$1"
  [ -f "$file" ] || return 0
  set -a
  . "$file"
  set +a
}

build_image() {
  require_file "$TEST_STACK_ENV_FILE"
  docker build \
    --file "${ROOT_DIR}/ops/containers/app/Dockerfile" \
    --target test \
    --build-arg "RUBY_VERSION=${RUBY_VERSION:-4.0.3}" \
    --tag "$IMAGE_NAME" \
    "$ROOT_DIR"
}

run_in_image() {
  command="$1"
  shift

  load_env_file "$TEST_APP_CORE_ENV_FILE"
  load_env_file "$TEST_APP_DB_ENV_FILE"

  docker run --rm \
    --env "RAILS_ENV=${RAILS_ENV:-test}" \
    --env "RAILS_LOG_TO_STDOUT=${RAILS_LOG_TO_STDOUT:-true}" \
    --env "DATABASE_URL=${DATABASE_URL:-}" \
    --env "MYSQL_HOST=${MYSQL_HOST:-db}" \
    --env "MYSQL_PORT=${MYSQL_PORT:-3306}" \
    "$IMAGE_NAME" \
    sh -lc "$command" sh "$@"
}

case "${1:-}" in
  build)
    build_image
    ;;
  verify)
    build_image
    run_in_image 'bundle exec ruby -e "require \"./config/environment\"; puts Rails.env"'
    ;;
  rspec)
    build_image
    run_in_image 'bundle exec rspec "$@"' "$@"
    ;;
  *)
    echo "Usage: test.sh {build|verify|rspec}" >&2
    exit 1
    ;;
esac
