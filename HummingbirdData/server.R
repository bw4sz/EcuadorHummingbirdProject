library(shiny)
library(maptools)
library(dplyr)
library(htmltools)
library(ggplot2)
library(leaflet)

server <- function(input, output, session) {
  Sys.setlocale('LC_ALL','C') 
  
  #Site Map
  d<-read.csv("Sites.csv",row.names=1)
  d$Site<-rownames(d)
  m <- leaflet(d) %>% addTiles() %>% addMarkers(~long,~lat,popup=~paste(Site,paste(min_elev,max_elev,sep=" - ")))
  output$mymap <- renderLeaflet(m)
  
  #Transect Data
  
  #TODO put hummingbird transect numbers and elevation information
  transects<-read.csv("PlantTransects.csv",row.names=1)

  #How many transects by site
  mostc<-function(x){names(sort(table(x),decreasing=T))[1]}
  tran_table<-transects %>% group_by(site) %>% summarize(Transects_Performed=length(unique(date)),Plant_Species=length(unique(plant_field_name)),Total_Flowers=sum(total_flowers),Top_Plant=mostc(plant_field_name))
  
  #Plot of flower count over time
  output$tran_table<-renderTable(tran_table)
  
  #Phenology plots
  #month factor
  
  transects$Month<-factor(transects$Month,levels=month.name)
  phenology<-transects %>% group_by(site,Month,Year) %>% summarize(total_flowers=sum(total_flowers),ele=mean(elevation),n=n()) %>% filter(Year %in% 2017)
  output$phenology<-renderPlot({
    p<-ggplot(data=phenology,aes(x=Month,y=total_flowers,col=ele)) + facet_wrap(~Year) + geom_point(size=4) + geom_line(aes(group=site)) + labs(y="Flowers",col="Site") + theme_bw()
    print(p)
  })
  
  #plant elevation ranges
  #screen plants with more than 20 records
  common_plants<-transects %>% group_by(plant_field_name) %>% summarise(n=n()) %>% filter(n>20)
  common_totals<-transects %>% filter(!is.na(elevation)) %>% filter(plant_field_name %in% common_plants$plant_field_name)
  
  #lowest to highest elevation factor order
  plant_ord<-common_totals  %>% droplevels() %>% group_by(plant_field_name) %>% summarize(e=mean(as.numeric(elevation))) %>% arrange(e) %>% .$plant_field_name
  common_totals$plant_field_name <- factor(common_totals$plant_field_name,levels=plant_ord)
  plant_elev<-ggplot(common_totals,aes(x=plant_field_name,y=as.numeric(elevation))) + geom_boxplot(aes(fill=site)) + coord_flip() + theme_bw() + labs(x="Elevation(m)",y="Species",fill="Site") 
  output$plant_elev<-renderPlot(plant_elev)
  
  #Camera Data
  camera_dat<-read.csv("Cameras.csv")
  
  ## summary table
  cam_table<-camera_dat %>% group_by(site) %>% summarize(n=n(),plant_species=length(unique(plant_field_name)))
  output$cam_table<-renderTable(cam_table)
  
  #Interaction Data
  int_data<-read.csv("Interactions.csv",row.names=1)
  
  #Summary Table
  int_table<-int_data %>% group_by(site) %>% summarize(Observations=n(),Hummingbird_sp=length(unique(hummingbird)),Plant_sp=length(unique(plant_field_name)))
  output$int_table<-renderTable(int_table)
  
  #interaction table
  net_table<-int_data %>% group_by(plant_field_name,hummingbird) %>% filter(!is.na(plant_field_name)) %>% summarize(n=n()) %>% arrange()
  net_table<-droplevels(net_table)
  hum_ord<-net_table %>% group_by(hummingbird) %>% summarize(n=n()) %>% arrange(n) %>% .$hummingbird
  plant_ord<-net_table %>% group_by(plant_field_name) %>% summarize(n=n()) %>% arrange(desc(n)) %>% .$plant_field_name
  
  net_table$hummingbird<-factor(net_table$hummingbird,levels=hum_ord)
  net_table$plant_field_name<-factor(net_table$plant_field_name,levels = plant_ord)
  int_plot<-ggplot(net_table,aes(x=plant_field_name,y=hummingbird,fill=n)) + geom_tile() + labs(y="Hummingbird",x="Plant",fill="Observations") + theme_bw() + theme(axis.text.x=element_text(angle=-90)) + scale_fill_continuous(low="blue",high="red")
  output$int_plot<-renderPlot(int_plot)
  
  #Hummingbird elevation
  #combine both transects and cameras
  hum_tran<-read.csv("HummingbirdTransects.csv",row.names=1)
  hum_tran<-hum_tran %>% filter(!is.na(elevation)) %>% select(hummingbird,lon,lat,site,date,elevation)
  
  #get from bird data
  hum_cam<-int_data %>% filter(!is.na(elevation)) %>% select(hummingbird,lon,lat,site,date,elevation)
  hum<-bind_rows(list(hum_tran,hum_cam))

  #bird elevation range                 
  hum_ord<-hum  %>% droplevels() %>% group_by(hummingbird) %>% summarize(e=mean(as.numeric(elevation))) %>% arrange(e) %>% .$hummingbird
  hum$hummingbird <- factor(hum$hummingbird,levels=hum_ord)
  hum_elev<-ggplot(hum,aes(x=hummingbird,y=as.numeric(elevation))) + geom_boxplot(aes(fill=site)) + coord_flip() + theme_bw() + labs(x="Elevation(m)",y="Species",fill="Site") 
  output$hum_elev<-renderPlot(hum_elev)
  
  ##plant map  
  
  plant_map <- leaflet(d) %>% addTiles() %>% fitBounds(~min(long),~min(lat),~max(long),~max(lat))
  
  filteredData<-reactive({
    
    #filter based on selection
    if(!is.null(input$plant_species)){
      out<-transects %>% filter(plant_field_name %in% input$plant_species) %>%
        group_by(site,plant_field_name)  %>% top_n(1)
      return(out)
    }
  })
  
  #look for new selections
  observe({
    
    #add points
    if(!is.null(input$plant_species)){
      newdata<-filteredData()
        leafletProxy("plant_map",data=newdata)  %>% clearMarkers() %>%
          addMarkers(~lon,~lat,popup=~site)
        
    }
    
  })
  
  output$plant_map <- renderLeaflet(plant_map)
  
}
