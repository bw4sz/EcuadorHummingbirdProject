library(shiny)
library(leaflet)
library(dplyr)

plants<-read.csv("PlantTransects.csv") %>% filter(!is.na(lat)) %>% droplevels()
plants<-levels(plants$plant_field_name)

# Define UI for application 
shinyUI(
  fluidPage(
    mainPanel(width=10,
  # Application title
  titlePanel("Hummingbird-Plant Interactions of Northwest Ecuador"),

  # Sidebar with a slider input for number of bins 
  leafletOutput("mymap"),
  
  #Transects
  
  h2("Flower Transects"),
  "Each month our field team collects information on the hummingbird visited flowers along 12 1.5km transects",
  tableOutput('tran_table'),
  p("Our sites cover a wide elevation gradient from 800m to 3000m."),
  plotOutput("plant_elev"),
  p("Available flowers changes over time as new species come into bloom"),
  plotOutput('phenology'),

  #Plant map
  br(),
  p("This interactive map shows where the plant species occur"),
  column(2,selectizeInput("plant_species", "Plant Species", plants, selected = NULL, multiple = FALSE,options = NULL)),
  column(10,leafletOutput("plant_map")),  
  br(),
  
  h3("Birds"),
  plotOutput("hum_elev"),
  h2("Cameras"),
  fluidRow(
  column(5,tableOutput('cam_table')),
  column(7,tableOutput('int_table'))
  ),
  plotOutput('int_plot'),
  p("Site design by Ben Weinstein - Oregon State University"),
  paste("Last updated",Sys.time())
     )
    ))