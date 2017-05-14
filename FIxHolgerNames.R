library(readxl)
library(stringr)

a<-read_xlsx("C:/Users/Ben/Dropbox/HummingbirdProject/Data/UnPocoChoco/observations_UnPocoChoco.xlsx")
head(a)

folders<-a$folder

for(i in 1:length(folders)){
  olddate<-str_split(folders[i],"_")[[1]][2]
  oldnum<-str_split(folders[i],"_")[[1]][3]
  newdate<-format(strptime(olddate,"%Y%m%d"),"%y%m%d")
  if(oldnum=="01"){
    newname<-paste(newdate,"AA",sep="")
  }
  if(oldnum=="02"){
    newname<-paste(newdate,"AB",sep="")
  }
  if(oldnum=="03"){
    newname<-paste(newdate,"AC",sep="")
  }
  #paste back to month
  a$new_folder[i]<-paste("201703",str_split(folders[i],"_")[[1]][1],newname,sep="/")
}

a$folder<-a$new_folder
write.csv(a,"C:/Users/Ben/Desktop/mn.csv")
