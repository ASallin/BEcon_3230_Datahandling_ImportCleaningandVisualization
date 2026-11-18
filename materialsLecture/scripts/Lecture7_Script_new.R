#######################################################################
# Project Lecture 7: Data Preparation, Reshaping, and Stacking
#
# This script is the main script for lecture 7 of Data Handling.
# In the first part, it prepares a messy data frame for analysis (analytical
# data frame). In the second part, the ideas of reshaping and stacking
# are illustrated with an example.
#
# A. Sallin, St. Gallen, 2024
#######################################################################


# Set up ------------------------------------------------------------------

# Load packages (install if needed)
library(tidyverse) # tidyverse contains dplyr, readr, tibble, and all other packages from the tidyverse universe.



# Load data ---------------------------------

# load example data
df <- data.frame(
    Student = c("Johannes", "Hannah", "Pam", "Igor", "Johannes"),
    ID = c(1,2,3,4,1),
    Gender = c("Male", "Female", "Female", "Male", "Male"),
    Year = c(2026, 2026, 2026, 2026, 2025),
    Econ = c(5.0, 5.25, 4.0, 5.25, 3.0),
    DataHandling = c(4.0, 4.5, 5.5, 5.0, 4.0),
    Management = c(5.5, 6.0, 4.75, 6.0, 2.5)
)

# inspect data
df



# Selecting subsets (select columns) ------------------------------------------

df_anon <- df |>
    select(ID, Gender, Econ, DataHandling, Management, Year)
df_anon



# Arrange ---------------------------------
df_anon |>
    arrange(Econ)

df_anon |>
    arrange(Econ)

df_anon |>
    arrange(Management, desc = T)



# Filtering datasets (filter rows based on variable values) ------------------------------------------

# one filtering condition
df_anon |>
    filter(Gender == "Male")

# several filtering conditions
df_anon |>
    filter(
        Gender == "Male",
        Year > 2025
    )

# Let's remove failing year
df_anon <- df_anon |>
    filter(Year == 2026)




# Mutating datasets (add/change values/columns) ------------------------------------------

# Recode gender
df_anon <- df_anon |>
    mutate(
        Female = if_else(Gender == "Male", 0, 1),
        Avg = (Econ + DataHandling + Management) / 3
    )
df_anon

# use across
df_anon |>
    mutate(across(c(Econ, DataHandling), function(x) {
        x + 0.1
    }))

df_anon |>
    mutate(across(c(everything()), function(x) {
        as.character(x)
    }))




# Summary statistics and aggregation -------------------------------------------

# generate a simple descriptive statistics table
df_anon  |>
    summarize(
        mean = mean(Econ),
        standard_deviation = sd(Econ),
        median = median(Econ),
        N = n()
)


# summarize by groups of observations ("split-apply-combine")

# split into gender-groups
# apply statistics functions, and combine results in one table

by_gender <- df_anon |>
    group_by(Female) |>
    summarize(
        mean = mean(Econ),
        standard_deviation = sd(Econ),
        median = median(Econ),
        N = n()
    )

df_anon |>
    group_by(Female) |>
    summarize(across(
        .cols = c(Econ, Management),
        .fns = list(mean = mean, standard_deviation = sd, median = median)
    ))


# Very handy: count ---------------------------------

df_anon |>
    count(Female, Year)




################################################################
# BREAK --------------------------
################################################################



# Reshaping datasets: introductory example/concept -----------------------------

# load example data
df <- data.frame(
  Student = c("Johannes", "Hannah", "Igor"),
  Econ = c(5.0, 5.25, 4.0),
  DataHandling = c(4.0, 4.5, 5.0),
  Management = c(5.5, 6.0, 6.0)
)

# inspect data
df



# reshape from wide to long
tidydf <- pivot_longer(
    data = df,
    cols = c(Econ, DataHandling, Management),
    # cols = -Student,
    names_to = "Subject",
    values_to = "Grade"
)

# inspect result
tidydf






# Wide to Long --------------------------------------------

## initialize and inspect a wide example data-frame
wide_df <- data.frame(
    last_name = c("Wayne", "Trump", "Marx"),
    first_name = c("John", "Melania", "Karl"),
    gender = c("male", "female", "male"),
    income.2018 = c("150000", "250000", "10000"),
    income.2017 = c("140000", "230000", "15000"),
    stringsAsFactors = FALSE
)
wide_df











# transform from wide to long
long_df <- pivot_longer(
    wide_df,
    c(income.2018, income.2017),
    names_to = "year",
    names_prefix = "income.",
    values_to = "income"
)

# inspect the result
long_df








# Long to wide -------------------------------------------

# initiate a weird long data.frame
weird_df <- data.frame(
    last_name = c("Wayne", "Trump", "Marx",
                  "Wayne", "Trump", "Marx",
                  "Wayne", "Trump", "Marx"),
    first_name = c("John", "Melania", "Karl",
                    "John", "Melania", "Karl",
                    "John", "Melania", "Karl"),
    gender = c("male", "female", "male",
                "male", "female", "male",
                "male", "female", "male"),
    value = c("150000", "250000", "10000",
              "2000000", "5000000", "NA",
              "50", "25", "NA"),
    variable = c("income", "income", "income",
                 "assets", "assets", "assets",
                 "age", "age", "age"),
    stringsAsFactors = FALSE)


# inspect it, where are the problems?
weird_df


# transform from long to wide
tidy_df <- pivot_wider(weird_df,
                       names_from = "variable",
                       values_from = "value")

# inspect result
tidy_df







# Stacking/Row binding -------------------------------------------


# initialize and inspect sample subsets
# initialize
subset1 <- data.frame(ID=c(1,2),
                      X=c("a", "b"),
                      Y=c(50,10))

subset2 <- data.frame(ID=c(3,4),
                      Z=c("M", "O"))

subset3 <- data.frame(ID= c(5),
                      X=c("c"),
                      Z="P")

# inspect
str(subset1)
str(subset2)
str(subset3)


# combine/stack
# install if needed
# install.packages("dplyr")

# stack data frames
combined_df <- bind_rows(subset1, subset2, subset3)
combined_df1 <- rbind(subset1, subset2, subset3) # error

# inspect the result
combined_df


# The end  ---------------------------------
