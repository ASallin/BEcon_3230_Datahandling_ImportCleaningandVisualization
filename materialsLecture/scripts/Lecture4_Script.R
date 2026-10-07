################################################################
# Data Handling: Import, Cleaning and Visualisation
# Lecture 4: Students' notebook
# Dr. Aurélien Sallin
################################################################



# Load libraries ----------------------------------------------------------

library(readr)


# Read in csv -------------------------------------------------------------

stocks <- read_csv("data/stock_prices.csv")
stocks

# glimpse() (from dplyr) gives a quick overview of a data frame, turned sideways
library(dplyr)
glimpse(stocks)

read_csv('A,B
         12:00, 12:00
         14:30, midnight
         20:01, noon')



# Guess parsers -----------------------------------------------------------

guess_parser(c("12:00", "midnight", "noon"))
guess_parser(c("12:00", "14:30", "20:01"))

parse_time(c("12:00", "14:30", "20:01"))


guess_parser("1'300'000")
guess_parser("1'300'000", locale = locale(grouping_mark = "'"))



# Data structures ---------------------------------------------------------

## Data types: special values
NA
NaN
Inf
NULL


## Data structures: vectors

persons <- c("Andy", "Brian", "Andy")
persons

is.character(persons)

ages <- c(24, 50, 30)
ages

# Vector concatenation (into strings)
paste(persons[1], "+", persons[3])
paste(persons[1], "+", persons[3] , sep = "")
paste0(persons[1], "+", persons[3] , sep = "")


# Coercion ---------------------------------

# What happens when you create a vector out of `persons` and `ages`?
c(persons, ages)

# Another example
mixed2 <- c(TRUE, 2, 3)
mixed2

# Explicit coercion
x <- c(FALSE, FALSE, TRUE)
as.numeric(x)

as.numeric(c("1.2", "3.4", "5.6"))
as.numeric(c("1.2", "a", "5.6"))
as.integer(c(1.2, 2.9, 3.7))


# Data structures: matrices ---------------------------------

my_matrix <- matrix(
  c(1, 2, 3, 4, 5, 6),
  nrow = 3,
  byrow = FALSE
)
my_matrix
dim(my_matrix)

mycoercedmatrix <- cbind(
  persons, ages
)

rownames(mycoercedmatrix) <- c("a", "b", "c")
attributes(mycoercedmatrix)


# Data structures: Arrays ---------------------------------
my_array <- array(1:12, dim = c(2, 3, 2))
my_array
dim(my_array)

my_array1 <- array(c(1:4), dim = c(2,3,4))
my_array2 <- array(c(1:6), dim = c(2,3,4))


my_array1 + my_array2



# Data structures: Data frames, tibbles, and data tables ---------------------------------

df <- data.frame(person = persons, age = ages, gender = c(0, 1, 1))
df

names(df)
colnames(df)
str(df)
df

df$gender



# Data structures: lists ---------------------------------

my_list <- list(my_array,
                my_matrix,
                df
)
length(my_list)
names(my_list)

# Indexing a list can be done with double [[]]
my_list[[1]]
my_list[[1]][[4]]

# If the elements have names, $ can access the element
my_list <- list(my_array, "matrix" = my_matrix, df)
my_list$matrix



# Data attributes ---------------------------------

x <- c(a=1, b=2, c=3)
names(x)

m <- matrix(1:6, nrow=2)
dim(m)

#  dimnames stores the names of the rows, columns (and further dimensions) of a matrix or array.
dimnames(m) <- list(c("row1", "row2"), c("col1", "col2", "col3"))
m


# Factors ---------------------------------

gender <- factor(c("Male", "Male", "Female"))
gender

typeof(gender)
levels(gender)
attributes(gender)


x1 <- c("Dec", "Apr", "Jan", "Mar")

month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

y1 <- factor(x1, levels = month_levels)
y1

sort(y1)

# Reorder
levels(y1) <- rev(levels(y1))
sort(y1)



# Manipulating rectangular data in R ---------------------------------

library(datasets)
data(swiss)
swiss <- read_csv("../../data/swiss.csv")

swiss <- as.data.frame(swiss)

# inspect the structure
str(swiss)

# look at the first few rows
head(swiss, n = 5)


#### Select columns
swiss$Fertility # use the $-operator

swiss[, 1] # use brackets [] and the column number/index

swiss[, "Fertility"] # use the name of the column

swiss[, c("Fertility", "Agriculture")] # use the name of the column


#### Select rows
swiss[1,]  # First row

swiss[swiss$Fertility > 40,]  # Based on condition ("filter")


## End