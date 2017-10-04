#delete empty folders
a<-list.dirs("/Users/Ben/Dropbox/HummingbirdProject/Data/",recursive = T)
for(fold in a){
  fil<-list.files(fold)  
  if(length(fil)==0){
    print(fold)
    unlink(fold,recursive = T)
  }
}
