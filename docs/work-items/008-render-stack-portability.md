---
id: render-stack-portability
aliases: []
tags:
  - work-items
  - render
  - terraform
  - portability
  - infrastructure
depends_on:
  - database-engine-and-iac-strategy
  - render-infrastructure-requirements
order: 8
phase: work-items
status: draft
title: Render Stack Portability
---

# Render Stack Portability

## Goal

- [ ] Make the Render/Terraform stack portable across Render accounts by parameterizing account-specific values.

## Scope

- Render workspace owner ID as a variable.
- Render API auth as a secret.
- Per-environment Render service IDs as secrets.
- Per-environment Render environment IDs as repository variables.
- Current-account adoption IDs stay isolated to the active workspace.
- Document the hardcoded vs variable boundary for future reuse.

## Operational Note

- The current repository is still tied to one Render workspace for the adopted QA resources.
- The stack should remain reusable by another account as long as that account supplies its own owner ID, API key, and resource IDs.
- The `Hobby` plan still limits the active promotion chain, so portability here means configuration reuse, not a guarantee of identical live topology.

## Implementation Plan

- [ ] Parameterize `owner_id` in every Render provider block.
- [ ] Pass `TF_VAR_owner_id` through GitHub Actions jobs that run Terraform.
- [ ] Add `RENDER_OWNER_ID` to the GitHub repository variables interface.
- [ ] Keep the current workspace resource IDs out of reusable defaults.
- [ ] Keep the hardcoded vs variable matrix documented in the work items.
- [ ] Validate that QA `terraform plan` still succeeds with the portable inputs.

## Affected Docs

- `docs/work-items/006-render-infrastructure-requirements.md`
- `docs/work-items/007-database-engine-and-iac-strategy.md`
- `docs/work-items/index.md`

## Affected Ops

- `.github/workflows/infra-render.yml`
- `Makefile`
- `ops/scripts/secrets.sh`
- `ops/infra/render/envs/qa/providers.tf`
- `ops/infra/render/envs/staging/providers.tf`
- `ops/infra/render/envs/prod/providers.tf`
- `ops/infra/render/envs/qa/variables.tf`
- `ops/infra/render/envs/staging/variables.tf`
- `ops/infra/render/envs/prod/variables.tf`

## Checklist

- [ ] Externalize the Render workspace owner ID.
- [ ] Keep API keys and resource IDs outside the code.
- [ ] Document the portability boundary for another Render account.
- [ ] Verify the QA Terraform plan still passes after parameterization.

## Validation

- [ ] A different Render workspace can reuse the same Terraform structure by setting its own `RENDER_OWNER_ID` and resource IDs.
- [ ] The current QA workflow still plans successfully.

## Notes

- This work item is about portability and reuse, not about unlocking the Hobby plan limits.
- Keep the code minimal and favor variables for anything account-specific.
