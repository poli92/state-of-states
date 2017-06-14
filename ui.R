
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shinydashboard)
library(shiny)
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



source("helper.R")

series <- as.character(SeriesCodes$Industry)
names(series) <- as.character(SeriesCodes$Industry)

header <- dashboardHeader(
  # Application title
  title = "US State Employment Data"
)

body <- dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("myMap", height = 500)
           )
    ),

    column(width = 3,
           box(width = NULL, status = "warning",
               ###############################################################################
               #  Add a dropdown box for selecting which series to display
               ############################################################################### 
               selectInput(
                 "series", "Industry", choices = series, selected = series[1]
               ) 
               )
           )
  ),
  fluidRow(
    DT::dataTableOutput("table")
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)
