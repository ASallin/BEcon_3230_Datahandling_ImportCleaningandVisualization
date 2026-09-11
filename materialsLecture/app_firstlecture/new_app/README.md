# Class survey — form + live dashboard (Postgres, no API keys)

Replacement for the Google-Sheets version. Two Shiny apps sharing one free
Postgres database:

| Folder        | What it is                        | Who uses it                     |
|---------------|-----------------------------------|---------------------------------|
| `form/`       | the "Tell us about yourself" form | students (QR code on slide 1)   |
| `dashboard/`  | live flexdashboard of responses   | lecturer, shown in class        |

No service-account JSON, no Google Maps key. Storage is Postgres; home towns
are geocoded with the free, keyless **ArcGIS** geocoder (`tidygeocoder`), and
the coordinates *and country* are cached in the `geocode_cache` table.

> Why ArcGIS and not OpenStreetMap? Nominatim ranks candidates by a Wikipedia
> derived "importance" score that is unreliable for small places: it puts a
> 50 person hamlet in France above Arbon TG (14'000 people), so Swiss towns
> kept landing in the wrong country. ArcGIS ranks by prominence like Google
> Maps and got all test towns right with no manual exceptions. It also returns
> the country, which is why no shapefile (`sf`/`rnaturalearth`) is needed.

```
new_app/
├── README.md
├── setup_db.R           # run once: creates the tables
├── prewarm_geocode.R    # optional: fill the geocode cache before class
├── db.R                 # connection helper (canonical copy)
├── .env.example         # template for the DB credentials (PG* variables)
├── form/                # deployable Shiny app  (app.R + db.R + .env)
└── dashboard/           # deployable Shiny app  (survey_dashboard.Rmd + db.R + .env)
```

`db.R` is copied into `form/` and `dashboard/` so each deploys standalone.
If you change one copy, copy it to the other two.

---

## 1. Create a free Postgres database

**Supabase** (recommended) or **Neon** — both have a free tier that is far more
than enough for ~230 students.

Supabase:

1. https://supabase.com → new project. Pick a region close to Switzerland
   (e.g. `eu-central-1` / Frankfurt). Set a database password and keep it.
2. Project → **Connect**. You'll see the connection parameters:
   * **Direct connection** — host `db.<ref>.supabase.co`. IPv6-only on the free
     plan, so it fails on networks without IPv6 (many home/office setups, and
     shinyapps.io). Use it only if it actually connects.
   * **Session pooler** — host `aws-0-<region>.pooler.supabase.com`, port `5432`,
     user `postgres.<ref>`. IPv4. Use this for `setup_db.R` and the dashboard.
   * **Transaction pooler** — same pooler host, port `6543`. Best for the form
     app's many short inserts.

## 2. Point the code at it

```bash
cd new_app
cp .env.example .env
```

Edit `.env` with your values (these are the standard PostgreSQL client
variables — see "How the connection works" below):

```
PGHOST=db.your-ref.supabase.co
PGPORT=5432
PGUSER=postgres
PGPASSWORD=YOUR-PASSWORD
PGDATABASE=postgres
PGSSLMODE=require
```

`.env` is git-ignored — it must never be committed. Copy it into the two app
folders too (each app reads a `.env` next to itself when run locally):

```bash
cp .env form/.env
cp .env dashboard/.env
```

### How the connection works

There is no connection string wired through the code. The credentials travel
from `.env` to the database in four hops, and the last hop is done by the
PostgreSQL client library, not by us:

1. **`.env`** holds plain `NAME=VALUE` lines on disk.
2. **`readRenviron(".env")`** (top of `db.R`) loads those into the R process's
   environment, so `Sys.getenv("PGHOST")` now returns the host.
3. **`db_connect()`** calls `DBI::dbConnect(RPostgres::Postgres())` with **no
   arguments**. `RPostgres` is a thin wrapper over libpq.
4. **libpq** fills every unspecified parameter from its standard environment
   variables: `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`,
   `PGSSLMODE`. That naming convention *is* the wiring.

So `db.R` stays a two-liner:

```r
if (file.exists(".env")) readRenviron(".env")
db_connect <- function() DBI::dbConnect(RPostgres::Postgres())
```

The explicit equivalent, if you ever want to see it spelled out:

```r
DBI::dbConnect(
  RPostgres::Postgres(),
  host     = Sys.getenv("PGHOST"),
  port     = Sys.getenv("PGPORT"),
  user     = Sys.getenv("PGUSER"),
  password = Sys.getenv("PGPASSWORD"),
  dbname   = Sys.getenv("PGDATABASE"),
  sslmode  = Sys.getenv("PGSSLMODE")
)
```

> A full `postgresql://…` URL does **not** work here: `RPostgres` does not parse
> a URL passed as `dbname`, so libpq gets no host and silently falls back to
> `localhost`. Use the `PG*` variables above instead.

## 3. Install R packages

```r
install.packages(c(
  "shiny", "shinyjs", "DBI", "RPostgres",          # form + dashboard
  "flexdashboard", "dplyr", "ggplot2", "scales",   # dashboard
  "leaflet", "tidygeocoder",                       # map + geocoding
  "quanteda", "quanteda.textplots", "RColorBrewer" # word cloud
))
```

## 4. Create the tables (once)

```bash
Rscript setup_db.R
```

Creates `responses` and `geocode_cache`. Safe to re-run.

## 5. Run locally

Form:

```r
shiny::runApp("form")
```

Dashboard:

```r
rmarkdown::run("dashboard/survey_dashboard.Rmd")
```

Submit a test response in the form, watch it appear in the dashboard (it
refreshes every 20 seconds).

---

## Deploying to shinyapps.io

Deploy each folder as its own app. **Do not rely on the local `.env` in
production** — set the `PG*` variables in the app's environment instead. Load
your `.env` into the current R session first so `rsconnect` can read the values:

```r
library(rsconnect)
readRenviron("new_app/.env")

pg_vars <- c("PGHOST", "PGPORT", "PGUSER", "PGPASSWORD", "PGDATABASE", "PGSSLMODE")

# form — Transaction pooler recommended (PGPORT=6543)
rsconnect::deployApp("form",
  appName = "FormDataHandling2026", envVars = pg_vars)

# dashboard
rsconnect::deployApp("dashboard",
  appName = "ClassSurveyDashboard2026", envVars = pg_vars)
```

`envVars` uploads each variable's value (from `Sys.getenv`) to the app's
settings, encrypted; nothing is written into the bundle. You can also set/edit
them later in the shinyapps.io dashboard under the app's **Settings → Variables**.

After deploying, update slide 1:

* new form URL → the link on the "Introduce yourself!" slide
  (`materialsLecture/slides/01_introduction.qmd`)
* regenerate the QR code image in `img/` to point at the new URL

---

## Before each lecture

1. (Optional) clear last year's data:
   ```sql
   TRUNCATE responses;
   -- keep geocode_cache: those coordinates are still valid and save API calls
   ```
2. Run `Rscript prewarm_geocode.R` a few minutes before class so the dashboard
   map never waits on the geocoder. Add `--reset` to throw away the cache and
   look every town up again.
3. Open the dashboard, project it, start the lecture.

---

## Database schema

```
responses
  id            bigint  (identity, primary key)
  home_town     text
  literacy      integer            -- 0..10
  used_r        boolean
  major         text               -- BWL | VWL | BIA | BLaw | BLE | other
  enrolled_dsf  boolean
  assoc_data    text               -- free-text word association
  submitted_at  timestamptz        -- DEFAULT now()

geocode_cache
  place         text  (primary key)
  lat           double precision
  lon           double precision
  country       text               -- ISO3 code from the geocoder (CHE, DEU, ...)
  cached_at     timestamptz        -- DEFAULT now()
```

Only towns that were successfully located are stored, so a typo is looked up
once, left off the map, and retried on the next Refresh. If a town ends up in
the wrong place, delete that one row and press Refresh:

```sql
delete from geocode_cache where place = 'SomeTown';
```

## Notes

* **Concurrency:** each form submission opens a short-lived connection and does
  one `INSERT`. Postgres handles the first-5-minutes-of-class burst without
  trouble — this was the main weakness of the Sheets version.
* **Reading the data afterwards** (e.g. for the schedule slide table):
  ```r
  con <- db_connect()
  d <- DBI::dbReadTable(con, "responses")
  DBI::dbDisconnect(con)
  ```
* **Geocoding:** the cache means each distinct town is looked up once, ever
  (~230 students, far fewer distinct towns). Esri's keyless ArcGIS endpoint is
  meant for occasional, non-stored use; a class dashboard is well inside that,
  but if you ever need a guarantee, get a free ArcGIS developer token or switch
  `method = "arcgis"` back to `"osm"` in `dashboard/survey_dashboard.Rmd` and
  `prewarm_geocode.R` (and accept the ranking problems described above).
* **Typos:** ArcGIS will fuzzy-match a misspelling to a plausible nearby place
  rather than refuse it, so an occasional dot may be slightly off. Names it
  cannot place at all are simply left off the map.
