library(shiny)
library(leaflet)

# Define UI for application 
shinyUI(fluidPage(
  
  # Application title
titlePanel("Hummingbird Interactions of the Northwest Ecuador"),

  # Sidebar with a slider input for number of bins 
  leafletOutput("mymap"),
  
  #Data Status, last updated. sys.time()
  #Transects
  mainPanel(
    h1("Flower Transects"),
  tableOutput('tran_table'),
  h2("Common Birds and Flowers"),
  "Birds",
  plotOutput("hum_elev"),
  "Flowers",
  plotOutput("plant_elev"),
  "Flower Phenology",
  plotOutput('phenology'),
  h1("Cameras"),
  tableOutput('cam_table'),
  "Camera Observations",
  tableOutput('int_table'),
  plotOutput('int_plot')
  
  # all site summary
)))
