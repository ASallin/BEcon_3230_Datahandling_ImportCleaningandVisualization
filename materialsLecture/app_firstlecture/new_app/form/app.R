# Data Handling @HSG — "Tell us about yourself" form
# --------------------------------------------------------------------
# Students open this app (QR code on slide 1) and submit one response.
# Responses are written to a Postgres database; the dashboard app reads
# from the same table. See ../README.md for setup and deployment.

library(shiny)
library(shinyjs)
library(DBI)
library(RPostgres)

source("db.R")

# --- configuration ---------------------------------------------------
fields_all       <- c("home_town", "literacy", "ai_use", "used_R", "major",
                      "enrolled_dsf", "assoc_data", "predicted_grade")
fields_mandatory <- c("home_town", "literacy", "major")

majors <- c("VWL", "BWL", "BIA", "BLaw", "BLE", "other")

# Swiss grade scale: 1.00 (worst) to 6.00 (best), quarter-point steps
grades <- sprintf("%.2f", seq(6, 1, by = -0.25))

app_css <- paste(
  ".mandatory_star { color: red; }",
  # breathing room between questions
  "#form > .form-group, #form > div { margin-bottom: 26px; }",
  "#form .help-block { margin-bottom: 4px; }"
)

label_mandatory <- function(label) {
  tagList(label, span("*", class = "mandatory_star"))
}

blank_to_na <- function(x) if (is.null(x) || !nzchar(trimws(x))) NA_character_ else trimws(x)

# --- write one response to Postgres --------------------------------
save_response <- function(v) {
  con <- db_connect()
  on.exit(dbDisconnect(con))

  row <- data.frame(
    home_town       = blank_to_na(v$home_town),
    literacy        = as.integer(v$literacy),
    ai_use          = as.integer(v$ai_use),
    used_r          = isTRUE(v$used_R),
    major           = v$major,
    enrolled_dsf    = isTRUE(v$enrolled_dsf),
    assoc_data      = blank_to_na(v$assoc_data),
    predicted_grade = suppressWarnings(as.numeric(blank_to_na(v$predicted_grade))),
    stringsAsFactors = FALSE
  )
  # submitted_at is filled by the table's DEFAULT now()
  dbAppendTable(con, "responses", row)
}

# --- UI -----------------------------------------------------------
ui <- fluidPage(
  useShinyjs(),
  inlineCSS(app_css),
  titlePanel("Tell us about yourself!"),
  div(
    id = "form",
    textInput(
      "home_town",
      label_mandatory("What do you consider to be your 'home town'? (enter it in English)")
    ),
    sliderInput(
      "literacy",
      "How would you rate your programming literacy? (0 = none, 10 = expert)",
      min = 0, max = 10, value = 0, step = 1, ticks = TRUE
    ),
    sliderInput(
      "ai_use",
      HTML("Artificial dependence \U0001F916 <br> How often do you lean on an LLM (Claude, ChatGPT, …) for coursework?<br>(0 = never, 10 = all the time)"),
      min = 0, max = 10, value = 0, step = 1, ticks = TRUE
    ),
    tags$div(
      tags$label(label_mandatory("Have you used R before?")),
      tags$div(class = "help-block",
               "For example: in another course, in self-study, or at work"),
      checkboxInput("used_R", "I've used R before", FALSE)
    ),
    tags$div(
      tags$label(label_mandatory(
        HTML("Are you enrolled in the Data Science Fundamentals <br> program at the HSG?"))),
      checkboxInput("enrolled_dsf", "Yes", FALSE)
    ),
    selectInput("major", label_mandatory("Which Major are you in?"), majors),
    textInput(
      "assoc_data",
      "First word (or idea) that comes to mind when you think of 'data science'?"
    ),
    selectInput(
      "predicted_grade",
      "Your predicted final grade for this course? (1.00-6.00, no pressure)",
      choices = c("Pick one" = "", grades), selected = ""
    ),
    actionButton("submit", "Submit", class = "btn-primary"),
    hidden(
      span(id = "submit_msg", "Submitting..."),
      div(id = "error", div(br(), tags$b("Error: "), span(id = "error_msg")))
    )
  ),
  hidden(
    div(
      id = "thankyou_msg",
      h3("Thanks, your response was submitted successfully!"),
      actionLink("submit_another", "Submit another response")
    )
  )
)

# --- server -----------------------------------------------------
server <- function(input, output, session) {

  # enable Submit only once the mandatory text/select/slider fields are filled
  observe({
    ok <- vapply(fields_mandatory, function(id) {
      val <- input[[id]]
      if (is.numeric(val)) return(!is.null(val))
      !is.null(val) && nzchar(as.character(val))
    }, logical(1))
    shinyjs::toggleState("submit", condition = all(ok))
  })

  form_values <- reactive({
    stats::setNames(lapply(fields_all, function(id) input[[id]]), fields_all)
  })

  observeEvent(input$submit, {
    shinyjs::disable("submit")
    shinyjs::show("submit_msg")
    shinyjs::hide("error")

    tryCatch({
      save_response(form_values())
      shinyjs::reset("form")
      shinyjs::hide("form")
      shinyjs::show("thankyou_msg")
    },
    error = function(e) {
      shinyjs::html("error_msg", conditionMessage(e))
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
}

shinyApp(ui, server)
