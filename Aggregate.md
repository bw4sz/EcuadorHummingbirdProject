---
title: "AggregateData"
author: "Ben Weinstein"
date: "May 2, 2017"
output: html_document
---



#GPS Data


```r
allwaypoints<-list.files(basename,recursive=TRUE,full.name=TRUE,pattern=".gpx")
```


```r
#read in waypoints
wayfiles<-function(x){
    try(k<-readGPX(x,waypoints=TRUE)$waypoints)
    k$site<-str_match(x,"(\\w+)/waypoints")[2]
    if("cmt" %in% (colnames(k))){
      k$time<-k$cmt
    }
    return(k)
  }
wpoints<-lapply(allwaypoints,wayfiles)
wpoints<-wpoints[!sapply(wpoints,length)==1]

wpoints<-lapply(wpoints,function(x){
  k<-x %>% dplyr::select(lon,lat,elevation=ele,time,waypoint=name,site)
})

wpoints<-rbind_all(wpoints)
```


```r
#Standardize time field

get_time<-function(x){
  
  if(nchar(x)==20){
    b<-strsplit(as.character(x),"T")[[1]][2]
    #remove the z
    b<-strsplit(as.character(b),"Z")[[1]][1]
    timet<-format(strptime(b,"%H:%M:%S"),"%H:%M:%S")
    return(timet)
    }

#poco de choco string, ask nicole to change her GPS to english abbreviations?
if(nchar(x) %in% c(17,18)){
  timet<-strsplit(x," ")[[1]][[2]]
  return(timet)
}
 
  return(NA) 

}

wpoints$time_gps<-sapply(wpoints$time,get_time)
```


```r
#spanish lookup table
mt<-data.frame(Month=month.abb,Spanish=c("ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"))

#standardize date field
get_date<-function(x){
  if(nchar(x)==20){
    b<-strsplit(as.character(x),"T")[[1]][1]
    #remove the z
    datet<-format(strptime(b,"%Y-%m-%d"),"%d/%m/%Y")
    return(datet)
    }

  if(nchar(x) %in% c(17,18)){
  b<-strsplit(as.character(x),"T")[[1]][1]
  mnh<-strsplit(b," ")
  mn<-strsplit(mnh[[1]][1],"-")
  mn[[1]][2]<-as.character(mt$Month[mt$Spanish %in% mn[[1]][2]])
  paste(mn[[1]],collapse="-")
  datet<-format(strptime(b,"%d-%b-%y"),"%d/%m/%Y")
  return(datet)
  }
  return(NA)
}

wpoints$date_gps<-sapply(wpoints$time,get_date)

#create site id, month, year waypoint combination.
wpoints$Transect_ID<-paste(wpoints$site,wpoints$date_gps,wpoints$waypoint,sep="_")
wpoints$Camera_ID<-paste(wpoints$site,wpoints$waypoint,sep="_")

#delete duplicates
wpoints<-wpoints[!duplicated(wpoints),]
```


```r
#write gps points
write.csv(wpoints,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/GPS.csv")

#Write in case we want to visualize with the shiny data
write.csv(wpoints,"HummingbirdData/GPS.csv")
```

#Transect Data


```r
transect_files<-list.files(basename,recursive=TRUE,pattern="transect_",full.names=T)

transect_files<-transect_files[!str_detect(transect_files,"~")]

transect_xlsx<-lapply(transect_files,function(x){
  
  print(x)
  if(str_detect(x,".xlsx")){
    y<-read_xlsx(x)
    
    #turn waypoints to character for the moment
    y$waypoint<-as.character(y$waypoint)
    y$total_flowers<-as.character(y$total_flowers)
    y$height<-as.character(y$height)

  }
  if(str_detect(x,".csv")){
    y<-read.csv(x)
    
    #turn waypoints to character for the moment
    y$waypoint<-as.character(y$waypoint)
    y$total_flowers<-as.character(y$total_flowers)
  }
  
  return(y)
})
```

```
## [1] "C:/Users/Ben/Dropbox/HummingbirdProject/Data//Cambugan/transect_Cambugan.xlsx"
## [1] "C:/Users/Ben/Dropbox/HummingbirdProject/Data//LasGralarias/transect_lasgralarias.xlsx"
## [1] "C:/Users/Ben/Dropbox/HummingbirdProject/Data//Maquipucuna/transect_Maquipucuna.csv"
## [1] "C:/Users/Ben/Dropbox/HummingbirdProject/Data//MashpiCapuchin/transect_MashpiCapuchin (Copia en conflicto de Andres Marcayata 2017-07-13).xlsx"
```

```
## Error in `$<-.data.frame`(`*tmp*`, "waypoint", value = character(0)): replacement has 0 rows, data has 42
```

```r
#Combine files
transect_data<-bind_rows(transect_xlsx)
```

```
## Error in list_or_dots(...): object 'transect_xlsx' not found
```

```r
#turn total flowers back to numeric
transect_data$total_flowers<-as.numeric(transect_data$total_flowers)
```

```
## Error in eval(expr, envir, enclos): object 'transect_data' not found
```

## Cleaning


```r
#Month and year column
transect_data$Month<-months(strptime(transect_data$date,"%d/%m/%Y"))
```

```
## Error in strptime(transect_data$date, "%d/%m/%Y"): object 'transect_data' not found
```

```r
transect_data$Year<-years(strptime(transect_data$date,"%d/%m/%Y"))
```

```
## Error in strptime(transect_data$date, "%d/%m/%Y"): object 'transect_data' not found
```

```r
#TODO taxize and name standardization
sources <- gnr_datasources()
tropicos<-sources$id[sources$title == 'Tropicos - Missouri Botanical Garden']

transect_data$plant_field_name<-factor(transect_data$plant_field_name)
```

```
## Error in factor(transect_data$plant_field_name): object 'transect_data' not found
```

```r
tran_levels<-levels(transect_data$plant_field_name)
```

```
## Error in levels(transect_data$plant_field_name): object 'transect_data' not found
```

```r
tran_taxize<-list()
for (x in 1:length(tran_levels)){
Sys.sleep(0.5)
tran_taxize[[x]]<-gnr_resolve(tran_levels[x],best_match_only=T,canonical = TRUE,data_source_ids=tropicos)
}
```

```
## Error in eval(expr, envir, enclos): object 'tran_levels' not found
```

```r
tran_taxize<-bind_rows(tran_taxize)

#only keep species with matched double names
plants_keep<-tran_taxize$submitted_name[sapply(strsplit(tran_taxize$matched_name2," "),length)==2]
```

```
## Error in strsplit(tran_taxize$matched_name2, " "): non-character argument
```

```r
plants_missing<-tran_taxize$submitted_name[!sapply(strsplit(tran_taxize$matched_name2," "),length)==2]
```

```
## Error in strsplit(tran_taxize$matched_name2, " "): non-character argument
```

```r
#get missing data
transect_unidentified<-transect_data %>% filter(!plant_field_name %in% plants_keep) %>% select(site,plant_field_name) %>% distinct() %>% filter(!is.na(plant_field_name))
```

```
## Error in eval(expr, envir, enclos): object 'transect_data' not found
```

```r
transect_data<-transect_data %>% filter(plant_field_name %in% plants_keep) %>% 
select(date,Month,Year,site,plant_field_name,total_flowers,waypoint,height,hummingbird,comment) %>% droplevels()
```

```
## Error in eval(expr, envir, enclos): object 'transect_data' not found
```

```r
#fix mistakes

for (x in levels(transect_data$plant_field_name)){
  levels(transect_data$plant_field_name)[levels(transect_data$plant_field_name) %in% x]<-tran_taxize[tran_taxize$submitted_name %in% x,"matched_name2"]  
}
```

```
## Error in levels(transect_data$plant_field_name): object 'transect_data' not found
```

```r
#droplevels
transect_data<-droplevels(transect_data)
```

```
## Error in droplevels(transect_data): object 'transect_data' not found
```

```r
#clean the  birds
##need to standardize plant species to read from revised plant names
transect_data[transect_data$hummingbird %in% "","hummingbird"]<-NA
```

```
## Error in transect_data[transect_data$hummingbird %in% "", "hummingbird"] <- NA: object 'transect_data' not found
```

```r
transect_data$hummingbird<-factor(transect_data$hummingbird)
```

```
## Error in factor(transect_data$hummingbird): object 'transect_data' not found
```

```r
hum_levels<-levels(transect_data$hummingbird)
```

```
## Error in levels(transect_data$hummingbird): object 'transect_data' not found
```

```r
hum_levels<-hum_levels[!hum_levels==""]
```

```
## Error in eval(expr, envir, enclos): object 'hum_levels' not found
```

```r
hum_taxize<-list()
for (x in 1:length(hum_levels)){
  print(hum_levels[x])
hum_taxize[[x]]<-gnr_resolve(hum_levels[x],best_match_only=T,canonical = TRUE)
}
```

```
## Error in eval(expr, envir, enclos): object 'hum_levels' not found
```

```r
hum_taxize<-bind_rows(hum_taxize)

#fix formatted lavels
for (x in levels(transect_data$hummingbird)){
  levels(transect_data$hummingbird)[levels(transect_data$hummingbird) %in% x]<-hum_taxize[hum_taxize$user_supplied_name %in% x,"matched_name2"]  
}
```

```
## Error in levels(transect_data$hummingbird): object 'transect_data' not found
```

## Combine with gps data


```r
transect_data$Transect_ID<-paste(transect_data$site,transect_data$date,transect_data$waypoint,sep="_")
```

```
## Error in paste(transect_data$site, transect_data$date, transect_data$waypoint, : object 'transect_data' not found
```

```r
transect_gps<-transect_data %>% left_join(wpoints,by="Transect_ID") %>% select(-time,-waypoint.x,waypoint=waypoint.y,-site.y,site=site.x)
```

```
## Error in eval(expr, envir, enclos): object 'transect_data' not found
```

```r
paste(missing<-transect_gps %>% filter(is.na(lon)) %>% nrow(.), "transect points missing GPS data")
```

```
## Error in eval(expr, envir, enclos): object 'transect_gps' not found
```

```r
transect_gps %>% filter(is.na(lon)) %>% group_by(site,date) %>% summarize(n=n())
```

```
## Error in eval(expr, envir, enclos): object 'transect_gps' not found
```


## Divide into plant and hummingbird transects


```r
hummingbird_transects<-transect_gps %>% filter(!hummingbird=="")
```

```
## Error in eval(expr, envir, enclos): object 'transect_gps' not found
```

```r
#What's up with cambugan, alot of no total flower counts?
plant_transects<-transect_gps %>% filter(!plant_field_name=="") %>% filter(!is.na(total_flowers))
```

```
## Error in eval(expr, envir, enclos): object 'transect_gps' not found
```

## Write to file


```r
#plants
write.csv(hummingbird_transects,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/HummingbirdTransects.csv")
```

```
## Error in is.data.frame(x): object 'hummingbird_transects' not found
```

```r
#write to shiny server
write.csv(hummingbird_transects,"HummingbirdData/HummingbirdTransects.csv")
```

```
## Error in is.data.frame(x): object 'hummingbird_transects' not found
```

```r
#plants
write.csv(plant_transects,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/PlantTransects.csv")
```

```
## Error in is.data.frame(x): object 'plant_transects' not found
```

```r
#write to shiny server
write.csv(plant_transects,"HummingbirdData/PlantTransects.csv")
```

```
## Error in is.data.frame(x): object 'plant_transects' not found
```

#Camera Data


```r
camera_files<-list.files(basename,recursive=TRUE,pattern="cameras",full.names = T)

camera_xlsx<-lapply(camera_files,function(x){
  
  if(str_detect(x,".xlsx")){
    j<-read_xlsx(x)
    j$waypoint<-as.character(j$waypoint)
    j$card_id<-as.character(j$card_id)
    j$start_time<-as.character(j$start_time)
    j$start_date<-as.character(j$start_date)
    j$height<-as.character(j$height)
    return(j)
  }
  
  if(str_detect(x,".csv")){
    j<-read.csv(x)
    j$waypoint<-as.character(j$waypoint)
    j$card_id<-as.character(j$card_id)
    j$start_time<-as.character(j$start_time)
    j$height<-as.character(j$height)

    return(j)
  }
  
})

camera_dat<-bind_rows(camera_xlsx)
```

```
## Error in bind_rows_(x, .id): Can not automatically convert from character to POSIXct, POSIXt in column "end_date".
```

## Cleaning


```r
#Month and year column
camera_dat$Month<-months(strptime(camera_dat$start_date,"%d/%m/%Y"))
```

```
## Error in strptime(camera_dat$start_date, "%d/%m/%Y"): object 'camera_dat' not found
```

```r
camera_dat$Year<-years(strptime(camera_dat$start_date,"%d/%m/%Y"))
```

```
## Error in strptime(camera_dat$start_date, "%d/%m/%Y"): object 'camera_dat' not found
```

```r
##need to standardize plant species to read from revised plant names
camera_dat$plant_field_name<-factor(camera_dat$plant_field_name)
```

```
## Error in factor(camera_dat$plant_field_name): object 'camera_dat' not found
```

```r
cam_levels<-levels(camera_dat$plant_field_name)
```

```
## Error in levels(camera_dat$plant_field_name): object 'camera_dat' not found
```

```r
cam_taxize<-list()
for (x in 1:length(cam_levels)){
cam_taxize[[x]]<-gnr_resolve(cam_levels[x],best_match_only=T,canonical = TRUE,data_source_ids=tropicos)
}
```

```
## Error in eval(expr, envir, enclos): object 'cam_levels' not found
```

```r
cam_taxize<-bind_rows(cam_taxize)

#only keep species with matched double names
plants_keep<-cam_taxize$submitted_name[sapply(strsplit(cam_taxize$matched_name2," "),length)==2]
```

```
## Error in strsplit(cam_taxize$matched_name2, " "): non-character argument
```

```r
plants_missing<-cam_taxize$submitted_name[!sapply(strsplit(cam_taxize$matched_name2," "),length)==2]
```

```
## Error in strsplit(cam_taxize$matched_name2, " "): non-character argument
```

```r
camera_missing<-camera_dat %>% filter(!plant_field_name %in% plants_keep) %>% select(site,plant_field_name) %>% distinct()
```

```
## Error in eval(expr, envir, enclos): object 'camera_dat' not found
```

```r
camera_dat<-camera_dat %>% filter(plant_field_name %in% plants_keep) %>% droplevels()
```

```
## Error in eval(expr, envir, enclos): object 'camera_dat' not found
```

```r
#for formatted lavels
for (x in levels(camera_dat$plant_field_name)){
  levels(camera_dat$plant_field_name)[levels(camera_dat$plant_field_name) %in% x]<-cam_taxize[cam_taxize$submitted_name %in% x,"matched_name2"]  
}
```

```
## Error in levels(camera_dat$plant_field_name): object 'camera_dat' not found
```

```r
camera_dat<-droplevels(camera_dat)
```

```
## Error in droplevels(camera_dat): object 'camera_dat' not found
```

## Combine with gps data


```r
camera_dat$Camera_ID<-paste(camera_dat$site,camera_dat$waypoint,sep="_")
```

```
## Error in paste(camera_dat$site, camera_dat$waypoint, sep = "_"): object 'camera_dat' not found
```

```r
camera_gps<-camera_dat %>% left_join(wpoints,by="Camera_ID") %>% select(-time,-waypoint.x,waypoint=waypoint.y,site=site.x)
```

```
## Error in eval(expr, envir, enclos): object 'camera_dat' not found
```

```r
paste(camera_gps %>% filter(is.na(lon)) %>% nrow(.), "camera points missing GPS data")
```

```
## Error in eval(expr, envir, enclos): object 'camera_gps' not found
```

```r
camera_gps %>% filter(is.na(lon)) %>% group_by(site) %>% summarize(n=n())
```

```
## Error in eval(expr, envir, enclos): object 'camera_gps' not found
```

## Write to file


```r
#write to dropbox
write.csv(camera_dat,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/Cameras.csv")
```

```
## Error in is.data.frame(x): object 'camera_dat' not found
```

```r
#write to shiny server
write.csv(camera_dat,"HummingbirdData/Cameras.csv")
```

```
## Error in is.data.frame(x): object 'camera_dat' not found
```

#Interaction Data


```r
int_files<-list.files(basename,recursive=TRUE,pattern="observations",full.names = T)

int_data<-lapply(int_files,function(x){
  if(str_detect(x,".xlsx")){
    j<-read_xlsx(x)
    try(j$site<-str_match(x,"(\\w+)/observations")[2],silent=T)
    j$time<-as.character(j$time)
    j$filename<-as.character(j$filename)
    j$date<-as.character(j$date)
    j$waypoint<-as.character(j$waypoint)
    return(j)
  }
  if(str_detect(x,".csv")){
    j<-read.csv(x)
    try(j$site<-str_match(x,"(\\w+)/observations")[2],silent=T)
    j$time<-as.character(j$time)
    j$filename<-as.character(j$filename)
    j$date<-as.character(j$date)
    j$waypoint<-as.character(j$waypoint)
    return(j)
  }
  
})
```

```
## Error in `$<-.data.frame`(`*tmp*`, "date", value = character(0)): replacement has 0 rows, data has 15
```

```r
int_data<-bind_rows(int_data)
```

```
## Error in list_or_dots(...): object 'int_data' not found
```

## Cleaning


```r
int_data[int_data$hummingbird %in% "","hummingbird"]<-NA
```

```
## Error in int_data[int_data$hummingbird %in% "", "hummingbird"] <- NA: object 'int_data' not found
```

```r
int_data$hummingbird<-factor(int_data$hummingbird)
```

```
## Error in factor(int_data$hummingbird): object 'int_data' not found
```

```r
int_levels<-levels(int_data$hummingbird)
```

```
## Error in levels(int_data$hummingbird): object 'int_data' not found
```

```r
int_taxize<-list()
for (x in 1:length(int_levels)){
  Sys.sleep(0.5)
  int_taxize[[x]]<-gnr_resolve(int_levels[x],best_match_only=T,canonical = TRUE)
}
```

```
## Error in eval(expr, envir, enclos): object 'int_levels' not found
```

```r
int_taxize<-bind_rows(int_taxize)

#only keep species with matched double names
hum_keep<-int_taxize$submitted_name[sapply(strsplit(int_taxize$matched_name2," "),length)==2]
```

```
## Error in strsplit(int_taxize$matched_name2, " "): non-character argument
```

```r
int_data<-int_data %>% filter(hummingbird %in% hum_keep) %>% droplevels()
```

```
## Error in eval(expr, envir, enclos): object 'int_data' not found
```

```r
#for formatted lavels
for (x in levels(int_data$hummingbird)){
  levels(int_data$hummingbird)[levels(int_data$hummingbird) %in% x]<-int_taxize[int_taxize$submitted_name %in% x,"matched_name2"]  
}
```

```
## Error in levels(int_data$hummingbird): object 'int_data' not found
```

```r
int_data<-droplevels(int_data)
```

```
## Error in droplevels(int_data): object 'int_data' not found
```

```r
#only hummingbirds
isclass<-tax_name(query = levels(int_data$hummingbird), get = "family", db = "ncbi")
```

```
## Error in levels(int_data$hummingbird): object 'int_data' not found
```

```r
troch_keep<-isclass %>% filter(family =="Trochilidae") %>% .$query
```

```
## Error in eval(expr, envir, enclos): object 'isclass' not found
```

```r
int_data<-int_data %>% filter(hummingbird %in% troch_keep) %>% droplevels()
```

```
## Error in eval(expr, envir, enclos): object 'int_data' not found
```

## Combine with camera data


```r
int_data$Camera_ID<-paste(int_data$site,int_data$waypoint,sep="_")
```

```
## Error in paste(int_data$site, int_data$waypoint, sep = "_"): object 'int_data' not found
```

```r
tojoin<-camera_gps %>% select(Camera_ID,plant_field_name,lon,lat,elevation)
```

```
## Error in eval(expr, envir, enclos): object 'camera_gps' not found
```

```r
int_gps<-int_data %>% left_join(tojoin,by="Camera_ID")
```

```
## Error in eval(expr, envir, enclos): object 'int_data' not found
```


```r
#interactions within 20 seconds are condensced to the same event
int_gps$timestamp<-as.POSIXct(paste(int_gps$date,int_gps$time),format=" %d/%m/%Y %H:%M:%S",tz="EST")
```

```
## Error in paste(int_gps$date, int_gps$time): object 'int_gps' not found
```

```r
difftimeall<-function(x){
  out<-c()
  out[1]<-NA
  for(i in 1:length(x)){
    out[i+1]<-difftime(x[i+1],x[i],units="mins")
  }
  return(data.frame(time_since=out))
}

#remove observations within 1 minute
too_close<-int_gps %>% group_by(Camera_ID) %>% arrange(timestamp) %>% do(difftimeall(.$timestamp)) %>% filter(time_since<1) %>% .$ID
```

```
## Error in eval(expr, envir, enclos): object 'int_gps' not found
```

```r
int_gps<-int_gps %>% filter(!Camera_ID %in% too_close)
```

```
## Error in eval(expr, envir, enclos): object 'int_gps' not found
```

```r
#drop without hummingbird data
int_gps<-int_gps %>% filter(!is.na(hummingbird))
```

```
## Error in eval(expr, envir, enclos): object 'int_gps' not found
```

```r
#missing gps data
paste(int_gps %>% filter(is.na(lon)) %>% nrow(.), "records missing gps data")
```

```
## Error in eval(expr, envir, enclos): object 'int_gps' not found
```

```r
print("Missing GPS records by site")
```

```
## [1] "Missing GPS records by site"
```

```r
int_gps %>% filter(is.na(lon)) %>% group_by(site,Camera_ID) %>% summarize(n=n())
```

```
## Error in eval(expr, envir, enclos): object 'int_gps' not found
```

## Write to file


```r
#write to dropbox
write.csv(int_gps,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/Interactions.csv")
```

```
## Error in is.data.frame(x): object 'int_gps' not found
```

```r
#write to shiny server
write.csv(int_gps,"HummingbirdData/Interactions.csv")
```

```
## Error in is.data.frame(x): object 'int_gps' not found
```
