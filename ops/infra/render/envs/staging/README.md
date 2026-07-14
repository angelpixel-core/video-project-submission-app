# Staging

## Inventory

| Resource | Name | Notes |
| --- | --- | --- |
| Web service | `video-project-submission-app-staging` | Planned Render web runtime for staging. |
| Worker service | `video-project-submission-app-staging-worker` | Planned background worker for staging queue processing. |
| PostgreSQL service | `video-project-submission-app-staging-db` | Planned managed Postgres for staging. |
| Hostname | `staging.<placeholder-domain>` | Placeholder until DNS is finalized. |
| TLS | Render-managed | Certificate termination handled by Render. |

## Runtime Inputs

- `RAILS_ENV=staging`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_MASTER_KEY`
- `DATABASE_URL`

## Notes

- Staging should mirror QA and production behavior as closely as possible.
- Keep the worker separate from QA to preserve promotion boundaries.
