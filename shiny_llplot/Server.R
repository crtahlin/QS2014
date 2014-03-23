# Server part of the llplot shiny app
# Author:Crt Ahlin

# library for interactive web pages
library(shiny)

# AIRS data import library
# devtools::install_github(repo="AIRS_Data_Import", username="crtahlin")
library(AIRSDataImport)

# library for plotting
library(ggplot2)

shinyServer( function(input, output, session) {
  dataHP <- reactive(function(){
    data <- AIRSImport(filePath=input$dataFileAIRS$datapath, sensor="HP")  
    return(data)
    })
  
  dataFitbit <- reactive(function(){
    data <- read.csv(file=input$dataFileFitbit$datapath)  
    return(data)
  })
  
  output$dataHP <- renderTable(head(dataHP(), n=100))
  output$dataFitbit <- renderTable(head(dataFitbit(), n=100))
  
  output$plot <- renderPlot(expr={hist(dataHP()$Value, breaks=50)})
  
  #output$debug1 <- renderText(input$dataFile$datapath)
})
