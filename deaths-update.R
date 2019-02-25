library(leaflet)
library(sp)
library(rgdal)
library(maps)
library(htmltools)
library(htmlwidgets)
library(ggmap)
library(tmap)
library(tmaptools)

setwd("/Users/mia/Documents/Website/Data-police-shootings")

###INITIAL STEPS####

##download and clean data
#deaths=read.csv('fatal-police-shootings-data.csv')

#create city_state column
#deaths$city_state=paste0(deaths$city, ', ', deaths$state)

#geocode cities
#geocodeQueryCheck()
#latlon=geocode(deaths$city_state, output='latlon')
#deaths$lon=latlon$lon
#deaths$lat=latlon$lat

##geocode additional cities ommitted in first round
#latlon2=geocode(deaths$city_state[2319:2415], output='latlon')
#deaths$lon[2319:2415]=latlon2$lon
#deaths$lat[2319:2415]=latlon2$lat

#date formatting
#deaths$date=as.Date(deaths$date)
#deaths$full_date=format(deaths$date, "%A, %B %d, %Y")

#create name_date column
#deaths$name_date=paste0(deaths$name, ' was fatally shot by police on ', deaths$full_date, '. Rest in power.')
#deaths$name_date=sub('TK TK', 'An unidentified person', deaths$name_date)

#export
#write.csv(deaths, file='deaths.csv')

#trouble-shooting unidentified people
#table(deaths$name)[2000:2415] #we see TK TK, also Tk Tk, and TK Tk
#deaths$name_date=sub('Tk Tk', 'An unidentified person', deaths$name_date)
#deaths$name_date=sub('TK Tk', 'An unidentified person', deaths$name_date)
#write.csv(deaths, file='deaths.csv')


####UPDATING DEATHS.CSV#####
##download and clean data
deaths_update=read.csv('fatal-police-shootings-data-2-19-19.csv')
deaths_update=deaths_update[2696:4054,] #bounds are [row.number.last.update + 1  : rows.number.current.update]

##upload last update
deaths_9.30.17=read.csv('deaths_9.30.17.csv')

#create city_state column
deaths_update$city_state=paste0(deaths_update$city, ', ', deaths_update$state, ', USA')


##geocode additional cities ommitted in first round
#eg latlon2=geocode(deaths_update$city_state[2453:2695], output='latlon') #bounds are [row.number.last.update + 1  : rows.number.current.update]
#eg deaths_update=deaths_update[2453:2695,]
#latlon2=geocode(deaths_update$city_state, output='latlon') #bounds are [row.number.last.update + 1  : rows.number.current.update]
#deaths_update$lon=latlon2$lon
#deaths_update$lat=latlon2$lat

##2.19 troubeshooting: ggmaps no longer has free API key
#geocode("Houston", output = "all") <- test
#geocode_OSM("atlanta, ga", as.data.frame = TRUE) <- test
deaths_update$city_state=gsub('300 block of State Line Road, TN', 'Dukedom, TN', deaths_update$city_state)
deaths_update$city_state=gsub('Philadephia, PA', 'Philadelphia, PA', deaths_update$city_state)
deaths_update$city_state=gsub('Scarbo, WV', 'Scarbro, WV', deaths_update$city_state)
deaths_update$city_state=gsub('Columbua', 'Columbia', deaths_update$city_state)
deaths_update$city_state=gsub('Rudioso', 'Ruidoso', deaths_update$city_state)
deaths_update$city_state=gsub('South Whitehall Township, PA', 'South Whitehall, PA', deaths_update$city_state)


latlon3=geocode_OSM(deaths_update$city_state, as.data.frame = TRUE) 
deaths_update$lon=latlon3$lon
deaths_update$lat=latlon3$lat


###troubleshooting#### #missing returns from geocode
#ts=deaths_update$city_state[2453:2695]
#missing=ts[which(is.na(latlon2$lat))]
#ts.latlon=geocode(missing, output='latlon')
#which(is.na(latlon2$lat))
#latlon2$lon[]=ts.latlon$lon[] ## went through and replaced individually  

#date formatting
deaths_update$date=as.Date(deaths_update$date)
deaths_update$full_date=format(deaths_update$date, "%A, %B %d, %Y")

#create name_date column
deaths_update$name_date=paste0(deaths_update$name, ' was fatally shot by police on ', deaths_update$full_date, '. Rest in power.')
deaths_update$name_date=sub('TK TK', 'An unidentified person', deaths_update$name_date)
deaths_update$name_date=sub('Tk Tk', 'An unidentified person', deaths_update$name_date)
deaths_update$name_date=sub('TK Tk', 'An unidentified person', deaths_update$name_date)

#trim original datasets of extraneous columns 
#deaths=deaths[,3:21]

colnames(deaths_9.30.17)
colnames(deaths_update)

#paste deaths_update
deaths_9.30.17=deaths_9.30.17[,2:20] #remove X column
deaths_9.30.17=deaths_9.30.17[,c(1:17,19,18)] #rearrange columns to match deaths_update
colnames(deaths_9.30.17)==colnames(deaths_update) #check match
deaths_2.19.19=rbind(deaths_9.30.17, deaths_update)

#export
write.csv(deaths_2.19.19, file='deaths_2.19.19.csv')


#make map
state = readOGR(dsn=getwd(), layer="State_2010Census_DP1")
mapStates = map("state", fill = TRUE, plot = FALSE)
map = leaflet(data = mapStates) %>% addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(
    radius=12,
    color='firebrick',
    lng = deaths_2.19.19$lon,
    lat = deaths_2.19.19$lat,
    popup = htmlEscape(deaths_2.19.19$name_date),
    clusterOptions = markerClusterOptions(
      freezeAtZoom = 15,
      iconCreateFunction = JS(
        "function (cluster) {
        var childCount = cluster.getChildCount();
        var c = ' marker-cluster-';
        if (childCount < 100) {
        c += 'large';
        } else if (childCount < 1000) {
        c += 'large';
        } else {
        c += 'large';
        }
        return new L.DivIcon({ html: '<div><span>' + childCount + '</span></div>', className: 'marker-cluster' + c, iconSize: new L.Point(40, 40) });
        
        }"
)
      )
      )

map
saveWidget(map, 'map_2-19-19.html')
