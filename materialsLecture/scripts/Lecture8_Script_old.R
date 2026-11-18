#######################################################################
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




# Data summary ------------------------------------------------------------

# Re-Initiate data frame on persons' spending
df_c <- data.frame(id = c(1:3,1:3,4, 5),
                   money_spent= c(1000, 2000, 6000, 1500, 3000, 5500, 3000, 4000),
                   currency = c("CHF", "CHF", "USD", "EUR", "CHF", "USD", "CAD", "CAD"),
                   year = c(2017, 2017, 2017, 2018, 2018, 2018, 2018, 2019))
df_c

# Re-Initiate data frame on persons' characteristics
df_p <- data.frame(id = 1:5,
                   first_name = c("Anna", "Betty", "Claire", "Diane", "Tom"),
                   profession = c("Economist", "Data Scientist",
                                  "Data Scientist", "Economist", "Ingeneer"))
df_p

# Merge
df_merged <- left_join(df_c, df_p, by = "id")

# summary statistics for each variable
summary(df_merged)

# cross-tabulation (categorical variables)
table(df_merged$year)
table(df_merged$year, df_merged$profession)

# Use "count" from dplyr
count(df_merged, year)

count(df_merged, year) |> 
  mutate(pct = n/sum(n))



# Selecting subsets (select columns) ------------------------------------------

df_selection <- select(df_merged, id, year, money_spent, currency)
df_selection



# Filtering datasets (filter rows based on variable values) ------------------------------------------

# one filtering condition
filter(df_selection, year == 2018)

# several filtering conditions
filter(df_selection, 
       year == 2018, 
       money_spent < 5000, 
       currency=="EUR")





# Mutating datasets (add/change values/columns) ------------------------------------------

# initiate an exchange-rate data frame
exchange_rates <- data.frame(exchange_rate= c(0.9, 1, 1.2, 1.4),
                             currency=c("USD", "CHF", "EUR", "CAD"), 
                             stringsAsFactors = FALSE)

# join the exchange-rate with the main dataset
df_selection <- left_join(df_selection, exchange_rates, by = "currency")

# add the new variable with money spent in CHF
df_mutated <- mutate(df_selection, 
                     money_spent_chf = money_spent * exchange_rate)
df_mutated

# use across 
df_mutated %>%
  mutate(across(c(money_spent, money_spent_chf), function(x) {x-10}))

df_mutated %>%
  mutate(across(c(everything()), function(x) {as.character(x)}))



# Summary statistics and aggregation -------------------------------------------

# generate a simple descriptive statistics table
summarize(df_mutated,
          mean = mean(money_spent_chf),
          standard_deviation = sd(money_spent_chf),
          median = median(money_spent_chf),
          N = n())


# summarize by groups of observations ("split-apply-combine")

# split into year-groups
# apply statistics functions, and combine results in one table

by_year <- df_mutated |> 
  group_by(year) |> 
  summarize(mean = mean(money_spent_chf),
            standard_deviation = sd(money_spent_chf),
            median = median(money_spent_chf),
            N = n()) 

df_mutated |> 
  group_by(year) |> 
  summarize(across(.cols = c(money_spent_chf),
                   .fns = list(mean = mean, 
                               standard_deviation = sd, 
                               median = median)))


# Use skimr
library(skimr) # install if needed
skim(df_mutated)


# use summarytools
summarytools::descr(df_mutated)
summarytools::freq(df_mutated)
summarytools::dfSummary(df_mutated)



# apply-type functions for data summaries

# load data
data("swiss")

# compute the mean for each variable (column)
apply(swiss, 1, mean)
apply(swiss, 2, mean)




