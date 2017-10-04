##look for completed observations, move the files
library(stringr)
library(dplyr)

#int<-read.csv("HummingbirdData/Interactions.csv",row.names=1)

#is_complete<-int %>% select(site,folder,filename,date,time,waypoint,hummingbird)

#get complete folders
#complete_folder<-is_complete[complete.cases(is_complete),] %>% select(site,folder) %>% unique()

#print incomplete folders
#incomplete_folder<-is_complete[!complete.cases(is_complete),] %>% select(site,folder) %>% unique()
#print(incomplete_folder)
#get folder path

basename<-c("/Users/Ben/Dropbox/HummingbirdProject/Data")
outputpath<-c("/Users/Ben/Dropbox/HummingbirdProject/Completed_Frames")

#list dirs
dirs<-list.dirs(basename,recursive = F,full.names = F)

dirs<-dirs[!dirs=="HummingbirdProjectCleaned"]

for( i in 1:length(dirs)){
  x<-dirs[i]
  full_path<-paste(basename,x,"foundframes",sep="/")
  out_folder<-paste(outputpath,x,"foundframes",sep="/")
  
  #call to system
  system(paste("ditto",full_path,out_folder,sep=" "))
  
  #find camera directories
  from<-list.dirs(full_path,recursive = T,full.names = T)
  
  #it lists itself as the first entry
  from<-from[-1]
  
  if (length(from)==0){
    next
  }
  
  #remove directories
  for(y in from){
    unlink(y,recursive=T)
  }
  
  }
