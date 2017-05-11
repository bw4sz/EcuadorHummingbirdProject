#Run all updates
library(knitr)

#clean data
knit('Aggregate.Rmd')

#Move found frames
source("CopyFrames.R")

#upload to shiny
source("UploadShiny.R")


