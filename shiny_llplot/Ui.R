# GUI part of the llplot shiny app
# Author:Crt Ahlin

# library for interactive web pages
library(shiny)

shinyUI(
  
  pageWithSidebar(
    
    headerPanel("Heart rate and other life logging data"),              
    sidebarPanel(
    helpText("version: 0.1"),
      h5("Demo data is plotted by default, if no user data is uploaded. Feel free to experiment."),
      hr(),
      h5("Heart rate data can currently only be uploaded in the CSV format exported from the AIRS app. See: "),
      a("http://tecvis.co.uk/software/airs/synchronise",href="http://tecvis.co.uk/software/airs/synchronise"),
      
      selectInput(inputId="selectedFormat",
                  label="Select data format:",
                  selected="AIRS", 
                  choices=c("AIRS CSV"="AIRS")),
      
      fileInput(inputId="dataFileAIRS", label="HR data file", multiple=TRUE),
      
      hr(),
      h5("The defult date range covers all of the demo data."),
      dateRangeInput(inputId="dateRange", 
                     label="Date range:",
                     start="2014-04-23",
                     end="2014-04-29",
                     format="d.m.yyyy" ),
      
      hr(),
      h5("Different levels of detail (faceting) are possible."),
      selectInput(inputId="selectedFacet",
                  label="Faceting by:", choices=c(
                    "No faceting"="noFacet",
                    "Day of the week"="weekdayFacet",
                    "Day"="dayFacet" ),
                  selected="noFacet",
                  multiple=FALSE),
      
      hr(),
      h5("Only one kind of 'typical' curve is supported at the moment. "),
      selectInput(inputId="selectedPlotMethod",
                  label="Select curve type:",
                  choices=c("No smoother" = "noSmooth",
                            "Cyclic cubic polynomial (not implemented)"="cycCubPoly",
                            "Cyclic fractional polynomial (not implemented)"="cycFracPoly",
                            "Cyclic GAM smoother"="cycGAMSmooth"),
                  selected="cycGAMSmooth", multiple=FALSE),
      
      hr(),
      h5("
               Fitbit data can be uploaded in CSV format as exported from Google spreadsheets.
               How to get the data into Google spreadsheets is described in:"),
      a("http://quantifiedself.com/2013/02/how-to-download-fitbit-data-using-google-spreadsheets/",
        href=" http://quantifiedself.com/2013/02/how-to-download-fitbit-data-using-google-spreadsheets/"),
      fileInput(inputId="dataFileFitbit",label="Fitbit data file"), #,
      
      h5("The code for this app can be found on Github, where you can also post suggestions and bug reports (as issues). See:"),
      a("https://github.com/crtahlin/QS2014",href="https://github.com/crtahlin/QS2014")
      
      # checkboxInput(inputId="drawFitbit",label="Draw fitbit data",value=TRUE),
#       
#       selectInput(inputId="selectedFitbitVars",
#                   label="Select Fitbit variables",
#                   choices=c(
#                     "Steps"="steps",                                       
#                     "Minutes very active"="minutesVeryActive",
#                     "Minutes asleep"="minutesAsleep",
#                     "Times awaken"="awakeningsCount"),
#                   selected="steps",
#                   multiple=TRUE)
      
    ),
    mainPanel(
      tabsetPanel(
        
        tabPanel(title="Graphs",
                plotOutput("plotHP", height="auto")
                 ),
      
        tabPanel(title="HP Data",
               p("100 random data points."),        
               tableOutput("dataHP")),
        
        tabPanel(title="Fitbit data",
               p("First 100 data points."),
               tableOutput("dataFitbit")
               )
        )
      )
    )
  )