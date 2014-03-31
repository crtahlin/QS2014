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
    })
  
  dataFitbit <- reactive(function(){
    data <- read.csv(file=input$dataFileFitbit$datapath)  
    data <- data[,c("date", "steps", "minutesAsleep", "awakeningsCount")]
    # browser()
    data$date <- format(data$date, format="%d.%m.%Y")
    #data[,"date"] <- as.Date(data[,"date"], format="%d.%m.%Y")
    return(data)
  })
  
  output$dataHP <- renderTable( dataHP()[sample(seq(dim(dataHP())[1]), size=100),] )
  output$dataFitbit <- renderTable(head(dataFitbit(), n=100))
  
  output$plot <- renderPlot(expr={hist(dataHP()$Value, breaks=50)})
  output$plotHP <- renderPlot(
    expr={
      dataFiltered <- subset(dataHP(), subset={(as.Date(dataHP()$Day, format="%d.%m.%Y") >= input$dateRange[1]) &
                                                 (as.Date(dataHP()$Day, format="%d.%m.%Y") <= input$dateRange[2]) })
      p <- ggplot(data=dataFiltered) + 
        theme_bw() + 
        geom_point(aes(x=CyclicTime, y=Value)) + 
        scale_x_continuous(limits=c(0,1)) +
        geom_smooth(aes(x=CyclicTime, y=Value))
      # faceting by weekday
      if (input$selectedFacet == "weekdayFacet") { 
        p <- p + facet_grid(Weekday ~ .)}
      # faceting by day
      if (input$selectedFacet == "dayFacet") { 
        p <- p + facet_grid(Day ~ .)}
      
      print(p)
    }
    )
  
  #output$debug1 <- renderText(input$dataFile$datapath)
})
