#!/usr/bin/env sh
set -e

echo "Waiting for MySQL..."

for i in 1 2 3 4 5 6 7 8 9 10; do
  if nc -z "${MYSQL_HOST:-db}" "${MYSQL_PORT:-3306}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
  if [ "$i" = "10" ]; then
    echo "MySQL not ready"
    exit 1
  fi
done

if [ -f /app/bin/rails ]; then
  bundle exec rails db:prepare
fi

exec "$@"
