# MySQL Init Scripts

This directory contains initialization scripts executed by the MySQL container on first startup.

## Files

- `001-bootstrap.sql` - Creates the database and application user.

## Notes

- Keep these scripts focused on bootstrap only.
- Avoid application logic here.
