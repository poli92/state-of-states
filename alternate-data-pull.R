library(blsAPI)
library(rjson)
library(RCurl)

#Define the apiDF function (courtesy Mike Silva https://github.com/mikeasilva/blsAPI)
## Process results
apiDF <- function(data){
  df <- data.frame(year=character(),
                   period=character(),
                   periodName=character(),
                   value=character(),
                   stringsAsFactors=FALSE)
  
  i <- 0
  for(d in data){
    i <- i + 1
    df[i,] <- unlist(d)
  }
  return(df)
}

SeriesList <- c('SMS01000000000000001', 'SMS01000000500000001')

payload <- list(
  'seriesid'=SeriesList,
  'startyear'=2007,
  'endyear'=2009)
response <- blsAPI(payload, 2)
json <- fromJSON(response)

EmpData <- data.frame(seriesID = character(),
                      year = character(),
                      period = character(),
                      periodName = character(),
                      value = character()
                      )

i <- 1
h <- length(SeriesList)

for (i in 1:h){

  SeriesID <- json$Results$series[[i]]$seriesID
  
  SeriesData <- apiDF(json$Results$series[[i]]$data)
  
  EmpData <- rbind(cbind(SeriesID, SeriesData),EmpData)

}

