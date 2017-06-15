fulldataset <- read.csv("data/empdata.csv")

#Use only supersectors for the time being 
fulldataset <- filter(fulldataset, substr(seriesID,13,18) == '000000')

#Create an actual series code 
fulldataset <- mutate(fulldataset, SeriesCode = substr(seriesID,11,18))

#Turn STFips into a character with leading 0s where applicable 
fulldataset <- mutate(fulldataset, STFips = str_pad(as.character(STFips), 2, pad = "0"))

saveRDS(fulldataset,file='data/empdata.Rda')