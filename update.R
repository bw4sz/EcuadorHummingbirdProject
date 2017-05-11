#Run all updates
library(knitr)

setwd("C:/Users/Ben/Documents/EcuadorHummingbirdProject/")

#clean data
knit('Aggregate.Rmd')

#Move found frames
source("CopyFrames.R")

#upload to shiny
source("UploadShiny.R")


