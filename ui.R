library(shiny)
library(markdown)

shinyUI(navbarPage("qdavit",

tabPanel("Home",
fluidRow(
  sidebarLayout(
    # sidebar
    sidebarPanel(
      fileInput('file1', 'Choose CSV/TSV File',
                accept=c('text/csv', 'text/comma-separated-values,text/plain')),
      downloadButton("downloadData", "Demo CSV File"),
      tags$hr(),
      checkboxInput('header', 'Header', TRUE),
      numericInput("lctrl", "Line of control", 1, min = 1),
      radioButtons('sep', 'Separator',
                   c(Comma=',',
                     Tab='\t'),
                   selected = ','),
      checkboxInput('returnpdf', 'Output PDF', FALSE),
      conditionalPanel(
        condition = "input.returnpdf == true",
        downloadLink('savepdf')
      ),
      tags$hr(),
      HTML('<footer>(c) 2017 Qinhu Wang, NWAFU</footer>')
    ),
    # main panel
    mainPanel(
      tableOutput('ct'),
      tableOutput('expr'),
      plotOutput('barplot')
    )
  )
)),

tabPanel("About",
fluidRow(column(1),column(10,
  includeMarkdown("README.md")
),column(1)
))

))
