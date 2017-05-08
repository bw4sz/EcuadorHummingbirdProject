#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
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
  plotOutput("plant_elev"),
  plotOutput('phenology'),
  h1("Cameras"),
  tableOutput('cam_table'),
  "Observations",
  tableOutput('int_table'),
  plotOutput('int_plot')
)))
