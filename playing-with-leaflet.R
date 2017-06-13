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

states()

#Create a SPDF for all states
statemaps <- states()

#Reduce number of vertices to increase plotting efficiency
usatrimmed <- gSimplify(statemaps, tol=0.01, topologyPreserve=TRUE)

#Re-attach the data from the original SPDF
usaspdf <- SpatialPolygonsDataFrame(usatrimmed,data=as.data.frame(statemaps@data))

#read in state emp data
fulldataset <- read.csv('empdata.csv')



#keep only the stwd total nonfarm estimate for april 
StateKey <- 1
AreaKey <- "Statewide"
IndustryKey <- "Total Nonfarm"
YearKey <- 2017
PeriodKey <- "M04"
MethodKey <- "Seasonally Adjusted"

#Subset the input dataset using the specified filters
SubTable <- filter(fulldataset, Area == AreaKey & Industry == IndustryKey & year == YearKey & period == PeriodKey & Adjustment.Method == MethodKey)

#Turn STFips into a character with leading 0s where applicable 
SubTable <- mutate(SubTable, STFips = str_pad(as.character(STFips), 2, pad = "0"))

#Join the spatial data with the economic data
EmpDataMerged <- geo_join(usaspdf,SubTable,"STATEFP","STFips")

#Specify the color and number of quantiles
pal <- colorQuantile("Greens",NULL, n=6)

#create a pop-up that states the industry and the the employment value
popup <- paste(
               "<b>", EmpDataMerged@data$NAME, "</b><br/>",
               EmpDataMerged$Industry,"(in thousands): ", as.character(EmpDataMerged$value)
)

#Create the leaflet widget 
mymap <-leaflet() %>%
  addTiles() %>%
    addPolygons(data = EmpDataMerged, 
                fillColor = ~pal(EmpDataMerged$value), 
                fillOpacity = 0.7, 
                weight = 0.2, 
                popup = popup)

mymap

#saveWidget(mymap, file="mymap.html")
