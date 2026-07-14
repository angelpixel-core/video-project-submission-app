# Prod

## Inventory

| Resource | Name | Notes |
| --- | --- | --- |
| Web service | `video-project-submission-app` | Planned production web runtime. |
| Worker service | `video-project-submission-app-worker` | Planned production background worker. |
| PostgreSQL service | `video-project-submission-app-db` | Planned managed Postgres for production. |
| Hostname | `<placeholder-domain>` | Placeholder until the real domain is chosen. |
| TLS | Render-managed | Certificate termination handled by Render. |

## Runtime Inputs

- `RAILS_ENV=production`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_MASTER_KEY`
- `DATABASE_URL`

## Notes

- Production stays reserved until the release path is ready.
- Keep the shape aligned with QA and staging so promotion stays predictable.
