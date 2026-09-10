
# Packages ----------------------------------------------------------------

library(shiny)
library(shinyjs)
library(DT)
library(googlesheets4)
library(gargle)
library(dplyr)   # you use %>% and data.frame ops



# One-time auth for google sheets -----------------------------------------

# one-time auth at startup.
# Trick: when using it locally to test, use the full path C:(/Users.)
# If deploying it online, use the relative path to the JSON file.
authenticate_gs4 <- function() {

  if (file.exists("20260909_google_private_key")) {
    # gs4_auth(path = "C:/Users/aurel/OneDrive/Documents/DataHandling/datahandling-lecture/materials/app_firstlecture/DataHandlingIntro/datahandlingform-4a1ada22d5ac.json")
    gs4_auth(path = "20260909_google_private_key")
    return(invisible(TRUE))
  }
  stop("No Google service account credentials found. Set GCP_SA_JSON or add service-account.json to the app.")
}

authenticate_gs4()

# gs4_user()


# Set-up ------------------------------------------------------------------

sheet_id <- "13jZFfQHdqN5fI4PqGZZCvHGSgPbDPKBhdSmQ4WClyME"
ss <- as_sheets_id(sheet_id)

fieldsMandatory <- c("used_R", "literacy", "major", "enrolled_dsf")
fieldsAll <- c("home_town", "literacy", "used_R", "major",  "enrolled_dsf", "assoc_data")

humanTime <- function() format(Sys.time(), "%Y%m%d-%H%M%OS")
epochTime  <- function() as.integer(Sys.time())

appCSS <- ".mandatory_star { color: red; }"

labelMandatory <- function(label) {
  tagList(label, span("*", class = "mandatory_star"))
}

loadData <- function() {
  # already authed above
  read_sheet(ss)
}

saveData <- function(data) {
  # coerce to one-row data frame with correct types
  data <- as.data.frame(as.list(data), stringsAsFactors = FALSE)
  sheet_append(ss, data = data, sheet = 1)
}

shinyApp(
  ui = fluidPage(
    shinyjs::useShinyjs(),
    shinyjs::inlineCSS(appCSS),
    titlePanel("Tell us about yourself!"),
    div(
      id = "form",
      textInput("home_town", labelMandatory("What do you consider to be your 'home town' (enter the home town in English)?")),
      sliderInput("literacy",
                  "How would you describe your programming literacy from 1 (low) to 10 (expert)",
                  0, 10, 1, ticks = TRUE),
      tags$div(
        tags$label(labelMandatory("Have you used R before?")),
        tags$div("For example: in another course, in self-study, or at work"),
        checkboxInput("used_R", "I've used R before", FALSE),
      ),
      tags$div(
        tags$label(labelMandatory("Are you enrolled in the Data Science Fundamental program at the HSG?")),
        checkboxInput("enrolled_dsf", "Yes", FALSE),
      ),
      selectInput(
        "major", "Which Major are you in?",
        c("BWL", "VWL", "BIA", "BLaw", "BLE", "other")
        ),
      textInput(
        "assoc_data",
        "First word (or idea) that comes to mind when you think of ‘data science’?"
      ),
      actionButton("submit", "Submit", class = "btn-primary"),
      shinyjs::hidden(
        span(id = "submit_msg", "Submitting..."),
        div(id = "error",
            div(br(), tags$b("Error: "), span(id = "error_msg"))
        )
      )
    ),
    shinyjs::hidden(
      div(
        id = "thankyou_msg",
        h3("Thanks, your response was submitted successfully!"),
        actionLink("submit_another", "Submit another response")
      )
    )
    # if you want the table and download back, re-enable these and ensure your Sheet allows read
    # , DT::dataTableOutput("responsesTable")
    # , downloadButton("downloadBtn", "Download responses")
  ),
  server = function(input, output, session) {

    observe({
      # handle checkbox and numeric mandatory fields correctly
      mandatoryFilled <- all(vapply(fieldsMandatory, function(x) {
        val <- input[[x]]
        if (is.logical(val)) return(!is.null(val))          # checkbox present
        if (is.numeric(val)) return(!is.null(val))          # slider present
        !is.null(val) && nzchar(as.character(val))          # text/select
      }, logical(1)))
      shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
    })

    formData <- reactive({
      data <- sapply(fieldsAll, function(x) input[[x]])
      data <- c(data, timestamp = epochTime())
      t(data)
    })

    observeEvent(input$submit, {
      shinyjs::disable("submit")
      shinyjs::show("submit_msg")
      shinyjs::hide("error")
      tryCatch({
        saveData(formData())
        shinyjs::reset("form")
        shinyjs::hide("form")
        shinyjs::show("thankyou_msg")
      },
      error = function(err) {
        shinyjs::html("error_msg", err$message)
        shinyjs::show(id = "error", anim = TRUE, animType = "fade")
      },
      finally = {
        shinyjs::enable("submit")
        shinyjs::hide("submit_msg")
      })
    })

    observeEvent(input$submit_another, {
      shinyjs::show("form")
      shinyjs::hide("thankyou_msg")
    })

    # If you re-enable the table:
    # output$responsesTable <- DT::renderDataTable(
    #   loadData(),
    #   rownames = FALSE,
    #   options = list(searching = FALSE, lengthChange = FALSE)
    # )
    # output$downloadBtn <- downloadHandler(
    #   filename = function() sprintf("responses_%s.csv", humanTime()),
    #   content = function(file) write.csv(loadData(), file, row.names = FALSE),
    #   contentType = "csv"
    # )
  }
)
