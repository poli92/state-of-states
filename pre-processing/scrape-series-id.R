#Pull all Series IDs from the HTML pages on BLS website

library(rvest)
library(stringr)

#Create an empty dataframe for the Series IDs
SeriesTable <- data.frame(Series.ID = character(),
                 Area = character(),
                 Industry = character(),
                 Datatype = character(),
                 Atdjustment.Method = character()
                 )


#Loop through the number of State FIPS Codes
for (i in 1:56){
  
  #Add leading zeros to fips number
  stfips <- str_pad(as.character(i), 2, pad = "0")
  
  #Create URL string
  url <- paste("https://www.bls.gov/sae/structure",stfips,".htm", sep="")
  
  #Wrapping the read_html function in try() will cause it to return an error 
  #without interrupting processing for invalid URLs  
  try(
  series <- read_html(url)
  )
  
  #Scrape the Series ID table from the webpage 
  temp.SeriesTable <- series %>% 
    html_nodes("table") %>%
    .[[2]] %>%
    html_table() %>%
    data.frame()
  
  #Append the new Series IDs to the existing ones 
  SeriesTable <- rbind(SeriesTable, temp.SeriesTable)
}

SeriesTable <- unique(SeriesTable)

#Save the Series IDs in the project directory 
write.csv(SeriesTable, "series_table.csv")
