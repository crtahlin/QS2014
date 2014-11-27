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
    
  # load the demo data ####
  load("DemoData.Rdata")
  
  # set plot heights ####
  plotHeight <- function() {
    if(!is.null(dataHPFiltered())) {
    if(input$selectedFacet == "dayFacet") {
    height <- min(as.numeric(input$dateRange[2]- input$dateRange[1])*350,
                  4000)
    return(height)
    } 
    if (input$selectedFacet == "weekdayFacet") {
      height <- 7*300
      return(height)
    } 
    height <- 700
    return(height)
    } else {return(0)}
  }
  
  dataHP <- reactive(function(){
    if (!is.null(input$dataFileAIRS)) {
    # print(input$dataFileAIRS)
    data <- AIRSImportMultiple(dataFilesAIRS=input$dataFileAIRS, sensor="HP")  
    data$Day <- as.Date(data$Day, format="%d.%m.%Y")
    return(data)
    } else { # if no user data loaded, use demo data
    # sample a smaller data set
      set.seed(1234)
      data <- AIRSDemoData[sample(1:dim(AIRSDemoData)[1], size=40000),]
      data$Day <- as.Date(data$Day, format="%d.%m.%Y")
      return(data)
    }
  })
  
  
  dataHPFiltered <- reactive({
    if(!is.null(dataHP())) {
    data <- subset(dataHP(),
                   subset={(as.Date(dataHP()$Day, format="%d.%m.%Y") >= input$dateRange[1]) &
                             (as.Date(dataHP()$Day, format="%d.%m.%Y") <= input$dateRange[2]) })
    print(str(data))
    return(data)
    }
  })
  
  
  dataFitbit <- reactive(function(){
    if(!is.null(input$dataFileFitbit)) {
    data <- read.csv(file=input$dataFileFitbit$datapath)  
    # import only some variables (that carry relevant info)
    data <- data[,c("date", "steps", "minutesAsleep", "awakeningsCount", "minutesVeryActive")]
    data$date <- as.Date(data$date, format="%d.%m.%Y")
    #data[,"date"] <- as.Date(data[,"date"], format="%d.%m.%Y")
    colnames(data)[which(colnames(data)=="date")] <- "Day"
    return(data)
    } else { # if no user data is uploaded, use demo data
    data <- FitbitDemoData
    # import only some variables (that carry relevant info)
    data <- data[,c("date", "steps", "minutesAsleep", "awakeningsCount", "minutesVeryActive")]
    data$date <- as.Date(data$date, format="%d.%m.%Y")
    #data[,"date"] <- as.Date(data[,"date"], format="%d.%m.%Y")
    colnames(data)[which(colnames(data)=="date")] <- "Day"
    return(data)
    }
  })
  
  dataFitbitFiltered <- reactive ({
    if (!is.null(dataFitbit())){
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
    }
  })
  
  output$dataHP <- renderTable(if (!is.null(dataHP())) {
    data <- dataHP()[sample(seq(dim(dataHP())[1]), size=100),
                                         c("Value", "CyclicTime", "Weekday", "Day")] 
    data$Day <- as.character(data$Day)
    return(data)
    })
  
  output$dataFitbit <- renderTable(if (!is.null(dataFitbitFiltered())) {
    data <- head(dataFitbitFiltered(), n=100)
    data$Day <- as.character(data$Day)
    return(data)
    })
  
  output$plot <- renderPlot(
    if(!is.null(dataHP())){expr={hist(dataHP()$Value, breaks=50)}}
    )
  output$plotHP <- renderPlot(
    if(!is.null(dataHPFiltered())) {
    expr={
      
      p <- ggplot(data=dataHPFiltered()) + 
        theme_bw() + 
        geom_point(aes(x=CyclicTime, y=Value), alpha=0.2) + 
        scale_x_continuous(breaks=c(0,0.25,0.5,0.75,1),labels=c("midnight","6 o'clock","noon","18 o'clock","midnight")) 
        
      # should smoother be ploted?
      if (input$selectedPlotMethod == "cycGAMSmooth") {
      p <- p + geom_smooth(aes(x=CyclicTime, y=Value), size=2, method="gam", formula = y~s(x, bs="cc"), se=FALSE)
      }
      
      # faceting by weekday
      if (input$selectedFacet == "weekdayFacet") { 
        p <- p + facet_grid(Weekday ~ .)}
      # faceting by day
      if (input$selectedFacet == "dayFacet") { 
        p <- p + facet_grid(Day ~ .)}
      
      # testing adding fitbit data
      if (input$selectedFacet == "dayFacet") { 
        p <- p + geom_text(data=dataFitbitFiltered(),
                           aes(x=0.5, y=40,
                               label=paste(
                                 "Steps count:", steps, 
                                 " Minutes very active:", minutesVeryActive,
                                 " Minutes asleep:", minutesAsleep,
                                 " Number of awakenings:", awakeningsCount
                                 
                                 )))
        # p <- p + annotate("text", label=dataFitbitFiltered()$steps, x=0, y=0)
        
      }
      
      print(p)
    }}, height=plotHeight
    )
  
  #output$debug1 <- renderText(input$dataFile$datapath)
})
