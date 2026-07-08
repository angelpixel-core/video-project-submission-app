STACK_ENV ?= dev
STACK_SCRIPT := ops/scripts/stack.sh

.PHONY: stack/%
stack/%:
	@STACK_ENV="$(STACK_ENV)" sh $(STACK_SCRIPT) "$*"
