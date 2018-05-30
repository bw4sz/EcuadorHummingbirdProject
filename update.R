#Run all updates
library(knitr)

setwd("/Users/Ben/Documents/EcuadorHummingbirdProject/")

#clean datas
knit('Aggregate.Rmd')

#run python script to generate bounding boxes
#system("/usr/bin/python /Users/Ben/Documents/DeepMeerkat/Training/GenerateBoxes_new.py")

#Move found frames
source("CopyFrames.R")

#upload to shiny
source("UploadShiny.R")

