
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {
  
  
  #Month dropdown
  output$chooseMonth <- renderUI({
    monthlist <- as.character(unique(subset(filter(fulldataset, year == as.numeric(input$year)), select = "periodName")$periodName))
    selectInput(
      "month", "Month", choices = monthlist, selected = monthlist[1]
    )  
  })
  
  # Update filter keys based on dropdown selections
  IndustryKey <- eventReactive(input$update, {
    input$series
  })
  
  MethodKey <- eventReactive(input$update, {
    input$adjmethod
  })
  
  YearKey <- eventReactive(input$update, {
    input$year
  })
  
  PeriodKey <- eventReactive(input$update, {
    input$month
  })
  
  #keep only the stwd total nonfarm estimate for april
  AreaKey <- "Statewide"
  
  EmpDataMerged <- eventReactive(input$update, {
    #Subset the input dataset using the specified filters
    SubTable <- filter(fulldataset, Area == AreaKey & Industry == IndustryKey() & year == YearKey() & periodName == PeriodKey() & Adjustment.Method == MethodKey())
    
    #Turn STFips into a character with leading 0s where applicable
    SubTable <- mutate(SubTable, STFips = str_pad(as.character(STFips), 2, pad = "0"))
    
    #Join the spatial data with the economic data
    EmpDataMerged <- geo_join(usaspdf,SubTable,"STATEFP","STFips")
    
    EmpDataMerged@data <- filter(EmpDataMerged@data, !(NAME %in% c('American Samoa','Guam','Commonwealth of the Northern Mariana Islands')))
    
    EmpDataMerged
  })
  
  
  
  ###############################################################################
  #  Generate the Leaflet widget
  ###############################################################################  
  output$myMap <- renderLeaflet({
    
    EmpDataMerged <- EmpDataMerged()
    
    #Specify the color based on the data value
    pal <- colorNumeric("Greens",EmpDataMerged$value)
    
    #create a pop-up that states the industry and the the employment value
    popup <- paste(
      "<b>", EmpDataMerged@data$NAME, "</b><br/>",
      EmpDataMerged$Datatype,": ", as.character(EmpDataMerged$value)
    )
    
    #Function to be used for wrapping titles later
    wrapper <- function(x, ...) 
    {
      paste(strwrap(x, ...), collapse = "<br>")
    }
    
    #Create a datatable
    output$table <- DT::renderDataTable({
      DT::datatable(
        data = subset(EmpDataMerged@data, select=c("NAME", "Area","Industry","Datatype",'Adjustment.Method',"year","periodName","value")),
        colnames = list('State','Area','Industry','Data Type',"Adjustment Method",'Year','Month','Data Value')
      )
    })
    
    #Create the leaflet widget 
    mymap <-leaflet(EmpDataMerged) %>%
      setView(lng = -103.0589, lat = 50.3601, zoom = 3) %>%
      addTiles() %>%
      addPolygons(data = EmpDataMerged, 
                  fillColor = ~pal(EmpDataMerged$value), 
                  fillOpacity = 0.7, 
                  weight = 0.2, 
                  popup = popup) %>%
      addLegend(pal = pal, 
                values = ~EmpDataMerged$value, 
                position = "bottomright", 
                title = paste(wrapper(EmpDataMerged$Industry[1], width = 20)))
    
  })
  
  
})
