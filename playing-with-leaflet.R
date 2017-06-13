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

#keep only the stwd total nonfarm estimate for april 
AreaKey <- "Statewide"
IndustryKey <- "Total Nonfarm"
YearKey <- 2017
PeriodKey <- "M04"
MethodKey <- "Seasonally Adjusted"

#Subset the input dataset using the specified filters
SubTable <- filter(fulldataset, Area == AreaKey & Industry == IndustryKey & year == YearKey & period == PeriodKey & Adjustment.Method == MethodKey)

#Join the spatial data with the economic data
EmpDataMerged <- geo_join(usaspdf,SubTable,"STATEFP","STFips")

#Specify the color based on the data value
pal <- colorNumeric("Greens",EmpDataMerged$value)

#create a pop-up that states the industry and the the employment value
popup <- paste(
               "<b>", EmpDataMerged@data$NAME, "</b><br/>",
               EmpDataMerged$Datatype,": ", as.character(EmpDataMerged$value)
)

#Create the leaflet widget 
mymap <-leaflet(EmpDataMerged) %>%
  setView(lng = -103.0589, lat = 42.3601, zoom = 2) %>%
    addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
                     ) %>%
      addPolygons(data = EmpDataMerged, 
                  fillColor = ~pal(EmpDataMerged$value), 
                  fillOpacity = 0.7, 
                  weight = 0.2, 
                  popup = popup) %>%
        addLegend(pal = pal, 
                  values = ~EmpDataMerged$value, 
                  position = "bottomright", 
                  title = paste(EmpDataMerged$Industry[1], "<br/>(in thousands)"))


mymap

#saveWidget(mymap, file="mymap.html")
