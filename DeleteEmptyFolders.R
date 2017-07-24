#delete empty folders
a<-list.dirs("C:/Users/Ben/Dropbox/HummingbirdProject/Completed_Frames/",recursive = T)
for(fold in a){
  fil<-list.files(fold)  
  if(length(fil)==0){
    print(fold)
    unlink(fold)
  }
}
