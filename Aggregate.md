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
```

```
## Error in overscope_eval_next(overscope, expr): object 'ele' not found
```

```r
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

```
## Error in if (nchar(x) == 20) {: missing value where TRUE/FALSE needed
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
```

```
## Error in if (nchar(x) == 20) {: missing value where TRUE/FALSE needed
```

```r
#create site id, month, year waypoint combination.
wpoints$Transect_ID<-paste(wpoints$site,wpoints$date_gps,wpoints$waypoint,sep="_")
wpoints$Camera_ID<-paste(wpoints$site,wpoints$waypoint,sep="_")

#delete duplicates
wpoints<-wpoints[!duplicated(wpoints),]
```


```r
#write gps points
write.csv(wpoints,"/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/GPS.csv")

#Write in case we want to visualize with the shiny data
write.csv(wpoints,"HummingbirdData/GPS.csv")
```

#Transect Data


```r
transect_files<-list.files(basename,recursive=TRUE,pattern="transect_",full.names=T)

transect_files<-transect_files[!str_detect(transect_files,"~")]
transect_files<-transect_files[!str_detect(transect_files,"metadata")]

transect_xlsx<-lapply(transect_files,function(x){
  
  print(x)
  if(str_detect(x,".xlsx")){
    y<-read_xlsx(x)
    
    #turn waypoints to character for the moment
    y$waypoint<-as.character(y$waypoint)
    y$total_flowers<-as.character(y$total_flowers)
    y$height<-as.character(y$height)
    y$count_method<-as.character(y$count_method)
    y$flower_unit<-as.character(y$flower_unit)
    y$flower_count1<-as.character(y$flower_count1)


  }
  if(str_detect(x,".csv")){
    
    y<-read.csv(x)
    
    #turn waypoints to character for the moment
    y$waypoint<-as.character(y$waypoint)
    y$total_flowers<-as.character(y$total_flowers)
    y$flower_unit<-as.character(y$flower_unit)
    y$flower_count1<-as.character(y$flower_count1)


  }
  
  return(y)
})
```

```
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Cambugan/transect_Cambugan.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//LasGralarias/transect_lasgralarias.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Maquipucuna/transect_Maquipucuna.csv"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//MashpiCapuchin/transect_MashpiCapuchin.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//MashpiLaguna/transect_MashpiLaguna.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Sachatamia/transect_Sachatamia.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//SantaLuciaLower/transect_SantaLuciaLower.csv"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//SantaLuciaUpper/transect_SantaLuciaUpper.csv"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//UnPocoDelChoco/transect_UnPocoDelChoco.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Verdecocha/transect_Verdecocha.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Yanacocha/transect_Yanacocha.xlsx"
```

```r
#Combine files
transect_data<-bind_rows(transect_xlsx)

#turn total flowers back to numeric
transect_data$total_flowers<-as.numeric(transect_data$total_flowers)
```

## Cleaning


```r
#Month and year column
transect_data$Month<-months(strptime(transect_data$date,"%d/%m/%Y"))
transect_data$Year<-years(strptime(transect_data$date,"%d/%m/%Y"))

#TODO taxize and name standardization
sources <- gnr_datasources()
tropicos<-sources$id[sources$title == 'Tropicos - Missouri Botanical Garden']

transect_data$plant_field_name<-factor(transect_data$plant_field_name)
tran_levels<-levels(transect_data$plant_field_name)

#check for empty cells
tran_levels<-tran_levels[!tran_levels %in% c(""," ")]
tran_taxize<-list()
for (x in 1:length(tran_levels)){
Sys.sleep(0.5)
tran_taxize[[x]]<-gnr_resolve(tran_levels[x],best_match_only=T,canonical = TRUE,data_source_ids=tropicos)
}
tran_taxize<-bind_rows(tran_taxize)

#only keep species with matched double names
plants_keep<-tran_taxize$submitted_name[sapply(strsplit(tran_taxize$matched_name2," "),length)==2]

plants_missing<-tran_taxize$submitted_name[!sapply(strsplit(tran_taxize$matched_name2," "),length)==2]

#get missing data
transect_unidentified<-transect_data %>% filter(!plant_field_name %in% plants_keep) %>% select(site,plant_field_name) %>% distinct() %>% filter(!is.na(plant_field_name))

transect_data<-transect_data %>% filter(plant_field_name %in% plants_keep) %>% 
select(date,Month,Year,site,plant_field_name,total_flowers,waypoint,height,hummingbird,comment) %>% droplevels()

#fix mistakes

for (x in levels(transect_data$plant_field_name)){
  levels(transect_data$plant_field_name)[levels(transect_data$plant_field_name) %in% x]<-tran_taxize[tran_taxize$submitted_name %in% x,"matched_name2"]  
}

#droplevels
transect_data<-droplevels(transect_data)

#clean the  birds
##need to standardize plant species to read from revised plant names
transect_data[transect_data$hummingbird %in% "","hummingbird"]<-NA
transect_data$hummingbird<-factor(transect_data$hummingbird)

hum_levels<-levels(transect_data$hummingbird)
hum_levels<-hum_levels[!hum_levels==""]

hum_taxize<-list()
for (x in 1:length(hum_levels)){
  print(hum_levels[x])
hum_taxize[[x]]<-gnr_resolve(hum_levels[x],best_match_only=T,canonical = TRUE)
}
```

```
## [1] "Adelomyia melanogenys"
## [1] "aglaiocercus coelestis"
## [1] "Aglaiocercus coelestis"
## [1] "Aglaiocercus kingii"
## [1] "Androdon aequatorialis"
## [1] "Boissonneaua flavescens"
## [1] "Boissonneaua jardini"
## [1] "Coeligena lutetiae"
## [1] "Coeligena torquata"
## [1] "Coeligena wilsoni"
## [1] "Colibri delphinae"
## [1] "Colibrí sp."
## [1] "Diglossa lafresnayi"
## [1] "Diglossa lafresnayii"
## [1] "Eriocnemis luciani"
## [1] "Eriocnemis nigrivestis"
## [1] "Lafresnaya lafresnayi"
## [1] "Metallura tyrianthina"
## [1] "Methallura tyrianthina"
## [1] "Ocreatus underwoodii"
## [1] "Phaethornis syrmatophorus"
## [1] "Phaethornis yaruqui"
## [1] "Phaetornis syrmatophorus"
## [1] "Pterophanes cyanopterus"
## [1] "Thalurania fannyi"
```

```r
hum_taxize<-bind_rows(hum_taxize)

#fix formatted lavels
for (x in levels(transect_data$hummingbird)){
  levels(transect_data$hummingbird)[levels(transect_data$hummingbird) %in% x]<-hum_taxize[hum_taxize$user_supplied_name %in% x,"matched_name2"]  
}
```

## Combine with gps data


```r
transect_data$Transect_ID<-paste(transect_data$site,transect_data$date,transect_data$waypoint,sep="_")
transect_gps<-transect_data %>% left_join(wpoints,by="Transect_ID") %>% select(-time,-waypoint.x,waypoint=waypoint.y,-site.y,site=site.x)
```

```
## Error in overscope_eval_next(overscope, expr): object 'waypoint.x' not found
```

```r
paste(missing<-transect_gps %>% filter(is.na(lon)) %>% nrow(.), "transect points", "out of", nrow(transect_gps), "missing GPS data")
```

```
## Error in eval(lhs, parent, parent): object 'transect_gps' not found
```

```r
missing_transect_gps<-transect_gps %>% filter(is.na(lon)) %>% group_by(site,date) %>% summarize(n=n())
```

```
## Error in eval(lhs, parent, parent): object 'transect_gps' not found
```

```r
write.csv(missing_transect_gps,"missing_transect_dates.csv")
```

```
## Error in is.data.frame(x): object 'missing_transect_gps' not found
```


## Divide into plant and hummingbird transects


```r
hummingbird_transects<-transect_gps %>% filter(!hummingbird=="")
```

```
## Error in eval(lhs, parent, parent): object 'transect_gps' not found
```

```r
#What's up with cambugan, alot of no total flower counts?
plant_transects<-transect_gps %>% filter(!plant_field_name=="") %>% filter(!is.na(total_flowers))
```

```
## Error in eval(lhs, parent, parent): object 'transect_gps' not found
```

## Write to file


```r
#plants
write.csv(hummingbird_transects,"/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/HummingbirdTransects.csv")
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
write.csv(plant_transects,"/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/PlantTransects.csv")
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
    j$end_date<-as.character(j$end_date)
    j$end_time<-as.character(j$end_date)
    j$height<-as.character(j$height)
    j$X__1<-NULL
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

## Cleaning


```r
#Month and year column
camera_dat$Month<-months(strptime(camera_dat$start_date,"%d/%m/%Y"))
camera_dat$Year<-years(strptime(camera_dat$start_date,"%d/%m/%Y"))

##need to standardize plant species to read from revised plant names
camera_dat$plant_field_name<-factor(camera_dat$plant_field_name)

cam_levels<-levels(camera_dat$plant_field_name)
cam_taxize<-list()
for (x in 1:length(cam_levels)){
cam_taxize[[x]]<-gnr_resolve(cam_levels[x],best_match_only=T,canonical = TRUE,data_source_ids=tropicos)
}
cam_taxize<-bind_rows(cam_taxize)

#only keep species with matched double names
plants_keep<-cam_taxize$submitted_name[sapply(strsplit(cam_taxize$matched_name2," "),length)==2]
plants_missing<-cam_taxize$submitted_name[!sapply(strsplit(cam_taxize$matched_name2," "),length)==2]

camera_missing<-camera_dat %>% filter(!plant_field_name %in% plants_keep) %>% select(site,plant_field_name) %>% distinct()

camera_dat<-camera_dat %>% filter(plant_field_name %in% plants_keep) %>% droplevels()

#for formatted lavels
for (x in levels(camera_dat$plant_field_name)){
  levels(camera_dat$plant_field_name)[levels(camera_dat$plant_field_name) %in% x]<-cam_taxize[cam_taxize$submitted_name %in% x,"matched_name2"]  
}

camera_dat<-droplevels(camera_dat)
```

## Combine with gps data


```r
camera_dat$Camera_ID<-paste(camera_dat$site,camera_dat$waypoint,sep="_")
camera_gps<-camera_dat %>% left_join(wpoints,by="Camera_ID") %>% select(-time,-waypoint.x,waypoint=waypoint.y,site=site.x)
```

```
## Error in overscope_eval_next(overscope, expr): object 'waypoint.x' not found
```

```r
paste(camera_gps %>% filter(is.na(lon)) %>% nrow(.), "camera points missing GPS data")
```

```
## Error in eval(lhs, parent, parent): object 'camera_gps' not found
```

```r
camera_gps %>% filter(is.na(lon)) %>% group_by(site) %>% summarize(n=n())
```

```
## Error in eval(lhs, parent, parent): object 'camera_gps' not found
```

## Write to file


```r
#write to dropbox
write.csv(camera_dat,"/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/Cameras.csv")

#write to shiny server
write.csv(camera_dat,"HummingbirdData/Cameras.csv")
```

#Interaction Data


```r
int_files<-list.files(basename,recursive=TRUE,pattern="observations",full.names = T)

int_data<-lapply(int_files,function(x){
  print(x)
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
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Cambugan/observations_cambugan.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//LasGralarias/observations_lasgralarias.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Maquipucuna/observations_Maquipucuna.csv"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//MashpiCapuchin/observations_MashpiCapuchin.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//MashpiLaguna/observations_MashpiLaguna.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Sachatamia/observations_Sachatamia.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//SantaLuciaLower/observations_SantaLuciaLower.csv"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//SantaLuciaUpper/observations_SantaLuciaUpper.csv"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//UnPocoDelChoco/observations_UnPocoDelChoco.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Verdecocha/observations_Verdecocha.xlsx"
## [1] "/Users/Ben/Dropbox/HummingbirdProject/Data//Yanacocha/observations_Yanacocha.xlsx"
```

```r
int_data<-bind_rows(int_data)
```

## Cleaning


```r
int_data[int_data$hummingbird %in% "","hummingbird"]<-NA
int_data$hummingbird<-factor(int_data$hummingbird)

int_levels<-levels(int_data$hummingbird)
int_taxize<-list()
for (x in 1:length(int_levels)){
  Sys.sleep(0.5)
  int_taxize[[x]]<-gnr_resolve(int_levels[x],best_match_only=T,canonical = TRUE)
}
int_taxize<-bind_rows(int_taxize)

#only keep species with matched double names
hum_keep<-int_taxize$submitted_name[sapply(strsplit(int_taxize$matched_name2," "),length)==2]

int_data<-int_data %>% filter(hummingbird %in% hum_keep) %>% droplevels()

#for formatted lavels
for (x in levels(int_data$hummingbird)){
  levels(int_data$hummingbird)[levels(int_data$hummingbird) %in% x]<-int_taxize[int_taxize$submitted_name %in% x,"matched_name2"]  
}

int_data<-droplevels(int_data)

#only hummingbirds
isclass<-tax_name(query = levels(int_data$hummingbird), get = "family", db = "ncbi")
```

```
## 
## Retrieving data for taxon 'Adelomyia melanogenys'
```

```
## 
## Retrieving data for taxon 'Aglaiocercus coelestis'
```

```
## 
## Retrieving data for taxon 'Amazilia franciae'
```

```
## 
## Retrieving data for taxon 'Atlapetes tricolor'
```

```
## 
## Retrieving data for taxon 'Boissonneaua flavescens'
```

```
## 
## Retrieving data for taxon 'Chlorostilbon melanorhynchus'
```

```
## 
## Retrieving data for taxon 'Coeligena lutetiae'
```

```
## 
## Retrieving data for taxon 'Coeligena torquata'
```

```
## 
## Retrieving data for taxon 'Coeligena wilsoni'
```

```
## 
## Retrieving data for taxon 'Colibri delphinae'
```

```
## 
## Retrieving data for taxon 'Doryfera ludovicae'
```

```
## 
## Retrieving data for taxon 'Ensifera ensifera'
```

```
## 
## Retrieving data for taxon 'Eriocnemis luciani'
```

```
## 
## Retrieving data for taxon 'Eriocnemis mosquera'
```

```
## 
## Retrieving data for taxon 'Eriocnemis nigrivestis'
```

```
## 
## Retrieving data for taxon 'Euphonia xanthogaster'
```

```
## 
## Retrieving data for taxon 'Eutoxeres aquila'
```

```
## 
## Retrieving data for taxon 'Heliangelus strophianus'
```

```
## 
## Retrieving data for taxon 'Heliodoxa imperatrix'
```

```
## 
## Retrieving data for taxon 'Heliodoxa jacula'
```

```
## 
## Retrieving data for taxon 'Heliodoxa rubinoides'
```

```
## 
## Retrieving data for taxon 'Henicorhina leucophrys'
```

```
## 
## Retrieving data for taxon 'Lafresnaya lafresnayi'
```

```
## 
## Retrieving data for taxon 'Lesbia nuna'
```

```
## 
## Retrieving data for taxon 'Metallura tyrianthina'
```

```
## 
## Retrieving data for taxon 'Ocreatus underwoodi'
```

```
## Not found. Consider checking the spelling or alternate classification
```

```
## No UID found for species 'Ocreatus underwoodi'!
```

```
## 
## Retrieving data for taxon 'Ocreatus underwoodii'
```

```
## 
## Retrieving data for taxon 'Phaethornis striigularis'
```

```
## 
## Retrieving data for taxon 'Phaethornis yaruqui'
```

```
## 
## Retrieving data for taxon 'Phaethornis griseogularis'
```

```
## 
## Retrieving data for taxon 'Phaethornis malaris'
```

```
## 
## Retrieving data for taxon 'Phaethornis syrmatophorus'
```

```
## 
## Retrieving data for taxon 'Popelairia conversii'
```

```
## 
## Retrieving data for taxon 'Pterophanes cyanopterus'
```

```
## 
## Retrieving data for taxon 'Puma concolor'
```

```
## 
## Retrieving data for taxon 'Schistes geoffroyi'
```

```
## 
## Retrieving data for taxon 'Thalurania fannyi'
```

```
## 
## Retrieving data for taxon 'Urosticte benjamini'
```

```r
troch_keep<-isclass %>% filter(family =="Trochilidae") %>% .$query

int_data<-int_data %>% filter(hummingbird %in% troch_keep) %>% droplevels()
```

## Combine with camera data


```r
int_data$Camera_ID<-paste(int_data$site,int_data$waypoint,sep="_")
tojoin<-camera_gps %>% select(Camera_ID,plant_field_name,lon,lat,elevation)
```

```
## Error in eval(lhs, parent, parent): object 'camera_gps' not found
```

```r
int_gps<-int_data %>% left_join(tojoin,by="Camera_ID")
```

```
## Error in tbl_vars(y): object 'tojoin' not found
```


```r
#label events
int_gps$ID=1:nrow(int_gps)
```

```
## Error in nrow(int_gps): object 'int_gps' not found
```

```r
#interactions within 20 seconds are condensced to the same event
int_gps$timestamp<-as.POSIXct(paste(int_gps$date,int_gps$time),format=" %d/%m/%Y %H:%M:%S",tz="EST")
```

```
## Error in paste(int_gps$date, int_gps$time): object 'int_gps' not found
```

```r
difftimeall<-function(x,ID){
  print(x)
  out<-c()
  if(length(x)==1){
    out<-NA
    return(data.frame(ID=ID,time_since=out))
  }
    for(i in 2:length(x)){
      out[i]<-difftime(x[i],x[i-1],units="mins")
    }
  return(data.frame(ID=ID,time_since=out))
}

#remove observations within 1 minute
too_close<-int_gps %>% group_by(Camera_ID) %>% arrange(timestamp) %>% do(difftimeall(.$timestamp,.$ID)) %>% filter(time_since<1)  
```

```
## Error in eval(lhs, parent, parent): object 'int_gps' not found
```

```r
int_gps<-int_gps %>% filter(!ID  %in% too_close$ID)
```

```
## Error in eval(lhs, parent, parent): object 'int_gps' not found
```

```r
#drop without hummingbird data
int_gps<-int_gps %>% filter(!is.na(hummingbird))
```

```
## Error in eval(lhs, parent, parent): object 'int_gps' not found
```

```r
#missing gps data
paste(int_gps %>% filter(is.na(lon)) %>% nrow(.), "records missing gps data")
```

```
## Error in eval(lhs, parent, parent): object 'int_gps' not found
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
## Error in eval(lhs, parent, parent): object 'int_gps' not found
```

## Write to file


```r
#write to dropbox
write.csv(int_gps,"/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/Interactions.csv")
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

