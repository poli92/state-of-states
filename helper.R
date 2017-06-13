library(leaflet)
library(maps)
library(tigris)
library(dplyr)
library(htmlwidgets)
library(rgdal)
library(raster)
library(sp)
library(rgeos)
library(stringr)
library(magrittr)

#read in state emp data
fulldataset <- read.csv('data/empdata.csv')

#Use only supersectors for the time being 
fulldataset <- filter(fulldataset, substr(seriesID,13,18) == '000000')

#Create an actual series code 
fulldataset <- mutate(fulldataset, SeriesCode = substr(seriesID,11,18))

#Turn STFips into a character with leading 0s where applicable 
fulldataset <- mutate(fulldataset, STFips = str_pad(as.character(STFips), 2, pad = "0"))

#Extract just an ordered list of series codes and names 
SeriesCodes <- unique(fulldataset[c("SeriesCode","Industry")])

SeriesCodes <- SeriesCodes[with(SeriesCodes, order(SeriesCode, Industry)), ]

#ensure that there is no residual statemaps object in environment
rm(statemaps)

#Try to run the states() function until it is successful 
#Connectivity errors sometime occur 
while (exists('statemaps') == FALSE){
  #Create a SPDF for all states
  statemaps <- try(states())
}

#Reduce number of vertices to increase plotting efficiency
usatrimmed <- gSimplify(statemaps, tol=.1, topologyPreserve=TRUE)

#Re-attach the data from the original SPDF
usaspdf <- SpatialPolygonsDataFrame(usatrimmed,data=as.data.frame(statemaps@data))




