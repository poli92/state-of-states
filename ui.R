
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
               ), 
               ###############################################################################
               #  Add a dropdown box for selecting which adjustment method to display
               ############################################################################### 
               selectInput(
                 "adjmethod", "Adjustment Method", choices = levels(fulldataset$Adjustment.Method), selected = fulldataset$Adjustment.Method[1]
               ), 
               ###############################################################################
               #  Add a dropdown box for selecting which year to display
               ############################################################################### 
               selectInput(
                 "year", "Year", choices = unique(as.character(fulldataset$year)), selected = fulldataset$year[1]
               ), 
               ###############################################################################
               #  Add a dropdown box for selecting which month to display
               ############################################################################### 
               uiOutput('chooseMonth'),
               p(
                 class = "text-muted",
                 "Source: US Bureau of Labor Statistics API"
               ),
               p(
                 class = "text-muted",
                  "Disclaimer: BLS.gov cannot vouch for the data or analyses derived from these data after the data have been retrieved from BLS.gov."
               )
               )
           )
  ),
  fluidRow(
    column(
      DT::dataTableOutput("table"),width = 12
    )
    
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)
