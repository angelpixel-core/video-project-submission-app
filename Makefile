STACK_ENV ?= dev
STACK_SCRIPT := ops/scripts/stack.sh
DB_SCRIPT := ops/scripts/db.sh
SECRETS_SCRIPT := ops/scripts/secrets.sh
REPO_SCRIPT := ops/scripts/repo/create.sh
TEST_SCRIPT := ops/scripts/test.sh
TEST_ARGS ?=
ENV ?= $(STACK_ENV)

.PHONY: stack/%
stack/%:
	@STACK_ENV="$(STACK_ENV)" sh $(STACK_SCRIPT) "$*"

.PHONY: secrets/%
secrets/%:
	@ENV="$(ENV)" TARGET="$(TARGET)" SECRET_NAME="$(SECRET_NAME)" SECRET_VALUE="$(SECRET_VALUE)" RENDER_API_KEY="$(RENDER_API_KEY)" RENDER_SERVICE_ID="$(RENDER_SERVICE_ID)" RENDER_OWNER_ID="$(RENDER_OWNER_ID)" RENDER_QA_ADOPTED_WEB_SERVICE_ID="$(RENDER_QA_ADOPTED_WEB_SERVICE_ID)" RENDER_QA_ADOPTED_DATABASE_ID="$(RENDER_QA_ADOPTED_DATABASE_ID)" RENDER_QA_ADOPTED_ENVIRONMENT_ID="$(RENDER_QA_ADOPTED_ENVIRONMENT_ID)" RENDER_QA_SERVICE_ID="$(RENDER_QA_SERVICE_ID)" RENDER_STAGING_SERVICE_ID="$(RENDER_STAGING_SERVICE_ID)" RENDER_PROD_SERVICE_ID="$(RENDER_PROD_SERVICE_ID)" RENDER_QA_ENVIRONMENT_ID="$(RENDER_QA_ENVIRONMENT_ID)" RENDER_STAGING_ENVIRONMENT_ID="$(RENDER_STAGING_ENVIRONMENT_ID)" RENDER_PROD_ENVIRONMENT_ID="$(RENDER_PROD_ENVIRONMENT_ID)" RAILS_MASTER_KEY="$(RAILS_MASTER_KEY)" MYSQL_PASSWORD="$(MYSQL_PASSWORD)" POSTGRES_PASSWORD="$(POSTGRES_PASSWORD)" DATABASE_PASSWORD="$(DATABASE_PASSWORD)" GITHUB_REPOSITORY="$(GITHUB_REPOSITORY)" sh $(SECRETS_SCRIPT) "$*"

.PHONY: repo/create
repo/create:
	@OWNER="$(OWNER)" NAME="$(NAME)" DESCRIPTION="$(DESCRIPTION)" LICENSE="$(LICENSE)" PRIVATE="$(PRIVATE)" PUBLIC="$(PUBLIC)" REPO_PROVIDER="$(REPO_PROVIDER)" REPO_HOST="$(REPO_HOST)" REPO_WEB_BASE_URL="$(REPO_WEB_BASE_URL)" REPO_API_BASE_URL="$(REPO_API_BASE_URL)" REPO_GIT_REMOTE_URL="$(REPO_GIT_REMOTE_URL)" REPO_OWNER="$(REPO_OWNER)" REPO_NAME="$(REPO_NAME)" REPO_DESCRIPTION="$(REPO_DESCRIPTION)" REPO_LICENSE="$(REPO_LICENSE)" REPO_PRIVATE="$(REPO_PRIVATE)" REPO_PUBLIC="$(REPO_PUBLIC)" sh $(REPO_SCRIPT)

.PHONY: db/seeds
db/seeds:
	@STACK_ENV="$(STACK_ENV)" sh $(DB_SCRIPT) seeds

.PHONY: db/projects/clean
db/projects/clean:
	@STACK_ENV="$(STACK_ENV)" sh $(DB_SCRIPT) projects/clean

.PHONY: web/console
web/console:
	@STACK_ENV="$(ENV)" sh $(DB_SCRIPT) console

.PHONY: test/unit
test/unit:
	@TEST_ENV="$(TEST_ENV)" TEST_ARGS="spec/unit" sh $(TEST_SCRIPT) rspec

.PHONY: test/integration
test/integration:
	@TEST_ENV="$(TEST_ENV)" TEST_ARGS="spec/contracts spec/integration spec/requests" sh $(TEST_SCRIPT) rspec

.PHONY: test/smoke
test/smoke:
	@TEST_ENV="$(TEST_ENV)" TEST_ARGS="spec/smoke" sh $(TEST_SCRIPT) rspec

.PHONY: test/acceptance
test/acceptance:
	@TEST_ENV="$(TEST_ENV)" sh $(TEST_SCRIPT) cucumber

.PHONY: test/performance
test/performance:
	@TEST_ENV="$(TEST_ENV)" TEST_ARGS="spec/performance" sh $(TEST_SCRIPT) rspec

.PHONY: test/ci
test/ci: test/unit test/integration

.PHONY: test/qa
test/qa: test/smoke test/acceptance

.PHONY: test/all
test/all: test/unit test/integration test/smoke test/acceptance test/performance

.PHONY: lint/rubocop
lint/rubocop:
	@bin/rubocop -f github

.PHONY: lint/security/brakeman
lint/security/brakeman:
	@bin/brakeman --no-pager

.PHONY: lint/security/bundler-audit
lint/security/bundler-audit:
	@bin/bundler-audit

.PHONY: lint
lint: lint/rubocop lint/security/brakeman lint/security/bundler-audit

.PHONY: lint/fix/rubocop
lint/fix/rubocop:
	@bin/rubocop -A

.PHONY: lint/fix
lint/fix: lint/fix/rubocop

.PHONY: test/%
test/%:
	@TEST_ENV="$(TEST_ENV)" TEST_ARGS="$(TEST_ARGS)" sh $(TEST_SCRIPT) "$*"
