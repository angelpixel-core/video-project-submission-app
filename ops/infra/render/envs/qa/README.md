# QA

## Inventory

| Resource | Name | Notes |
| --- | --- | --- |
| Web service | `video-project-submission-app-qa` | Existing Render service; Rails web runtime for QA. |
| Worker service | `video-project-submission-app-qa-worker` | Separate background worker for QA queue processing. |
| PostgreSQL service | `video-project-submission-app-qa-db` | Managed Postgres adopted from the live QA environment. |
| Hostname | `video-project-submission-app-qa.onrender.com` | Current Render hostname for QA. |
| TLS | Render-managed | Certificate termination handled by Render. |

## Runtime Inputs

- `RAILS_ENV=qa`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_MASTER_KEY`
- `DATABASE_URL`

## Notes

- QA is the first deployed compatibility checkpoint.
- Terraform should adopt this live state rather than recreate it.
