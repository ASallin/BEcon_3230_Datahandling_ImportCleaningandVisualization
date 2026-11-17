######################################################################
# Project Lecture 8: Data Analytics
#
# This script is the main script for lecture 8 of Data Handling.
#
# A. Sallin, St. Gallen, 2025
#######################################################################


# Set up ------------------------------------------------------------------

# Load packages (install if needed)
library(tidyverse) # tidyverse contains dplyr, readr, tibble, and all other packages from the tidyverse universe.


# Initiate data frame on persons' spending
df_c <- data.frame(id = c(1:3,1:3,5),
                   money_spent= c(1000, 2000, 6000, 1500, 3000, 5500,3000),
                   currency = c("CHF", "CHF", "USD", "EUR", "CHF", "USD", "CAD"),
                   year = c(2017, 2017, 2017, 2018, 2018, 2018, 2018))
df_c

# Initiate data frame on persons' characteristics
df_p <- data.frame(id = 1:4,
                   first_name = c("Anna", "Betty", "Claire", "Diane"),
                   profession = c("Economist", "Data Scientist",
                                  "Data Scientist", "Economist"))
df_p



# Preparatory steps: combine/merge data frames ------------------------------------------

# Outer join/Full join
fj <- merge(df_p, df_c, by="id", all = TRUE)
fj <- full_join(df_p, df_c, by = "id")

# Left join
lj <- merge(df_p, df_c, by = "id", all.x = TRUE)
lj <- left_join(df_p, df_c, by = "id")
lj

# Right join
rj <- merge(df_p, df_c, by = "id", all.y = TRUE)
rj <- right_join(df_p, df_c, by = "id")
rj

# Inner join
ij <- inner_join(df_p, df_c, by = "id")
ij <- merge(df_p, df_c, by = "id")
ij

# Anti join
aj <- anti_join(df_p, df_c, by = "id")
sj <- semi_join(df_p, df_c, by = "id")

# Cross join (not seen in the course)
merge(df_p, df_c, by = NULL)
cross_join(df_p, df_c)



# Check the many-to-many and one-to-many behavior -----------------------------------------

# Dataset 1: People (with duplicates - person appears multiple times)
people_mtm <- data.frame(
  id = c(1, 1, 2, 2),  # Each person appears twice, as student and employee/consultant
  role = c("Student", "Employee", "Student", "Consultant"),
  department = c("Economics", "IT", "Math", "Finance")
)
people_mtm

# Dataset 2: Transactions (multiple per person)
transactions_mtm <- data.frame(
  id = c(1, 1, 2, 2),  # Person 1 has 2 transactions, Person 2 has 2 transactions
  amount = c(100, 200, 150, 300),
  type = c("Purchase", "Refund", "Purchase", "Purchase")
)
transactions_mtm

# Example 1: MANY-TO-MANY (MTM)
# Problem: Multiple rows in both datasets with same key. Many-to-many join creates
mtm_result <- left_join(people_mtm, transactions_mtm, by = "id")
mtm_result # print

# We would need an additional unique identifier to properly link the datasets,
# for instance the year.


# Example 2: ONE-TO-MANY (OTM) - Clean and predictable
# Proper relationship: One person has many transactions

# Dataset 1: People (each person appears only ONCE)
people_otm <- data.frame(
  id = c(1, 2, 3),
  name = c("Anna", "Bob", "Claire"),
  department = c("Economics", "Math", "Finance")
)
people_otm

# Dataset 2: Transactions (multiple per person - the "many" side)
transactions_otm <- data.frame(
  id = c(1, 1, 1, 2, 2, 3),  # Anna has 3 transactions, Bob has 2, Claire has 1
  amount = c(100, 200, 50, 150, 300, 75),
  date = c("2024-01-01", "2024-01-15", "2024-02-01",
           "2024-01-10", "2024-01-20", "2024-02-05")
)
transactions_otm

# CLEAN: One-to-many join is predictable and meaningful
otm_result <- left_join(people_otm, transactions_otm, by = "id")




################################################################
# BREAK --------------------------
################################################################

# Duplicates ---------------------------------

orders <- data.frame(
    order_id = rep(2031, 6),
    item_id = c(1001, 2014, 3001, 3001, 3026, 3022),
    item = c(
        "Moitié-Moitié Fondue",
        "Fendant Wine",
        "Dessert: meringues + dbl",
        "Dessert: meringues + dbl",
        "Water",
        "Espresso"
    ),
    quantity = c(1, 1, 1, 1, 1, 1),
    price_chf = c(24.00, 38.00, 21.00, 21.00, 3.00, 4.50)
)
orders

calories <- data.frame(
    item = c(
        "Moitié-Moitié Fondue",
        "Moitié-Moitié Fondue",
        "Fendant",
        "Fendant",
        "Meringues + dbl cream"
    ),
    unit = c("per 100 g", "per portion", "per dl", "per dl", "per portion"),
    kcal = c(380, 950, 70, 85, 725)
)
calories


# # Case 1: trivial ---------------------------------

# Always count rows to keep tracks
nrow(orders)

# Using base R's duplicated
duplicated(orders)
orders[duplicated(orders), ]

# Remove using distinct
orders_clean <- distinct(orders)
orders_clean <- unique(orders) # base R
orders_clean

# Check again
stopifnot(!anyDuplicated(orders_clean))
!any(duplicated(orders_clean)) # Given a set of logical vectors, is at least one of the values true?
nrow(orders_clean) - nrow(orders)
count(orders_clean, order_id, item_id) |>
    filter(n > 1)



# Case 2: less trivial ---------------------------------

# Check duplicates
duplicated(calories)

# What makes a dup a dup? The key
count(calories, item, unit)

# Check the rows
calories |>
    group_by(item, unit) |>
    filter(n() > 1)

# Keep one row
slice(calories, 1, .by = c(item, unit)) # The first row of each item and unit
slice_max(calories, kcal, n = 1, by = c(item, unit)) # The row with the highest kcal

# Equivalent:
calories |>
    group_by(item, unit) |>
    filter(n() > 1)

# More on distinct
calories |>
    distinct(item)

calories |>
    distinct(item, unit)

# .keep_all = TRUE: keep all columns, first row per item and unit
calories |>
    distinct(item, unit, .keep_all = TRUE)



# Missing values ---------------------------------

data_missing <- tibble(
    Gender = c("Male", "Female", "Male", "Female", "Male", "Female"),
    Participation = c(1, 0, 1, NA, 1, 1),
    Wage = c(30, NA, 35, 28, 40, NA)
)
data_missing
# Row 2: no wage because she does not work (Participation = 0).
# This wage is not unknown, it is NOT APPLICABLE. Should we impute it?
# Row 6: she works, but did not report her wage. This one is really missing.


# Complete case analysis ---------------------------------
complete_case <- na.omit(data_missing)
complete_case # All women are gone

# Drop only the rows where the variable you analyze is missing
complete_wage <- data_missing |>
    filter(!is.na(Wage))
complete_wage


# Imputation ---------------------------------
# Wage is missing only for women: probably not MCAR.
mean_impute <- data_missing |>
    mutate(
        Wage = ifelse(is.na(Wage), mean(Wage, na.rm = TRUE), Wage),
        Participation = ifelse(
            is.na(Participation) & !is.na(Wage),
            1,
            Participation
        )
    )


# Analysis ---------------------------------
# Analyze mean Wage by gender: three methods, three different answers
# Raw data
data_missing |>
    group_by(Gender) |>
    summarize(
        Mean_Wage = mean(Wage, na.rm = TRUE),
        Participation_Rate = mean(Participation, na.rm = TRUE)
    )

# 2. Complete cases
complete_case |>
    group_by(Gender) |>
    summarize(
        Mean_Wage = mean(Wage, na.rm = TRUE),
        Participation_Rate = mean(Participation, na.rm = TRUE)
    )

# 3. Mean imputation: the women's mean wage rises from 28 to 31.5,
# because they get the overall mean, which includes the men's wages.
mean_impute |>
    group_by(Gender) |>
    summarize(
        Mean_Wage = mean(Wage, na.rm = TRUE),
        Participation_Rate = mean(Participation, na.rm = TRUE)
    )








# Create messy data frame -------------------------------------------------

# We create a fake, messy dataframe for exercise purposes
messy_df <- data.frame(last_name = c("Wayne", "Trump", "Karl Marx"),
                       first_name = c("John", "Melania", ""),
                       gender = c("male", "female", "Man"),
                       date = c("2018-11-15", "2018.11.01", "2018/11/02"),
                       income = c("150,000", "250000", "10000"), stringsAsFactors = FALSE)

messy_df
str(messy_df)







## define, clean categorical variables ------------------------------------------------------------------------
messy_df$gender <- as.factor(messy_df$gender)
messy_df$gender
levels(messy_df$gender)
# Problems?











## standardize categories ------------------------------------------------------------------------
messy_df$gender[messy_df$gender == "Man"] <- "male"
messy_df$gender

levels(messy_df$gender)[3] <- "male"


## tidyverse approach
messy_df$gender <- fct_recode(messy_df$gender, "male" = "Man")
messy_df$gender








## numeric/integer values ------------------------------------------------------------------------
as.integer(messy_df$income)
# Problem?








## ------------------------------------------------------------------------
messy_df$income <- str_replace(messy_df$income,
                               pattern = ",",
                               replacement = "")
messy_df$income <- as.integer(messy_df$income)



## clean up variables  ------------------------------------------------------------------------
messy_df
# remaining problems?







## split strings, add new variables
splitnames <- str_split(messy_df$last_name,
                        pattern = " ",
                        simplify = TRUE)
splitnames

## find rows with problematic cases, add correct first name,
problem_cases <- messy_df$first_name == ""
messy_df$first_name[problem_cases] <- splitnames[problem_cases, 1]


#last name
messy_df$last_name[problem_cases] <- splitnames[problem_cases, 2]
messy_df







##  parse dates correctly -------------------------------------------------------
library(lubridate)


## ------------------------------------------------------------------------
messy_df$date <- ymd(messy_df$date)


## ------------------------------------------------------------------------
messy_df


## ------------------------------------------------------------------------
str(messy_df)


