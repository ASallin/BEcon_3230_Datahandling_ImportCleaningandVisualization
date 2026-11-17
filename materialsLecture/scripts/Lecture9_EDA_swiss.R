# Exercise on EDA
# Lecture 9 - Data Handling
# Author: Aurélien Sallin, 2025



# Set-up ------------------------------------------------------------------

library(datasets) # for the swiss dataset
library(tidyverse)
library(summarytools)
library(skimr)



# Load data and make some manual changes ----------------------------------

# Load the built-in 'swiss' dataset from the package "datasets"
data("swiss")

swiss <- rownames_to_column(swiss, var = "municipality")

# Add an outlier in Lausanne
swiss[swiss$municipality == "Lausanne", "Infant.Mortality"] <- 100

# Add a NA for Agriculture in Gruyere
swiss[swiss$municipality == "Gruyere", "Agriculture"] <- NA



# Exploration with EDA tools ----------------------------------------------

# Use standard summary
summary(swiss)

# Use dplyr summarize
summarize(swiss,
          mean = mean(Agriculture),
          sd = sd(Agriculture),
          median = median(Agriculture),
          N = n())

# Use dplyr summarize and rbind for a summary table
bind_rows(
  summarize(swiss,
            name = "Agriculture",
            min = min(Agriculture),
            mean = mean(Agriculture),
            sd = sd(Agriculture),
            median = median(Agriculture),
            N = n()),
  summarize(swiss,
            name = "Examination",
            min = min(Examination),
            mean = mean(Examination),
            sd = sd(Examination),
            median = median(Examination),
            N = n()
            )
)

# Use skimr
skim(swiss)

# use summarytools
summarytools::descr(swiss)
summarytools::freq(swiss)
summarytools::dfSummary(swiss)




# Exploration per group ---------------------------------------------------

swiss |> 
  group_by(Catholic > 50) |> 
  summarize(mean(Fertility))

swiss |> 
  group_by(Catholic > 50) |> 
  summarize(
    across(
      .cols = c(Fertility, Education),
      .fns = list("min" = min, "mean" = mean, "median" = median, "max" = max,
                   "n_na" = ~sum(is.na(.)))
          )
        ) 
