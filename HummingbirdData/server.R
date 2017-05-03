library(shiny)
library(maptools)
library(dplyr)
library(htmltools)

server <- function(input, output, session) {
  
  #Site Map
  d<-read.csv("Sites.csv",row.names=1)
  d$Site<-rownames(d)
  m <- leaflet(d) %>% addTiles() %>% addMarkers(~long,~lat,popup=~Site)
  output$mymap <- renderLeaflet(m)
  
  #Transect Data
  transects<-read.csv("PlantTransects.csv",row.names=1)
  
  #How many transects by site
  mostc<-function(x){names(sort(table(x),decreasing=T))[1]}
  tran_table<-transects %>% group_by(site) %>% summarize(N=length(unique(Date,transect_code)), total_flowers=sum(total_flowers),Top_Plant=mostc(plant_field_name))
  
  #Plot of flower count over time
  output$tran_table<-renderTable(tran_table)
  
  #Camera Data
  
  #Interaction Data
  
  #Summary Table
  
  ##Phenology by site
  
  ##Interactions by site
  
  ## Across sites
}
