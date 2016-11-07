# First import our dependencies
library(shiny)
library(leaflet)
library(plotly)

# Define the UI for the application
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Allegheny County Crashes 2015"),
  
  # Let's use the sidebar layout to layout our application. As the name
  # implies, the sidebar layout has a sidebar (default to the left side)
  # and then a main panel on the right.
  sidebarLayout(
    # Create a sidebar that gives the user the option to 
    # specify grant date ranges, grant duration in years, 
    # and the grant amount range.
    sidebarPanel(
      # Add any number of UI inputs in the sidebar panel
      
      # First, let's add a speed limit range option
      sliderInput("speed_range",
                  "Speed limit range",
                  min = 10,
                  max = 65,
                  step = 5, 
                  value = c(10, 65)),
      
      # Day of the week
      selectInput("days_of_week", "Days of the week", 
                  choices = c(
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday"
                  ), selected = NULL, multiple = TRUE,
                  selectize = TRUE),
      
      # Speeding
      radioButtons("speeding_related", "Speeding related", 
                   choices = c(
                    "Both" = "both",
                    "Yes" = TRUE,
                    "No" = FALSE
                   )),
    
      # Impaired
      radioButtons("impaired_driver", "At least One Driver was Impaired by Drugs or Alcohol", 
                   choices = c(
                     "Both" = "both",
                     "Yes" = TRUE,
                     "No" = FALSE
                   ))
    ),
    
    # Now that the user inputs have been specified, let's add
    # output to the main panel of the UI.
    mainPanel(
      
      h2(textOutput("total_crashes")),
      
      # Because we have a few charts and tables, let's first organize
      # everything into tabs by using the tabsetPanel(...) function.
      tabsetPanel(
        
        # The first tab we'll create will let the user explore 
        # the number of collisions by speed limit
        tabPanel("Collision count by speed limit",
          plotlyOutput("crash_speed_chart")
        ),
        
        tabPanel("Crashes by day and speed limit",
                 plotlyOutput("crash_by_day_speed_limit")
        ),
        
        # The second tab will show a map of where the crashes occured
        tabPanel("Map",
          leafletOutput("map", width = "100%", height = 650)
        )
        
      )
    )
  )
))