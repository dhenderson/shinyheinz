# Import our dependencies
library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(leaflet)
library(plotly)

# Anything that happens here, before the shinyServer(...) function
# is loaded once when the application is started. This is a 
# good place to load our data

# load the data before starting up the application
crashes <- read.csv("data/crashes_2015_clean.csv")

# order the day of week levels
crashes$DAY_OF_WEEK <- ordered(crashes$DAY_OF_WEEK, 
                               levels = c("Sunday", "Monday", "Tuesday",
                                          "Wednesday", "Thursday", "Friday",
                                          "Saturday"))

# Define server logic
shinyServer(function(input, output) {
  # Everything in here is after the application is started
  # and is specific to each user session. That means
  # if one user subsets the data in a specific way, the 
  # change is only reflected in that one user's session,
  # not across all sessions.
  
  # setup our data --------
  
  crashData <- reactive({
    #' Reactive function that subsets our data based on 
    #' user input and returns a data frame.
    crash_data <- dplyr::filter(crashes,
      # speeding
      SPEED_LIMIT >= input$speed_range[1],
      SPEED_LIMIT <= input$speed_range[2]
    )
    
    # check if we have specified any days of the week
    if(length(input$days_of_week) > 0){
      crash_data <- crash_data %>%
        dplyr::filter(
          DAY_OF_WEEK %in% input$days_of_week
        )
    }
    
    # check if we want to subset speeding related
    if(input$speeding_related != "both"){
      crash_data <- crash_data %>%
        dplyr::filter(
          SPEEDING_RELATED == input$speeding_related
        )
    }
    
    # check if we want to subset by impaired driver
    if(input$impaired_driver != "both"){
      crash_data <- crash_data %>%
        dplyr::filter(
          IMPAIRED_DRIVER == input$impaired_driver
        )
    }
    
    return(crash_data)
  })
  
  # create some output ----------
  
  output$total_crashes <- renderText({
    # Count the total number of crashes we are exploring
    # and return some text in the form "Exploring x crashes"
    crash.count <- format(nrow(crashData()), big.mark=",")
    paste("Exploring", crash.count, "crashes", sep=" ")
  })
  
  output$crash_by_day_speed_limit <- renderPlotly({
    crashData() %>%
      ggplot(aes(x=DAY_OF_WEEK, y=SPEED_LIMIT)) + 
      geom_boxplot() + 
      labs(
        title = "Crashes by day of week",
        x = "Day of week",
        y = "Number of crashes"
      )
    ggplotly()
  })
  
  output$crash_speed_chart <- renderPlotly({
    # Generate a bar chart with speed limits on the 
    # x axis and a count of the number of crashes on 
    # the y axis with ggplot, then render it using the
    # Plotly javascript library.
    crashData() %>%
      dplyr::group_by(SPEED_LIMIT) %>%
      dplyr::summarise(
        count_crashes = n()
      ) %>%
      ggplot(aes(x=SPEED_LIMIT, y=count_crashes)) + 
      geom_bar(stat="identity") + 
      labs(
        title="Number of crashes by speed limit",
        x="Speed limit",
        y="Number of crashes"
      )
    # call the ggplotly function from the plotly package 
    # to return our ggplot as a javasript chart rather 
    # than as an image. You can use ggplot images if you 
    # prefer, but Plotly gives us nice rollover effects.
    plotly::ggplotly()
  })
  
  output$map <- renderLeaflet({
    # Let's add a map to our application that shows the 
    # user where the crashes took place. We will build the 
    # map with the Leaflet package, allowing the user
    # to interactively scroll around the map.
    
    leaflet(data=crashData()) %>%
      # use the CartoDB map for more subdued map tile colors
      addProviderTiles("CartoDB.Positron") %>%
      
      addMarkers(~DEC_LONG, ~DEC_LAT,
                 # the marker clusters gives us a nice visual 
                 # effect where when we zoom out points cluster
                 # together, and as we zoom in they are pulled apart
                 # showing the individual markers.
                 clusterOptions = markerClusterOptions())
  })
  
})