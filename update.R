#Run all updates
library(knitr)

setwd("C:/Users/Ben/Documents/EcuadorHummingbirdProject/")

#annotate frames
system("python C:/Users/Ben/Documents/EcuadorHummingbirdProject/Annotation/main.py")

#clean data
knit('Aggregate.Rmd')

#Move found frames
source("CopyFrames.R")

#upload to shiny
source("UploadShiny.R")


