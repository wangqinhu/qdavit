library(shiny)

shinyUI(pageWithSidebar(
  headerPanel("qPCR data visualization tool (qdavit)"),
  sidebarPanel(
    fileInput('file1', 'Choose CSV File',
              accept=c('text/csv', 'text/comma-separated-values,text/plain')),
    helpText("Note: A table file containing CT values  in csv/tsv format is expected.
Please ensure that the table is organized as follwing:
             1) each row represents a sample,
             2) each column represents a replicate,
             3) reference gene (left half) and test gene (right half) have the same number of replicates.
             4) sample name and replicate number are clearly labeled."),
    
    downloadButton("downloadData", "Demo"),
    
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
      downloadLink('pdflink')
    ),
    
    hr(),

    HTML('<footer>(c) 2017 Qinhu Wang, NWAFU</footer>')
    
  ),
  mainPanel(
    tableOutput('ct'),
    plotOutput("barplot", height = 300),
    plotOutput("pdfplot")

  )
))