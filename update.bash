#Rscript for generating hummingbird data 
cd C:/Users/Ben/Documents/EcuadorHummingbirdProject/

#clean data
Rscript -e "require ('knitr'); knit ('Aggregate.Rmd')"
Rscript -e "require ('knitr'); knit ('GPSMatching.Rmd')"

#upload to shiny
Rscript -e "require ('knitr'); knit ('UploadShiny.Rmd')"

#move foundframes to google cloud
gsutil


