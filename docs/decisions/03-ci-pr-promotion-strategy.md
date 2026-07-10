---
id: ci-pr-promotion-strategy
title: CI PR Promotion Strategy
phase: decisions
order: 3
aliases: []
tags:
  - decisions
  - ci
  - cd
  - pull-request
  - github-actions
---

# CI PR Promotion Strategy

## Decision

Use a normal pull request from `work-items/*` into `development` as the gate between fast push checks and the merge/deploy lane.

## Strategy

- A green push to `work-items/*` creates or updates a normal PR to `development`.
- The PR is not drafted; visibility and required checks come from branch protection.
- `development` is protected with required status checks and required approvals.
- PR creation uses a dedicated repository secret token such as `WORKITEM_PR_SYNC_TOKEN` so the resulting PR can trigger the normal `pull_request` workflow.
- Older runs for the same branch are cancelled when a newer push arrives.
- Auto-merge is deferred until branch protection and review policy are fully in place.

## Rationale

- Draft PRs reduce visibility and block review/automation.
- Branch protection is the correct mechanism for merge control.
- A dedicated token avoids relying on `GITHUB_TOKEN` for PR creation, which can suppress downstream workflow triggering.
- Cancelling obsolete runs saves runner time when a branch receives a newer push.

## Notes

- The token should be provisioned as a repository secret, preferably a fine-grained PAT or GitHub App token with `pull_requests: write` and the minimum required repo scope.
- Branch protection/ruleset configuration lives in GitHub settings unless later codified separately.
