library(ggmap)
library(sp)
library(maptools)
library(rgeos)
library (tmap)
library(rgdal)
library(leaflet)
deaths=read.csv('fatal-police-shootings-data.csv')
deaths$city_state=paste0(deaths$city, ', ', deaths$state)
latlon=geocode(deaths$city_state, output='latlon')
geocodeQueryCheck()
deaths$lon=latlon$lon
deaths$lat=latlon$lat

##make map using sp package
state <- readShapeSpatial(fn="State_2010Census_DP1")
index <- (as.data.frame(state)$STUSPS10 %in% c("AK", "HI")) #identify AK and HI data
state <- state[!index,] #remove AK and HI data
plot(state)
points(x=deaths$lon, y=deaths$lat) 


##make the map in leaflet
str(state)
lmap=leaflet(state) %>% addPolygons(data = getMapData(lmap))
lmap2 = addAwesomeMarkers(lmap, lng = deaths$lon, lat=deaths$lat)
lmap2


##stuck trying to add popups
lmap3= addPopups(lmap2,lng = deaths$lon, lat=deaths$lat, options = popupOptions(), data = getMapData(lmap))
?addPopups

?addPolygons
?getMapData
?addAwesomeMarkers
?popup
