##look for completed observations, move the files
library(stringr)
library(dplyr)

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
