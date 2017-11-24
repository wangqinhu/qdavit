library(shiny)
library(markdown)
library(colourpicker)
library(shinydashboard)

header <- dashboardHeader(title = "qdavit")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "About", icon=icon("book")),
    menuItem("Home", tabName = "Home", icon=icon("home"), selected = TRUE)
  ),
  fileInput('file1', 'Choose CSV/TSV File',
            accept=c('text/csv', 'text/comma-separated-values,text/plain')),
  div(align="center",
    downloadLink("downloadData", "Demo CSV File"),
    br()
  ),
  checkboxInput('header', 'Header', TRUE),
  numericInput("lctrl", "Line of control", 1, min = 1),
  radioButtons('sep', 'Separator',
               c(Comma=',',
                 Tab='\t'),
                 selected = ','),
  colourInput("col", "Choose colour", "gray", allowTransparent = TRUE),
  checkboxInput('returnpdf', 'Output PDF', FALSE),
  conditionalPanel(
    condition = "input.returnpdf == true",
    div(align="center",
        downloadLink('savepdf')
    )
  ),
  div(align="center",
      br(),
      HTML('<footer>(c) 2017 Qinhu Wang, NWAFU</footer>')
  )
)

body <- dashboardBody(
  tabItems(
    tabItem("Home",
      box(title = "Uploaded CT Values", width = 8,
          status = "info", solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE,
          tableOutput('ct')
      ),
      box(title = "Relative Expression Levels", width = 8,
          status = "info", solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE,
          tableOutput('expr')
      ),
      box(title = "Barplot of Relative Expression Levels", width = 8,
          status = "info", solidHeader = TRUE, collapsible = TRUE,
          plotOutput('barplot')
      )
    ),
    tabItem("About",
       includeMarkdown("README.md")
    )
  )
)

shinyUI(
  column(10, offset = 1,
    dashboardPage(
      header,
      sidebar,
      body,
      skin = c("blue")
    )
  )
)
