################################################################
# Data Handling: Import, Cleaning and Visualisation
# Lecture 2: Students' notebook
# Dr. Aurélien Sallin
################################################################



# The R environment -----------------------------------------

2 + 2  # This command does not create an object in the environment

my_variable <- 10 # This command assigns the numeric 10 to the variable my_variable

# Find out the class of the variable
class(my_variable)

# List the objects in the environment
objects()

# Remove the variable from the environment
rm(my_variable)

# Assignment
b <- 1 + 1
3 -> my_var




# Atomic Vectors --------------------------------------------------------------

# Integer vector
my_integer <- 9L
typeof(my_integer)
mean(my_integer)

# Double vector
my_double <- 9.0
typeof(my_double)
mean(my_double)

# Character vector ("string")
my_character <- "aurelien"
typeof(my_character)
mean(my_character) # works differently: returns an error

# Logical vector
my_logical <- TRUE
typeof(my_logical)


# Building vectors
vector_double <- c(1, 2, 3)
c(c(3, 4), c(10, 11))
vector_logical <- c(TRUE, FALSE, FALSE)
vector_integer <- c(1L, 2L, 3L)
vector_character <- c("a", "b")

typeof(vector_double)
typeof(vector_logical)


### Subsetting vectors
vector_double <- c(1, 2, 3)
vector_double[1]
vector_double[3]
vector_double[c(1, 2)]



# Matrices ----------------------------------------------------------------

v1 <- c(1, 2, 3, 4)
v2 <- c(10, 9, 8, 7)

m1 <- cbind(v1, v2)
print(m1)

m2 <- rbind(v1, v2)
m2

matrix(nrow=3, ncol = 3, 1:9, byrow = FALSE) # fills by column by default

# Change the byrow argument:
matrix(...)

# Example of a matrix:
mymatrix <- matrix(c(1,2,3,11,12,13,1,10),
                   nrow = 2,
                   ncol = 4,
                   byrow = FALSE)
print(mymatrix)
dim(mymatrix)
attributes(mymatrix)

mymatrix[1,2] # element in row 1, column 2
mymatrix[2,4] # element in row 2, column 4
mymatrix[,3]  # all elements in column 3
mymatrix[1,]  # all elements in row 1




# Arithmetic operators ----------------------------------------------------
2+2
4*5
20/5
20^5
sum_result <- 2+2
sum_result -2

# Modulo (remainder)
5 %% 3

# Integral division
5 %/% 3


# These operators are vectorized (element-wise)
a <- c(2, 3, 4)
b <- c(1, 2, 3)
a + b
a * b
a / b

a %% b
a %/% b




# Comparison operators ----------------------------------------------------

a <- c(2, 3, 4)
b <- c(1, 2, 3)

# Comparison
a == b
1 == 7
a != b
a > b
a < b
a >= b
a <= b
a %in% b # is each element of a somewhere in b?
1 %in% 2



# Logical/Booleans operators ----------------------------------------------

TRUE & FALSE
TRUE | FALSE
!TRUE

x <- c(TRUE, FALSE, TRUE, TRUE)
y <- c(FALSE, FALSE, TRUE, FALSE)

x & y
x | y

1 & 2




# Other common operators and functions ------------------------------------

sqrt(4^2)
log(2)
exp(10)
log(exp(10))



# Set operators -----------------------------------------------------------

a <- c(2, 3, 4)
b <- c(1, 2, 3)

union(a, b) # all unique elements in a or b
intersect(a, b) # all unique elements in both a and b
setdiff(a, b) # all unique elements in a but not in b
setequal(a, b) # are a and b equal (same elements, not necessarily in the same order)
setequal(c(1,2,3), c(3,2,1))



# Example of setdiff: Imagine you receive incomplete cantonal data on GDP and unemployment.
# You want to merge the two dataset.

# Cantons we have GDP data for
gdp   <- c("ZH", "BE", "SG", "VD", "GE", "TI")

# Cantons we have unemployment data for
unemp <- c("ZH", "BE", "SG", "VD", "BS")

# Please interpret:
setdiff(gdp, unemp)
setdiff(unemp, gdp)
intersect(gdp, unemp)


# Sequence operators ------------------------------------------------------

1:10
seq(1, 10)
seq(1, 10, by = 2)
seq(1, 10, length.out = 5)


# Loops -------------------------------------------------------------------

# for-loops ---------------------------------------------------------------

# Numeric vector
for (i in c(2, 4, 6, 8)) {
  print(i)
}

# Character vector
vector_loop <- c("brian", "mark", "sophia")

for (i in vector_loop) {
  sentence <- paste(i, "likes icecream.")
  print(sentence)
}


# Use length() to loop over a vector of unknown length
vect <- c(10, 20, 30, 40)
length(vect)

# Both loops do the same thing
for (i in 1:length(vect)) {
  print(vect[i] + 10)
}

for (i in (vect)) {
  print(i + 10)
}


# while-loop --------------------------------------------------------------
# Initiate variable
x <- 1

while (x <= 10) {
  print("88")
  x <- x + 1
}



# repeat-loop -------------------------------------------------------------

# Initiate variable
x <- 1

# Start repeat loop
repeat {
  print(x)
  x = x + 1

  # Break statement
  if (x == 6){
    break
  }
}




# Logical and control statements ------------------------------------------

condition <- TRUE
if (condition) {
  print("This is true!")
} else {
  print("This is false!")
}


if (1 != 0) {
  print("Yes, 1 is not equal to 0.")
}




# Functions ---------------------------------------------------------------

powerFunction <- function(base, exponent) {
  results <- base ^ exponent
  return(results)
}

powerFunction(exponent = 2, base = 3)
powerFunction(base = 2, exponent = 3)
powerFunction(2, 3)
powerFunction(c(2, 4, 3), 3)



# Functionals -------------------------------------------------------------

# User-defined function
triple <- function(x) {
  y <- x * 3
  return(y)
}

triple(1); triple(2); triple(3); triple(4)

# Base R
lapply(1:4, triple)

# purrr
library(purrr)
map_dbl(1:4, triple)
map(1:4, triple)

# Vectoirized function
triple(1:4)



# The "apply" functional --------------------------------------------------

# Empty matrix with 2 rows and 4 columns
mymatrix <- matrix(c(1, 2, 3, 11, 12, 13, 1, 10), nrow = 2, ncol = 4)
mymatrix

# Row sums with a for-loop
for (i in 1:2) {
  s <- sum(mymatrix[i, ])
  print(s)
}

# Row sums with apply
apply(mymatrix, MARGIN = 1, sum)



# Tutorial 1 ---------------------------------

## Tutorial 1: a function to compute the mean

# Write a function `meaN(x)` that computes the mean of a numeric vector. We are not allowed to call it "mean" because `mean()` is already a function in R.

# Test that `meaN(c(1, 3, 5, 3, 2))` returns 2.8.

meaN <- function(x) {
  # your code
}

vector <- c(1, 3, 5, 3, 2)
meaN(vector)

## End