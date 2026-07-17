# Video Project Submission App

## Local Hooks

Set up the repository-managed Git hooks:

```sh
make hooks/setup
```

The pre-push hook runs `make lint` before allowing a push.

Bypass the hook for emergencies only:

```sh
SKIP_LINT=1 git push
```
