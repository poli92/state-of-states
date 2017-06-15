#Try to run the states() function until it is successful 
#Connectivity errors sometime occur 
while (exists('statemaps') == FALSE){
  #Create a SPDF for all states
  statemaps <- try(states())
}

#Reduce number of vertices to increase plotting efficiency
usatrimmed <- gSimplify(statemaps, tol=.1, topologyPreserve=TRUE)

#Re-attach the data from the original SPDF
usaspdf <- SpatialPolygonsDataFrame(usatrimmed,data=as.data.frame(statemaps@data))

writeOGR(usaspdf,"usaspdf",driver="ESRI Shapefile",layer = "usaspdf")
