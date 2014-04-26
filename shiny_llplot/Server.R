# Server part of the llplot shiny app
# Author:Crt Ahlin

# set maximus size of file upload
options(shiny.maxRequestSize=30*1024^2)

# library for interactive web pages
library(shiny)

# AIRS data import library
library(AIRSDataImport)

# library for plotting
library(ggplot2)

# library fo GAM
library(mgcv)

shinyServer( function(input, output, session) {
  
  plotHeight <- function() {
    if(input$selectedFacet == "dayFacet") {
    height <- min(as.numeric(input$dateRange[2]- input$dateRange[1])*300,
                  4000)
    } else {
    height <- 700}
    return(height)
  }
  
  dataHP <- reactive(function(){
    # print(input$dataFileAIRS)
    data <- AIRSImportMultiple(dataFilesAIRS=input$dataFileAIRS, sensor="HP")  
    data$Day <- as.Date(data$Day, format="%d.%m.%Y")
    return(data)
  })
  
  
  dataHPFiltered <- reactive({
    data <- subset(dataHP(),
                   subset={(as.Date(dataHP()$Day, format="%d.%m.%Y") >= input$dateRange[1]) &
                             (as.Date(dataHP()$Day, format="%d.%m.%Y") <= input$dateRange[2]) })
    print(str(data))
    return(data)
  })
  
  
  dataFitbit <- reactive(function(){
    data <- read.csv(file=input$dataFileFitbit$datapath)  
    data <- data[,c("date", "steps", "minutesAsleep", "awakeningsCount")]
    data$date <- as.Date(data$date, format="%d.%m.%Y")
    #data[,"date"] <- as.Date(data[,"date"], format="%d.%m.%Y")
    colnames(data)[which(colnames(data)=="date")] <- "Day"
    return(data)
  })
  
  dataFitbitFiltered <- reactive ({
    # only take those days for which HR data exists?
    # TODO
    
    # dayswithHR <- unique(dataHPFiltered()$Day)
    #data <- subset(dataFitbit(),
    #       subset={(as.Date(dataFitbit()$Day, format="%d.%m.%Y") >= input$dateRange[1]) &
    #                 (as.Date(dataFitbit()$Day, format="%d.%m.%Y") <= input$dateRange[2]) })
    
    #TODO - do proper filtering!
    #data <- subset(dataFitbit(), subset={dataFitbit()$Day==dayswithHR})
    
    data <- subset(dataFitbit(),
                   subset={(as.Date(dataFitbit()$Day, format="%d.%m.%Y") >= input$dateRange[1]) &
                             (as.Date(dataFitbit()$Day, format="%d.%m.%Y") <= input$dateRange[2]) })
    # data <- dataFitbit()["Day"==dayswithHR,]
    print(str(data))
    return(data)
  })
  
  output$dataHP <- renderTable( dataHP()[sample(seq(dim(dataHP())[1]), size=100),
                                         c("Value", "CyclicTime", "Weekday", "Day")] )
  
  output$dataFitbit <- renderTable(head(dataFitbitFiltered(), n=100))
  
  output$plot <- renderPlot(expr={hist(dataHP()$Value, breaks=50)})
  output$plotHP <- renderPlot(
    expr={
      
      p <- ggplot(data=dataHPFiltered()) + 
        theme_bw() + 
        geom_point(aes(x=CyclicTime, y=Value)) + 
        scale_x_continuous(limits=c(0,1)) +
        geom_smooth(aes(x=CyclicTime, y=Value), method="gam", formula = y~s(x, bs="cc"))
      # faceting by weekday
      if (input$selectedFacet == "weekdayFacet") { 
        p <- p + facet_grid(Weekday ~ .)}
      # faceting by day
      if (input$selectedFacet == "dayFacet") { 
        p <- p + facet_grid(Day ~ .)}
      
      # testing adding fitbit data
      if (input$selectedFacet == "dayFacet") { 
        p <- p + geom_text(data=dataFitbitFiltered(), aes(x=0.15, y=40, label=paste("Steps count:", steps)))
        # p <- p + annotate("text", label=dataFitbitFiltered()$steps, x=0, y=0)
        
      }
      
      print(p)
    }, height=plotHeight
  )
  
  #output$debug1 <- renderText(input$dataFile$datapath)
})
