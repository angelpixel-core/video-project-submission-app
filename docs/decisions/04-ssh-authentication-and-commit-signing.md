---
id: ssh-authentication-and-commit-signing
title: SSH Authentication and Commit Signing
phase: decisions
order: 4
aliases: []
tags:
  - decisions
  - ssh
  - signing
  - authentication
  - github
---

# SSH Authentication and Commit Signing

## Decision

Use one SSH key for GitHub authentication and a separate SSH key for Git commit signing.

## Scope

- SSH authentication for repository access and `ssh -T` verification.
- SSH signing for Git commit signatures.
- No GPG signing in the current setup.

## Strategy

- Keep the authentication key loaded in `ssh-agent` for normal Git over SSH usage.
- Configure Git commit signing with a dedicated signing key.
- Register the signing public key in GitHub as a signing key.
- Keep the auth and signing keys separate so their purposes stay clear.

## Recommended Local Flow

### Authentication

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/company/repositories/github/<org>/<repo>/<auth-key>
ssh -T <github-host-alias>
```

Example SSH config:

```sshconfig
Host <github-host-alias>
  HostName github.com
  User git
  PreferredAuthentications publickey
  IdentitiesOnly yes
  IdentityFile ~/.ssh/company/repositories/github/<org>/<repo>/<auth-key>
```

### Commit Signing

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/company/repositories/github/<org>/<repo>/<signing-key>.pub
git config --global commit.gpgsign true
```

Register the signing public key in GitHub:

- `Settings`
- `SSH and GPG keys`
- `New SSH key`
- `Key type: Signing key`
- Paste the contents of `<signing-key>.pub`

## Verification

```bash
git config --get gpg.format
git config --get user.signingkey
git config --get commit.gpgsign
git log --show-signature -1
```

Optional local verification setup:

```bash
git config --global gpg.ssh.allowedSignersFile ~/.ssh/company/verification/allowed_signers
```

Example allowed signers entry:

```text
<verified-email@example.com> namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI<placeholder>
```

## Notes

- The email used in Git config should be a verified GitHub email address; keep the actual value out of this document and use a placeholder in examples.
- SSH signing is preferred over GPG for this repository because it has less setup overhead.
- The signing key should not be reused as the SSH authentication key unless there is a deliberate reason to do so.
