library(stringr)
a<-list.dirs("C:/Users/Ben/Dropbox/Ecuador hummingbird project/Public Folder/data/santaluciaupper/foundframes/",recursive = F)

for (i in a){
  subi<-list.dirs(i)
  basename<-str_match(subi[-1],"\\w+$")
  #reformat basename
  newnames<-sapply(basename,function(x){
    print(x)
    camid<-str_split(x,"_")[[1]][1]
    olddate<-str_split(x,"_")[[1]][2]
    oldnum<-str_split(x,"_")[[1]][3]
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
    
    #create directory
    if(!dir.exists(paste(i,camid,newname,sep="/"))){
      dir.create(paste(i,camid,newname,sep="/"),recursive = T)
    
      #file finds in old directory
      tocopy<-list.files(paste(i,x,sep="/"),full.names = T,recursive = T)
      tocopy_to<-paste(paste(i,camid,newname,list.files(paste(i,x,sep="/"),full.names = F,recursive = T),sep="/"))
      
      for(f in 1:length(tocopy)){
        file.copy(tocopy[f],tocopy_to[f])
      }
    }
  })
  
    #remove old files
    for(k in subi[-1]){
      unlink(k,recursive=T)  
    }

}