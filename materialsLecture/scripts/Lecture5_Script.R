########################################################
# Data Handling Lecture 5
#
# Read xml
# Read json
# Read html
########################################################

# load packages
library(xml2) # updated and faster than library `XML`

# parse XML, represent XML document as R object
xml_doc <- read_xml("data/company_dundermifflin.xml")
xml_doc


# Navigate
xml_children(xml_doc)
xml_children(xml_children(xml_doc) )
xml_children(xml_children(xml_children(xml_doc) ))

xml_child(xml_children(xml_doc), 1)
persons <- xml_children(xml_doc)

xml_siblings(persons[1])

sales <- xml_children(xml_children(xml_children(xml_doc)))
xml_parents(sales)
xml_parent(sales)


# Xpath
# find data via XPath
sales <- xml_find_all(xml_doc, xpath = ".//sales")
sales
xml_text(sales) # extract the data as text

position <- xml_find_all(xml_doc, xpath = ".//position")
position


# Convert persons to a dataframe: extract each attribute.
# xml_text extracts the text between the tags
df_persons <- data.frame(
  id = xml_attr(persons, "id"),
  name = xml_text(xml_find_all(persons, "./name")),
  position = xml_text(xml_find_all(persons, "./position")),
  branch = xml_attr(xml_find_all(persons, "./location"), "branch")
)


# JSON --------------------------------------------------------------------

# load packages
library(jsonlite)

# parse the JSON-document shown in the example above
json_doc <- fromJSON("data/person.json")

# look at the structure of the document
str(json_doc)

# navigate the nested lists, extract data
# extract the address part
json_doc$address
json_doc[[4]]

# extract the gender (type)
json_doc$gender$type



# HTML --------------------------------------------------------------------

# packages
library(rvest) # depends on httr and xml2

# fix variables
URL <- "https://en.wikipedia.org/wiki/Economy_of_Switzerland"



# READ WEBPAGE AS TEXT DOCUMENT -------------------

# Check raw html: add `view-source:` or CTRL+U - CTRL OPTION U
# view-source:https://en.wikipedia.org/wiki/Economy_of_Switzerland

# (naive approach to import a website into R...)
swiss_econ <- readLines("https://en.wikipedia.org/wiki/Economy_of_Switzerland")
head(swiss_econ)

# Navigate the raw HTML
swiss_econ[231]


# PARSE THE HTML, WEB SCRAPING ------------

# parse the webpage, show the content
swiss_econ_parsed <- read_html("https://en.wikipedia.org/wiki/Economy_of_Switzerland")
swiss_econ_parsed

# find the element containing the table
tab_node <- html_element(
  swiss_econ_parsed,
  xpath = '//*[@id="mwAao"]'
)

# print the HTML structure of the table
cat("HTML structure of the table:\n")
cat(as.character(tab_node))
cat("\n\n")

# extract the table as data.frame
tab <- html_table(tab_node)
tab



# Use Rvest ---------------------------------------------------------------

tab <- html_table(swiss_econ_parsed)

tab[[2]]
tab[[3]]


# Get the text
swiss_econ_parsed |> html_elements("p") |> html_text2()


# Get more text ---------------------------------

# parse the webpage
page <- read_html("https://en.wikipedia.org/wiki/Economy_of_Switzerland")

# select all paragraphs <p> inside the article body (
paragraphs <- html_elements(page, xpath = "//*[@id='mw-content-text']//p")

# extract the text of each paragraph
paragraphs <- html_text2(paragraphs)

paragraphs[3]


# split into words (cut at anything that is not a letter)
words <- tolower(unlist(strsplit(paragraphs, "[^[:alpha:]]+")))
words <- words[nchar(words) > 2]  # drop very short words

# drop filler words ("the", "and", ...)
stopwords <- tidytext::stop_words$word
words <- words[!words %in% stopwords]

# count each word and sort
counts <- as.data.frame(table(words))
counts <- counts[order(counts$Freq, decreasing = TRUE), ]
head(counts, 5)


# END ---------------------------------