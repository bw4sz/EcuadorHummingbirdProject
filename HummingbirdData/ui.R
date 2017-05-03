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
  
  #Transects
  inputPanel("Flower Transects"),
  tableOutput('tran_table')
))
