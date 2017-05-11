library(stringr)
d<-list.dirs("C:/Users/Ben/Dropbox/Ecuador hummingbird project/Public Folder/Data/",recursive=T,full.names = T)
d<-d[str_detect(d,"pictures$")]

for (i in 1:length(d)){
  from.dir <- d[i]
  f<-list.files("C:/Users/Ben/Dropbox/Ecuador hummingbird project/Public Folder/Data/",recursive=T,full.names = F)
  f<-f[str_detect(f,"pictures")]
  to.dir<- paste("C:/Users/Ben/Dropbox/HummingbirdProject/Pictures/",f[i],sep="")
  if(!dir.exists(to.dir)){
    dir.create(to.dir,recursive=T)
  }
  
  files<- list.files(path = from.dir, full.names = TRUE, recursive = TRUE)
  for (g in files){
    file.copy(from = g, to = to.dir)
  } 
  
}
