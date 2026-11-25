######################################################################
# Project Lecture 9: Exploratory Data Analysis and Visualization
#
# This script is the main script for lecture 9 of Data Handling.
#
# A. Sallin, St. Gallen, 2026
#######################################################################


# Set up ------------------------------------------------------------------

library(tidyverse)


# Load and check ----------------------------------------------------------

library(readxl)
costs <- read_excel("../../data/health_costs_canton.xlsx") # <- check your own path

head(costs)

glimpse(costs)

dim(costs)


# Call summary() ----------------------------------------------------------

summary(costs)


# Use skimr ---------------------------------------------------------------

library(skimr)
skim(costs)


# Use summarytools --------------------------------------------------------

library(summarytools)
dfSummary(costs)


# What is the unit of observation? ----------------------------------------

costs |>
    count(canton, year, sex) |>
    head(6)

costs |>
    summarize(n = n(), .by = c(canton, year, sex)) |>
    filter(n > 1)

costs  |>
  group_by(region, canton, sex)  |>
  summarize(
    n_distinct(year),
    min(year),
    max(year)
  )


# What to do with missing values? -----------------------------------------

costs |>
    count(region)

costs |>
    count(region, canton) |>
    filter(is.na(region))

# Recode
costs <- costs |>
    mutate(region = coalesce(region, "CH"))


# What do variables measure? ----------------------------------------------

costs |>
  filter(canton != "CH", sex == "total") |>
  summarise(
    n         = n(),
    n_missing = sum(is.na(cost_pc)),
    mean      = mean(cost_pc),
    median    = median(cost_pc),
    min       = min(cost_pc),
    max       = max(cost_pc),
    .by = canton
  )  |>
  head(5)

costs |>
    filter(canton != "CH", sex == "total") |>
    summarise(
        n = n(),
        n_missing = sum(is.na(cost_pc)),
        mean = mean(cost_pc),
        median = median(cost_pc),
        min = min(cost_pc),
        max = max(cost_pc),
        .by = year
    ) |>
    head(5)


# What type of variation occurs within my variables? ----------------------

cantons_total <- costs |>
    filter(canton != "CH", sex == "total")

cantons_total |>
  filter(year %in% c(1997, 2024)) |>
  group_by(year) |>
  summarise(
    mean = mean(cost_pc),
    median = median(cost_pc),
    min = min(cost_pc),
    max = max(cost_pc),
    sd = sd(cost_pc)
  )

cantons_total |>
  filter(year == 2024) |>
  slice_max(cost_pc, n = 3)

cantons_total |>
  filter(year == 2024) |>
  slice_min(cost_pc, n = 3)

growth <- cantons_total |>
    arrange(canton, year) |>
    group_by(canton) |>
    mutate(
      lag = lag(cost_pc),
      growth = cost_pc / lag - 1) |>
    ungroup()

growth

growth |>
    summarise(
        mean = mean(growth, na.rm = TRUE),
        median = median(growth, na.rm = TRUE),
        min = min(growth, na.rm = TRUE),
        max = max(growth, na.rm = TRUE)
    )

growth |>
    filter(abs(growth) > 0.10) |>
    arrange(desc(abs(growth))) |>
    head(10)

growth |>
    filter(growth < 0) |>
    count(year) |>
    arrange(-n)

costs |>
  filter(year %in% c(1997, 2024), canton == "CH") |>
  summarise(
    mean_cost  = mean(cost_pc),
    n_cantons  = n(),
    .by = c(year, sex)
  ) |>
  arrange(sex, year)


# Tables ------------------------------------------------------------------

tab <- costs |>
  filter(canton == "CH", year %in% c(1997, 2024)) |>
  select(sex, year, cost_pc) |>
  pivot_wider(
      names_from = year,
      values_from = cost_pc,
      names_prefix = "cost_"
  ) |>
  mutate(growth = cost_2024 / cost_1997 - 1) |>
  arrange(desc(cost_2024))

tab


# Tables: scales() example ------------------------------------------------

tab_improved <- tab |>
    mutate(
        across(
          c(cost_1997, cost_2024),
          function(x) {
            scales::number(x, accuracy = 1, big.mark = "'")
          }),
        growth = scales::percent(growth, accuracy = 0.1)
    )
tab_improved


# Labels and column names -------------------------------------------------

tab_improved <- tab_improved |>
    mutate(
        sex = stringr::str_to_title(sex)
    ) |>
    mutate(
        sex = factor(str_to_title(sex), levels = c("Women", "Men", "Total"))
    ) |>
    arrange(sex) |>
    rename(
        "Sex" = sex,
        "Costs in 1997" = cost_1997,
        "Costs in 2024" = cost_2024,
        "Growth rate (%)" = growth
    )
tab_improved



# gt tables --------------------------------------------

library(gt)
library(gtExtras)

tab |>
  gt() |>
  fmt_number(c(cost_1997, cost_2024), decimals = 0, sep_mark = "'") |>
  fmt_percent(growth, decimals = 0) |>
  cols_label(sex = "Sex", cost_1997 = "Costs in 1997", cost_2024 = "Costs in 2024",
             growth = "Growth rate") |>
  tab_header(title = "Health insurance costs per insured person, Switzerland",
             subtitle = "Women cost more, but men's costs grew faster") |>
  tab_source_note("Source: BAG, MOKKE (gross benefits, OKP).")

# opens in browser

# gtExtras sparklines ---------------------------

trend <- costs |>
  filter(canton == "CH") |>
  arrange(year) |>
  summarise(trend = list(cost_pc), .by = sex)

tab <- costs |>
  filter(canton == "CH", year %in% c(1997, 2024)) |>
  select(sex, year, cost_pc) |>
  pivot_wider(
      names_from = year,
      values_from = cost_pc,
      names_prefix = "cost_"
  ) |>
  mutate(growth = cost_2024 / cost_1997 - 1) |>
  left_join(trend, join_by(sex)) |>
  mutate(sex = factor(str_to_title(sex), levels = c("Women", "Men", "Total"))) |>
  arrange(sex)

tab_spark <- tab |>
  gt() |>
  fmt_number(c(cost_1997, cost_2024), decimals = 0, sep_mark = "'") |>
  fmt_percent(growth, decimals = 0) |>
  gt_plt_sparkline(trend) |>
  cols_label(sex = "Sex", cost_1997 = "Costs in 1997", cost_2024 = "Costs in 2024",
             growth = "Growth rate", trend = "1997-2024") |>
  tab_header(title = "Health insurance costs per insured person, Switzerland",
             subtitle = "Women cost more, but men's costs grew faster") |>
  tab_source_note("Source: BAG, MOKKE (gross benefits, OKP).")

tab_spark
# opens in browser


# The other tool to know: modelsummary ------------------------------------

library(modelsummary)
datasummary(sex ~ cost_pc * (Mean + SD + Min + Max),
            data = filter(costs, canton == "CH"),
            fmt = 0)




################################################################
# Graphs
################################################################

# Let's focus on cantonal healthcare costs in Switzerland -----------------

costs_graph <- costs  |>
  filter(canton != "CH", sex == "total")


# Data and aesthetics -----------------------------------------------------

costs_graph |>
    ggplot(
      aes(x = year, y = cost_pc)
    )


# Geometries (~the type of plot) ------------------------------------------

costs_graph |>
    ggplot(
      aes(x = year, y = cost_pc)
    ) +
    geom_point()

costs_graph |>
    ggplot(
      aes(x = year, y = cost_pc, group = canton)
    ) +
    geom_point() +
    geom_line()

costs_graph |>
    ggplot(
      aes(x = year, y = cost_pc, group = canton, color = canton)
    ) +
    geom_point() +
    geom_line()


# Facets ------------------------------------------------------------------

costs_graph |>
    ggplot(
      aes(x = year, y = cost_pc, group = canton, color = canton)
    ) +
    geom_point() +
    geom_line() +
    facet_grid(region ~ .)


# Additional layers and statistics ----------------------------------------

costs_graph |>
    filter(region == "German") |>
    ggplot(
      aes(x = year, y = cost_pc, group = canton, color = canton)
    ) +
    geom_point() +
    geom_line() +
    facet_grid(region ~ .)

costs_graph |>
    filter(region == "German") |>
    ggplot(
      aes(x = year, y = cost_pc)
    ) +
    geom_point(aes(color = canton)) +
    geom_line(aes(color = canton)) +
    geom_smooth(method = "lm", color = "black")


# Adjust the coordinate system or zoom ------------------------------------

costs_graph |>
    filter(region == "German") |>
    ggplot(
      aes(x = year, y = cost_pc, group = canton, color = canton)
    ) +
    geom_point() +
    geom_line() +
    coord_cartesian(xlim = c(2015, NA))


# Save graph before final styling -----------------------------------------

p <- costs_graph |>
    filter(region == "German") |>
    ggplot(
      aes(x = year, y = cost_pc, group = canton, color = canton)
    ) +
    geom_point() +
    geom_line()

p


# Final styling (fonts, colors, title) ------------------------------------

p +
    theme_classic()

p +
    theme_classic() +
    theme(
      legend.position = "bottom",
      axis.text = element_text(size = 12)
    )

p +
    scale_x_continuous(
      breaks = seq(2000, 2025, by = 5)
    ) +
    scale_y_continuous(
      labels = scales::label_comma(big.mark = "'")
    ) +
    labs(
      x = NULL,
      y = "Costs per inhabitant in CHF",
      title = "Healthcare costs increase in Switzerland",
      subtitle = "German-speaking cantons, 1997-2025",
      color = "Canton",
      caption = "Source: MOKKE Data"
    ) +
    theme_classic() +
    theme(
      legend.position = "bottom",
      axis.text = element_text(size = 12)
      )


# Use external themes from ggthemes ---------------------------------------

library(ggthemes)

p +
    scale_x_continuous(
      breaks = seq(2000, 2025, by = 5)
    ) +
    scale_y_continuous(
      labels = scales::label_comma(big.mark = "'")
    ) +
    labs(
      x = NULL,
      y = "Costs per inhabitant in CHF",
      title = "Healthcare costs increase in Switzerland",
      subtitle = "German-speaking cantons, 1997-2025",
      color = "Canton",
      caption = "Source: MOKKE Data"
    ) +
    theme_classic() +
    theme(
      legend.position = "bottom",
      axis.text = element_text(size = 12)
      ) +
    theme_economist()


# The end ---------------------------------
