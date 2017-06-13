#The program will pull every series using the BLS API. 
#Because the API will allow only 50 series to be pulled at a time,
#the process must be completed iteratively

#Must run srape-series-id first 

library(blsAPI)

#Pull in the config file containing the API Key
config <- read.csv("input/config.csv")

#Pull in the list of Series IDs created by scrape-series-id.R
SeriesIDs <- read.csv("series_table.csv")

#Subset only to the All Employee datatype and keep only the Series.ID var 
SeriesFrame <- subset(SeriesIDs, Datatype=="All Employees, In Thousands", 
                     select = Series.ID)

#Transform the Series.ID to a vector 
SeriesVector <- sort(as.vector(SeriesFrame$Series.ID))

#calculate the integer portion of the quotient 
n <- as.integer(length(SeriesVector)/50)

h <- 1

SequenceMax <- h+49

EmpData <- data.frame(year = character(),
                      period = character(),
                      periodName = character(),
                      value = character(),
                      seriesID = character())

#Loop through the pulls, pulling 50 series at a time for n iterations
for (i in 1:n){
  
  SeriesSubset <- SeriesVector[h:SequenceMax]

  #Specify the payload to be pulled
  payload <- list('seriesid' = SeriesSubset, 'registrationKey' = config$APIKey)
  
  #Store the returned data
  response <- blsAPI(payload = payload, api.version = 2, return.data.frame = FALSE)
  json <- fromJSON(response)
  
  q <- length(SeriesSubset)
  
  for (p in 1:q){
    
    SeriesID <- json$Results$series[[p]]$seriesID
    
    SeriesData <- apiDF(json$Results$series[[p]]$data)
    
    EmpData <- rbind(cbind(SeriesID, SeriesData),EmpData)
    
  }
  
  h <- h + 50
  SequenceMax <- SequenceMax + 50
  }

#For the final pull, pull only the remaining number of series (if any)
if (length(SeriesVector)%%50 != 0){
  
  SequenceMax <- h + length(SeriesVector)%%50 - 1
  
  SeriesSubset <- SeriesVector[h:SequenceMax]
  
  #Specify the payload to be pulled
  payload <- list('seriesid' = SeriesSubset, 'registrationKey' = config$APIKey)
  
  #Store the returned data
  response <- blsAPI(payload = payload, api.version = 2, return.data.frame = FALSE)
  json <- fromJSON(response)
  
  q <- length(SeriesSubset)
  
  for (p in 1:q){
    
    SeriesID <- json$Results$series[[p]]$seriesID
    
    SeriesData <- apiDF(json$Results$series[[p]]$data)
    
    EmpData <- rbind(cbind(SeriesID, SeriesData),EmpData)
    
  }
}

sorted <- EmpData[order(substr(EmpData$SeriesID, 4, 20),EmpData$year,EmpData$period),]

write.csv(sorted, "empdata.csv")

