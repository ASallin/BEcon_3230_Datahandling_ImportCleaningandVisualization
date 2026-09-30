################################################################
# Data Handling: Import, Cleaning and Visualisation
# Lecture 3: Students' notebook
# Dr. Aurélien Sallin
################################################################



# Encoding matters -----------------------------------------

# Create a text file using bash
# echo "Wherever there is great property, there is great inequality. For one very rich man there must be at least five hundred poor, and the affluence of the few supposes the indigence of the many." > adamsmith.txt

# Inspect using bash
# cat adamsmith.txt; echo

# Inspect in R
readLines("adamsmith.txt")

# Hex dump in bash
# xxd -b adamsmith.txt

# Hex dump in bash: hex
# xxd  adamsmith.txt


# Encoding issues ---------------------------------------------------------

# Read
# cat hastamanana.txt; echo

# Check hex dump
# file -b hastamanana.txt

#
# iconv -f iso-8859-1 -t utf-8 hastamanana.txt | cat


# Text files --------------------------------------------------------------

# Package to download webpages
library(httr)
# Package to inspect R objects
library(pryr)

economist <- GET("https://www.economist.com/")

pryr::object_size(economist)

economistRaw <- content(economist, as = "raw")
head(economistRaw, 20)

economistText <- content(economist, as = "text")
head(economistText)

# Save it
writeLines(economistText, "economistText.html")
