---
id: ssh-authentication-and-commit-signing
aliases: []
tags:
  - work-items
  - ssh
  - signing
  - authentication
  - github
depends_on:
  - ci-cd-and-environments
order: 5
phase: work-items
status: draft
title: SSH Authentication and Commit Signing
---

# SSH Authentication and Commit Signing

## Goal

- [ ] Document and apply the local SSH authentication and commit-signing setup using separate keys for auth and signing.

## Scope

- SSH authentication for GitHub access.
- SSH commit signing for Git history verification.
- Git configuration for signing commits by default.
- GitHub registration of the signing public key.

## Affected Docs

- `docs/decisions/04-ssh-authentication-and-commit-signing.md`
- `docs/decisions/index.md`
- `docs/overview.md`

## Affected Ops

- `~/.ssh/config`
- `~/.ssh/company/repositories/github/<org>/<repo>/<auth-key>`
- `~/.ssh/company/repositories/github/<org>/<repo>/<signing-key>`
- global `git config`

## Checklist

- [ ] Keep the GitHub authentication key separate from the commit-signing key.
- [ ] Register the signing public key in GitHub as a signing key.
- [ ] Configure `git config --global gpg.format ssh`.
- [ ] Configure `git config --global user.signingkey <placeholder-signing-key>.pub`.
- [ ] Configure `git config --global commit.gpgsign true`.
- [ ] Optionally configure `gpg.ssh.allowedSignersFile` for local verification.
- [ ] Verify signed commits with `git log --show-signature -1`.

## Validation

- [ ] `ssh -T <github-host-alias>` succeeds with the auth key.
- [ ] `git log --show-signature -1` reports a verified signature on the latest commit.
- [ ] GitHub shows `Verified` for a signed commit.
- [ ] Local verification works if `gpg.ssh.allowedSignersFile` is configured.

## Notes

- Use placeholders in examples when documenting email addresses.
- Prefer SSH signing over GPG for this repository to keep the setup simpler.
- Reuse the auth key only if there is a specific operational reason to do so; otherwise keep the signing key separate.
- This work item supports the PR automation path in `docs/work-items/003-ci-cd-and-environments.md` by making the signing/auth setup explicit and reproducible.
