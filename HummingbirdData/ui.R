library(shiny)
library(leaflet)
library(dplyr)

plants<-read.csv("PlantTransects.csv") %>% filter(!is.na(lat)) %>% droplevels()
plants<-levels(plants$plant_field_name)

# Define UI for application 
shinyUI(
  fluidPage(
  
  # Application title
  titlePanel("Hummingbird Interactions of Northwest Ecuador"),

  # Sidebar with a slider input for number of bins 
  leafletOutput("mymap"),
  
  #Transects
  mainPanel(
  
  h2("Flower Transects"),
  "Each month our field team collects information on the hummingbird visited flowers along 12 1.5km transects",
  tableOutput('tran_table'),
  plotOutput("plant_elev"),
  plotOutput('phenology'),

  #Plant map
  br(),
  column(2,selectizeInput("plant_species", "Plant Species", plants, selected = NULL, multiple = FALSE,options = NULL)),
  column(10,leafletOutput("plant_map")),  
  br(),
  
  h3("Birds"),
  plotOutput("hum_elev"),
  h2("Cameras"),
  column(5,tableOutput('cam_table')),
  column(7,tableOutput('int_table')),
  br(),
  br(),
  plotOutput('int_plot'),
  "Site design by Ben Weinstein - Oregon State University",
  paste("Last updated",Sys.time())


     )
    )
  )

