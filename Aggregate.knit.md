---
title: "AggregateData"
author: "Ben Weinstein"
date: "May 2, 2017"
output: html_document
---



#Transect Data


```r
transect_files<-list.files(basename,recursive=TRUE,pattern="transect_",full.names=T)

#remove example file
transect_files<-transect_files[!transect_files %in% "transect_example_file.xls"]    

transect_xls<-lapply(transect_files,function(x){
  read.csv(x)
})
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/
## Ben/Dropbox/Ecuador hummingbird project/Public Folder/Data/CBG_Cambugan/
## transect_cbg.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/GRAL_LasGralarias/
## transect_gral.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/MQPC_Maquipucuna/
## transect_mqpc.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/MSPC_MashpiCapuchin/
## transect_mspc.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/STL_Santa Lucia/
## transect_stl.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote
## = quote, : incomplete final line found by readTableHeader on 'C:/
## Users/Ben/Dropbox/Ecuador hummingbird project/Public Folder/Data/
## transect_example_file.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : line 1 appears to contain embedded nulls
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : line 4 appears to contain embedded nulls
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/UPDC_Un Poco Del
## Choco/transect_updc.xlsx'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/VECO_Verdecocha/
## transect_veco.xls'
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote =
## quote, : incomplete final line found by readTableHeader on 'C:/Users/Ben/
## Dropbox/Ecuador hummingbird project/Public Folder/Data/YANA_Yanacocha/
## transect_yana.xls'
```

```r
#Combine files
transect_data<-bind_rows(transect_xls)
```

#Camera Data


```r
camera_files<-list.files(basename,recursive=TRUE,pattern="camera_",full.names = T)

#remove example file
camera_files<-camera_files[!camera_files %in% "camera_example_file.xls"]    

camera_xls<-lapply(camera_files,function(x){
  read.csv(x)
})
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote
## = quote, : incomplete final line found by readTableHeader on 'C:/
## Users/Ben/Dropbox/Ecuador hummingbird project/Public Folder/Data/
## camera_example_file.xls'
```

```r
camera_dat<-bind_rows(camera_xls)
```

#Interaction Data


```r
int_files<-list.files(basename,recursive=TRUE,pattern="camera_",full.names = T)

#remove example file
int_files<-int_files[!int_files %in% "camera_example_file.xls"]    
camera_xls<-lapply(int_files,function(x){
  read.csv(x)
})
```

```
## Warning in read.table(file = file, header = header, sep = sep, quote
## = quote, : incomplete final line found by readTableHeader on 'C:/
## Users/Ben/Dropbox/Ecuador hummingbird project/Public Folder/Data/
## camera_example_file.xls'
```

```r
camera_dat<-bind_rows(camera_xls)
```

## Write cleaned data to three seperate files
