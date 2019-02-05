library(shiny)
library(leaflet)
library(dplyr)
library(kableExtra)
library(shinythemes)
transects<-read.csv("PlantTransects.csv") %>% droplevels()
int_data<-read.csv("Interactions.csv",row.names=1)

plants<-levels(transects$final_plant_name)

# Define UI for application 
shinyUI(
  fluidPage(theme = shinytheme("cosmo"),
    mainPanel(width=10,
  # Application title
  titlePanel("Hummingbird-Plant Interactions of Northwest Ecuador"),
  
  # Sidebar with a slider input for number of bins 
  leafletOutput("mymap"),
  
  h1("Summary"),
  
  p(paste("We have collected" ,nrow(transects), "flowering plant records for",n_distinct(transects$final_plant_name),"species at",length(unique(transects$site)),"sites.")),
  p(paste("We have filmed ",n_distinct(int_data$waypoint),"flowers", "and documented", nrow(int_data),"interactions between",n_distinct(int_data$final_plant_name), "species of flowers and",n_distinct(int_data$hummingbird), "species of hummingbirds.")),
  
  #Transects
  h2("Flower Transects"),
  "Each month our field team collects information on the hummingbird visited flowers along 12 1.5km transects",
  tableOutput('tran_table'),
  p("Our sites cover a wide elevation gradient from 800m to 3000m."),
  plotOutput("plant_elev",width=1000,height=1500),
  p("Available flowers change over time as new species come into bloom."),
  plotOutput('phenology',height=450,width=1250),

  #Plant map
  br(),
  p("This interactive map shows where the plant species occur"),
  column(2,selectizeInput("plant_species", "Plant Species", plants, selected = "Columnea ciliata", multiple = FALSE,options = NULL)),
  column(10,leafletOutput("plant_map")),  
  br(),
  
  h3("Birds"),
  plotOutput("hum_elev",width=900,height=900),
  h2("Cameras"),
  p("Each month we set cameras to record hummingbird-plant interactions."),
  fluidRow(
  column(5,tableOutput('cam_table')),
  column(7,tableOutput('int_table'))
  ),
  h2("Interaction Matrix"),
  plotOutput('int_plot',width=2000,height=700),
  p("Site design by Ben Weinstein - University of Florida"),
  paste("Last updated",Sys.time())
     )
    ))
