#Plant photos

library(dplyr)
library(stringr)
#Check for new photos

#Rename photo

#

fils<-list.files("/Users/Ben/Dropbox/HummingbirdProject/Data/",full.names = T,recursive = T)
fils<-fils[str_detect(fils,"pictures/")]

basname<-"/Users/ben/Dropbox/HummingbirdProject/plant_guide"

for(i in 1:length(fils)){
  print(i)
  original<-fils[i]
  #drop spaces
  x<-gsub(original,pattern=" ",replacement = "_")
  
  #get extension
  extension<-str_match(x,"(\\.\\w+)")[,2]
  #Other bad delim characters
  x<-gsub(x,pattern="\\=",replacement = "")
  x<-gsub(x,pattern="\\[",replacement = "")
  x<-gsub(x,pattern="\\]",replacement = "")
  x<-gsub(x,pattern="\\-",replacement = "_")
  x<-gsub(x,pattern="\\(",replacement = "_")
  x<-gsub(x,pattern="\\)",replacement = "_")

  site<-str_match(x,"Data//(\\w+)")[,2]
  family<-str_match(x,"/(\\w+)/\\w+/\\w+\\.")[,2]
  species<-str_match(x,"(\\w+)/\\w+\\.")[,2]
  photo<-str_match(x,"\\w+/(\\w+)\\.")[,2]
  filname<-paste(site,family,species,paste(photo,extension,sep=""),sep="_")
  fullname<-paste(basname,filname,sep="/")
  file.copy(from=original,to=fullname,overwrite = F,copy.date=T)
}
