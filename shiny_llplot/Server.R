# Server part of the llplot shiny app
# Author:Crt Ahlin

# library for interactive web pages
library(shiny)

# AIRS data import library
library(AIRSDataImport)

# library for plotting
library(ggplot2)

shinyServer( function(input, output, session) {
  
  dataHP <- reactive(function(){
    # print(input$dataFileAIRS)
    data <- AIRSImportMultiple(dataFilesAIRS=input$dataFileAIRS, sensor="HP")  
    return(data)
    browser()
    print(data)
    })
  
  dataFitbit <- reactive(function(){
    data <- read.csv(file=input$dataFileFitbit$datapath)  
    return(data)
  })
  
  output$dataHP <- renderTable( dataHP()[sample(seq(dim(dataHP())[1]), size=100),] )
  output$dataFitbit <- renderTable(head(dataFitbit(), n=100))
  
  output$plot <- renderPlot(expr={hist(dataHP()$Value, breaks=50)})
  output$plotHP <- renderPlot(
    expr={
      p <- ggplot(data=dataHP()) + 
        theme_bw() + 
        geom_point(aes(x=CyclicTime, y=Value)) + 
        scale_x_continuous(limits=c(0,1)) +
        geom_smooth(aes(x=CyclicTime, y=Value))
      print(p)
    }
    )
  
  #output$debug1 <- renderText(input$dataFile$datapath)
})
