# One-time database setup. Run once, after creating your Postgres database and
# putting its connection string in .env (or exporting DATABASE_URL):
#
#   Rscript setup_db.R
#
# Safe to re-run: it only creates tables that do not exist yet.

if (file.exists(".env")) readRenviron(".env")

library(DBI)
library(RPostgres)
source("db.R")

con <- db_connect()
on.exit(dbDisconnect(con))

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS responses (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    home_town        text,
    literacy         integer,
    ai_use           integer,
    used_r           boolean,
    major            text,
    enrolled_dsf     boolean,
    assoc_data       text,
    predicted_grade  numeric,
    submitted_at     timestamptz NOT NULL DEFAULT now()
  );
")

# Migrations for databases created before these columns existed (no-op otherwise)
dbExecute(con, "ALTER TABLE responses ADD COLUMN IF NOT EXISTS ai_use integer;")
dbExecute(con, "ALTER TABLE responses ADD COLUMN IF NOT EXISTS predicted_grade numeric;")

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS geocode_cache (
    place      text PRIMARY KEY,
    lat        double precision,
    lon        double precision,
    country    text,
    cached_at  timestamptz NOT NULL DEFAULT now()
  );
")

# country comes straight from OpenStreetMap (ISO2 code), so we no longer need
# a shapefile lookup to work out which country a point is in
dbExecute(con, "ALTER TABLE geocode_cache ADD COLUMN IF NOT EXISTS country text;")

cat("Tables in the database:\n")
print(dbListTables(con))
cat("\nSetup complete.\n")
