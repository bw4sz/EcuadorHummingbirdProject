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
    }

#poco de choco string, ask nicole to change her GPS to english abbreviations?
if(nchar(x) %in% c(17,18)){
  timet<-strsplit(x," ")[[1]][[2]]
}
  return(timet)
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
    }

  if(nchar(x) %in% c(17,18)){
  b<-strsplit(as.character(x),"T")[[1]][1]
  mnh<-strsplit(b," ")
  mn<-strsplit(mnh[[1]][1],"-")
  mn[[1]][2]<-as.character(mt$Month[mt$Spanish %in% mn[[1]][2]])
  paste(mn[[1]],collapse="-")
  datet<-format(strptime(b,"%d-%b-%y"),"%d/%m/%Y")
  }
  return(datet)
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

#only xlsx files
transect_files<-transect_files[!str_detect(transect_files,"~")]

transect_xlsx<-lapply(transect_files,function(x){
  y<-read_xlsx(x)
  
  #turn waypoints to character for the moment
  y$waypoint<-as.character(y$waypoint)
  y$total_flowers<-as.character(y$total_flowers)
  
  return(y)
})

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
tran_taxize<-gnr_resolve(tran_levels,best_match_only=T,canonical = TRUE,data_source_ids=tropicos)

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
```

## Combine with gps data


```r
transect_data$Transect_ID<-paste(transect_data$site,transect_data$date,transect_data$waypoint,sep="_")
transect_gps<-transect_data %>% left_join(wpoints,by="Transect_ID") %>% select(-time,-waypoint.x,waypoint=waypoint.y,-site.y,site=site.x)

paste(missing<-transect_gps %>% filter(is.na(lon)) %>% nrow(.), "transect points missing GPS data")
```

```
## [1] "1561 transect points missing GPS data"
```

```r
transect_gps %>% filter(is.na(lon)) %>% group_by(site,date) %>% summarize(n=n())
```

```
## Source: local data frame [19 x 3]
## Groups: site [?]
## 
##              site       date     n
##             <chr>      <chr> <int>
## 1        Cambugan 14/03/2017   118
## 2        Cambugan 15/02/2017   104
## 3        Cambugan 16/03/2017    55
## 4    LasGralarias 16/03/2017    22
## 5  MashpiCapuchin  12/4/2017     4
## 6      SantaLucia 17/04/2017    51
## 7      SantaLucia 19/04/2017    46
## 8      SantaLucia 20/01/2017   136
## 9      SantaLucia 20/02/2017    79
## 10     SantaLucia 22/02/2017    91
## 11     SantaLucia 22/03/2017    22
## 12     SantaLucia 24/03/2017    10
## 13    UnPocoChoco 26/04/2017    36
## 14     Verdecocha 18/03/2017     1
## 15     Verdecocha   4/4/2017   201
## 16      Yanacocha 17/03/2017   141
## 17      Yanacocha 18/02/2017   185
## 18      Yanacocha   4/4/2017   174
## 19           <NA> 19/01/2017    85
```


## Divide into plant and hummingbird transects


```r
hummingbird_transects<-transect_gps %>% filter(!hummingbird=="")

#What's up with cambugan, alot of no total flower counts?
plant_transects<-transect_gps %>% filter(!plant_field_name=="") %>% filter(!is.na(total_flowers))
```

## Write to file


```r
#plants
write.csv(hummingbird_transects,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/HummingbirdTransects.csv")

#write to shiny server
write.csv(hummingbird_transects,"HummingbirdData/HummingbirdTransects.csv")

#plants
write.csv(plant_transects,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/PlantTransects.csv")

#write to shiny server
write.csv(plant_transects,"HummingbirdData/PlantTransects.csv")
```

#Camera Data


```r
camera_files<-list.files(basename,recursive=TRUE,pattern="cameras",full.names = T)

#only xlsx files
camera_files<-camera_files[str_detect(camera_files,".xlsx")]

camera_xlsx<-lapply(camera_files,function(x){
  j<-read_xlsx(x)
  j$waypoint<-as.character(j$waypoint)
  j$card_id<-as.character(j$card_id)
  j$start_time<-as.character(j$start_time)
  return(j)
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
cam_taxize<-gnr_resolve(levels(camera_dat$plant_field_name),best_match_only=T,canonical = TRUE,data_source_ids=tropicos)

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

paste(camera_gps %>% filter(is.na(lon)) %>% nrow(.), "camera points missing GPS data")
```

```
## [1] "16 camera points missing GPS data"
```

```r
camera_gps %>% filter(is.na(lon)) %>% group_by(site) %>% summarize(n=n())
```

```
## # A tibble: 6 � 2
##              site     n
##             <chr> <int>
## 1        Cambugan     5
## 2    LasGralarias     1
## 3  MashpiCapuchin     1
## 4 SantaLuciaLower     1
## 5      Verdecocha     4
## 6       Yanacocha     4
```

## Write to file


```r
#write to dropbox
write.csv(camera_dat,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/Cameras.csv")

#write to shiny server
write.csv(camera_dat,"HummingbirdData/Cameras.csv")
```

#Interaction Data


```r
int_files<-list.files(basename,recursive=TRUE,pattern="observations",full.names = T)

#only xlsx files
int_files<-int_files[str_detect(int_files,".xlsx")]

int_data<-lapply(int_files,function(x){
  j<-read_xlsx(x)
  try(j$site<-str_match(x,"(\\w+)/observations")[2],silent=T)
  j$time<-as.character(j$time)
  j$filename<-as.character(j$filename)
  return(j)
})

int_data<-bind_rows(int_data)
```

## Cleaning


```r
##need to standardize plant species to read from revised plant names
int_data$hummingbird<-factor(int_data$hummingbird)
int_taxize<-gnr_resolve(levels(int_data$hummingbird),best_match_only=T,canonical = TRUE)

#only keep species with matched double names
hum_keep<-int_taxize$submitted_name[sapply(strsplit(int_taxize$matched_name2," "),length)==2]

#for formatted lavels
for (x in levels(int_data$hummingbird)){
  levels(int_data$hummingbird)[levels(int_data$hummingbird) %in% x]<-int_taxize[int_taxize$submitted_name %in% x,"matched_name2"]  
}
```

```
## Error in levels(int_data$hummingbird)[levels(int_data$hummingbird) %in% : replacement has length zero
```

```r
int_data<-droplevels(int_data)

#only hummingbirds
isclass<-tax_name(query = levels(int_data$hummingbird), get = "family", db = "ncbi")
```

```
## 
## Retrieving data for taxon 'Aglaiocercus coelestis'
```

```
## 
## Retrieving data for taxon 'Atlapetes tricolor'
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
## Retrieving data for taxon 'Coeligena'
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
## Retrieving data for taxon 'Euphonia xanthogaster'
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
## Retrieving data for taxon 'Metallura tyrianthina'
```

```
## 
## Retrieving data for taxon 'Ocreatus underwoodii'
```

```
## 
## Retrieving data for taxon 'Phaethornis'
```

```
## 
## Retrieving data for taxon 'Phaethornis striigularis'
```

```
## 
## Retrieving data for taxon 'Phaethornis syrmatophorus'
```

```
## 
## Retrieving data for taxon 'Phaethornis yaruqui'
```

```
## 
## Retrieving data for taxon 'Puma concolor'
```

```
## 
## Retrieving data for taxon 'Thalurania fannyi'
```

```
## 
## Retrieving data for taxon 'Unidentified'
```

```
## 
## Retrieving data for taxon 'unknown'
```

```
## 
## Retrieving data for taxon 'Urosticte benjamini'
```

```r
hum_keep<-hum_keep[isclass$family %in% "Trochilidae"]

#get higher order taxize
int_data<-int_data %>% filter(hummingbird %in% hum_keep) %>% droplevels()
```

## Combine with camera data


```r
int_data$Camera_ID<-paste(int_data$site,int_data$waypoint,sep="_")
tojoin<-camera_gps %>% select(Camera_ID,plant_field_name,lon,lat,elevation)
int_gps<-int_data %>% left_join(tojoin,by="Camera_ID")
```


```r
#interactions within 20 seconds are condensced to the same event
int_gps$timestamp<-as.POSIXct(paste(int_gps$date,int_gps$time),format=" %d/%m/%Y %H:%M:%S",tz="EST")

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

int_gps<-int_gps %>% filter(!Camera_ID %in% too_close)

#drop without hummingbird data
int_gps<-int_gps %>% filter(!is.na(hummingbird))

#missing gps data
paste(int_gps %>% filter(is.na(lon)) %>% nrow(.), "records missing gps data")
```

```
## [1] "166 records missing gps data"
```

## Write to file


```r
#write to dropbox
write.csv(int_gps,"C:/Users/Ben/Dropbox/HummingbirdProject/Data/HummingbirdProjectCleaned/Interactions.csv")

#write to shiny server
write.csv(int_gps,"HummingbirdData/Interactions.csv")
```
