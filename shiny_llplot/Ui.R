# GUI part of the llplot shiny app
# Author:Crt Ahlin

# library for interactive web pages
library(shiny)

shinyUI(
  
  pageWithSidebar(
    
    headerPanel("Heart rate and other life logging data"),              
    sidebarPanel(
      helpText("Upload heart rate data in AIRS or format."),
      
      selectInput(inputId="selectedFormat",
                  label="Select data format",
                  selected="AIRS", 
                  choices=c("AIRS CSV"="AIRS")),
      
      fileInput(inputId="dataFileAIRS", label="HR data file", multiple=TRUE),
      
      dateRangeInput(inputId="dateRange", 
                     label="Date range",
                     start="2014-04-01",
                     format="d.m.yyyy" ),
      
      selectInput(inputId="selectedFacet",
                  label="Faceting by", choices=c(
                    "No faceting"="noFacet",
                    "Day of the week"="weekdayFacet",
                    "Day"="dayFacet" ),
                  selected="noFacet",
                  multiple=FALSE),
      
      selectInput(inputId="selectedPlotMethod",
                  label="Select plotting method",
                  choices=c("Cyclic cubic polynomial (not implemented)"="cycCubPoly",
                            "Cyclic fractional polynomial (not implemented)"="cycFracPoly",
                            "Cyclic GAM smoother"="cycGAMSmooth"),
                  selected="cycGAMSmooth", multiple=TRUE),
      
      fileInput(inputId="dataFileFitbit",label="Fitbit data file") #,
      
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
                 plotOutput("plot"),
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