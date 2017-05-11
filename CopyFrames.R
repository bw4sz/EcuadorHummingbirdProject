##look for completed observations, move the files
library(stringr)

int<-read.csv("HummingbirdData/Interactions.csv",row.names=1)

is_complete<-int %>% select(site,folder,filename,date,time,waypoint,hummingbird)

#get complete folders
complete_folder<-is_complete[complete.cases(is_complete),] %>% select(site,folder) %>% unique()

#get folder path
basename<-c("C:/Users/Ben/Dropbox/HummingbirdProject/Data")
outputpath<-c("C:/Users/Ben/Dropbox/HummingbirdProject/Completed_Frames")

for( i in 1:nrow(complete_folder)){
  x<-complete_folder[i,]
  full_path<-paste(basename,x$site,"foundframes",x$folder,sep="/")
  out_folder<-paste(outputpath,x$site,"foundframes",x$folder,sep="/")
  #create directories if they don't exist
  if(!dir.exists(out_folder)){
    dir.create(out_folder,recursive = T)
  }
  
  #find files
  from<-list.files(full_path,recursive = T,full.names = T)
  to<-paste(out_folder,list.files(full_path,recursive = T),sep="/")
  
  #move files
  file.copy(from,to)
  
  #remove files
  file.remove(from)
  
}
