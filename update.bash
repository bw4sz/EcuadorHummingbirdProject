#Rscript for generating hummingbird data 
cd C:/Users/Ben/Documents/EcuadorHummingbirdProject/
Rscript -e "require ('knitr'); knit ('Aggregate.Rmd')"
Rscript -e "require ('knitr'); knit ('GPSMatching.Rmd')"
Rscript -e "require ('knitr'); knit ('UploadShiny.Rmd')"