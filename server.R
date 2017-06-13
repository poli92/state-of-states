
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {

    #keep only the stwd total nonfarm estimate for april 
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
      addTiles() %>%
      addPolygons(data = EmpDataMerged, 
                  fillColor = ~pal(EmpDataMerged$value), 
                  fillOpacity = 0.7, 
                  weight = 0.2, 
                  popup = popup) %>%
      addLegend(pal = pal, 
                values = ~EmpDataMerged$value, 
                position = "bottomright", 
                title = paste(EmpDataMerged$Industry[1], "<br/>(in thousands)"))
    
    output$myMap <- renderLeaflet(mymap)

})
