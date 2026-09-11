# Run this shortly before the lecture to fill the geocode cache for all home
# towns already submitted, so the dashboard never waits on OpenStreetMap
# during class (Nominatim allows ~1 request per second).
#
#   Rscript prewarm_geocode.R
#
# Pass --reset to throw away the whole cache and look everything up again
# (useful if some towns were resolved to the wrong place).

if (file.exists(".env")) readRenviron(".env")

library(DBI)
library(RPostgres)
library(tidygeocoder)
source("db.R")

reset <- "--reset" %in% commandArgs(trailingOnly = TRUE)

con <- db_connect()
on.exit(dbDisconnect(con))

if (reset) {
  n <- dbExecute(con, "DELETE FROM geocode_cache")
  cat(sprintf("Reset: removed all %d cached locations.\n", n))
}

# Towns students submitted
towns <- dbGetQuery(con, "
  SELECT DISTINCT trim(home_town) AS place
  FROM responses
  WHERE home_town IS NOT NULL AND trim(home_town) <> ''
")$place

# Towns we already resolved (rows without coordinates do not count)
cache <- dbReadTable(con, "geocode_cache")
done  <- cache$place[is.finite(cache$lat) & is.finite(cache$lon)]
todo  <- setdiff(towns, done)

cat(sprintf("%d towns submitted, %d already cached, %d to look up\n",
            length(towns), length(intersect(towns, done)), length(todo)))

if (length(todo) > 0) {
  # ArcGIS: free, no API key, ranks by prominence like Google Maps
  res <- tidygeocoder::geocode(
    data.frame(place = todo), address = place,
    method = "arcgis", quiet = FALSE, full_results = TRUE
  )

  cc <- if ("attributes.Country" %in% names(res))
    res[["attributes.Country"]] else NA_character_

  fresh <- data.frame(place = res$place, lat = res$lat,
                      lon = res$long, country = cc)
  failed <- fresh$place[!is.finite(fresh$lat)]
  fresh  <- fresh[is.finite(fresh$lat) & is.finite(fresh$lon), , drop = FALSE]

  if (nrow(fresh) > 0) dbAppendTable(con, "geocode_cache", fresh)

  cat(sprintf("Cached %d locations.\n", nrow(fresh)))
  if (length(failed) > 0)
    cat("Could not place (left off the map):", paste(failed, collapse = ", "), "\n")
}

cat("\nCache now contains:\n")
print(dbGetQuery(con, "SELECT place, country, lat, lon FROM geocode_cache ORDER BY place"))
