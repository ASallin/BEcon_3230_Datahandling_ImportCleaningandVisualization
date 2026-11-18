# Exercise on missing values
# Lecture 9 - Data Handling
# Author: Aurélien Sallin, 2025
library(dplyr)

data <- data.frame(
  Gender = c("Male", "Female", "Male", "Female", "Male", "Female"),
  Participation = c(1, 0, 1, NA, 0, 1),
  Wage = c(30, NA, 35, 28, 40, NA)
)

data

# Complete case analysis ---------------------------------
complete_case <- na.omit(data)



# Imputation ---------------------------------
# Mean imputation for missing Wage
mean_impute <- data |> 
  mutate(
    Wage = if_else(is.na(Wage), mean(Wage, na.rm = TRUE), Wage),
    Participation = if_else(
      is.na(Participation), 
      round(mean(Participation, na.rm = TRUE), 0), 
      Participation
      )
    ) 



# Analysis ---------------------------------
# Analyze mean Wage by gender
data |>
  group_by(Gender) |>
  summarize(
    Mean_Wage = mean(Wage, na.rm = TRUE),
    Participation_Rate = mean(Participation, na.rm = TRUE)
  )

complete_case |>
  group_by(Gender) |>
  summarize(
    Mean_Wage = mean(Wage, na.rm = TRUE),
    Participation_Rate = mean(Participation, na.rm = TRUE)
  )

mean_impute |>
  group_by(Gender) |>
  summarize(
    Mean_Wage = mean(Wage, na.rm = TRUE),
    Participation_Rate = mean(Participation, na.rm = TRUE)
  )
