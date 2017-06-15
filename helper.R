# This program reads in and wrangles the dataset that provides the backbone of the application 



library(dplyr)
library(stringr)
library(rgeos)
library(tigris)
library(sp)
library(rgdal)
library(leaflet)
library(DT)

rm(list=ls())

#read in state emp data
fulldataset <- readRDS("data/empdata.Rda")

#Extract just an ordered list of series codes and names 
SeriesCodes <- unique(fulldataset[c("SeriesCode","Industry")])

SeriesCodes <- SeriesCodes[with(SeriesCodes, order(SeriesCode, Industry)), ]

#Series name list for input selection in UI
series <- as.character(SeriesCodes$Industry)

#read in trimmed USA shapefile 
usaspdf <- readOGR("usaspdf","usaspdf")
