# db.R — Postgres connection helper (shared by the form app and the dashboard).
#
# Credentials live in environment variables, loaded from a git-ignored ".env"
# file next to the app (see .env.example). On shinyapps.io set the same
# variables in the app's Settings -> Variables.
#
# RPostgres::Postgres() with no arguments reads the standard libpq variables:
#   PGHOST  PGPORT  PGUSER  PGPASSWORD  PGDATABASE  PGSSLMODE

if (file.exists(".env")) readRenviron(".env")

db_connect <- function() {
  DBI::dbConnect(RPostgres::Postgres())
}
