library(shiny)
library(maptools)
library(dplyr)
library(htmltools)
library(ggplot2)

server <- function(input, output, session) {
  Sys.setlocale('LC_ALL','C') 
  
  #Site Map
  d<-read.csv("Sites.csv",row.names=1)
  d$Site<-rownames(d)
  m <- leaflet(d) %>% addTiles() %>% addMarkers(~long,~lat,popup=~Site)
  output$mymap <- renderLeaflet(m)
  
  #Transect Data
  transects<-read.csv("PlantTransects.csv",row.names=1)
  
  #How many transects by site
  mostc<-function(x){names(sort(table(x),decreasing=T))[1]}
  tran_table<-transects %>% group_by(site) %>% summarize(N=length(unique(date)),Species=length(unique(plant_field_name)),total_flowers=sum(total_flowers),Top_Plant=mostc(plant_field_name))
  
  #Plot of flower count over time
  output$tran_table<-renderTable(tran_table)
  
  #Phenology plots
  #month factor
  transects$Month<-factor(transects$Month,levels=month.name)
  phenology<-transects %>% group_by(site,Month,Year) %>% summarize(total_flowers=sum(total_flowers))
  output$phenology<-renderPlot({
    p<-ggplot(data=phenology,aes(x=Month,y=total_flowers,col=site)) + facet_wrap(~Year) + geom_point() + geom_line(aes(group=site)) + labs(y="Flowers",col="Site")
    print(p)
  },height=350,width=750)
  
  #Camera Data
  camera_dat<-read.csv("Cameras.csv")
  
  ## summary table
  cam_table<-camera_dat %>% group_by(site) %>% summarize(n=n(),plant_species=length(unique(plant_field_name)))
  output$cam_table<-renderTable(cam_table)
  
  #Interaction Data
  int_data<-read.csv("Interactions.csv")
  
  #Summary Table
  int_data %>% group_by(site) %>% summarize(n=n(),hummingbird_species=length(unique(hummingbird)))
  ##plant map  
  
  ##Bird map
  
  ##Interactions by site
  
  ## Across sites
}
