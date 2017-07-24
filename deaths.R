library(leaflet)
library(sp)
library(rgdal)
library(maps)
library(htmltools)
library(htmlwidgets)
library(ggmap)

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
deaths_update=read.csv('fatal-police-shootings-data-7.3.17.csv')

#create city_state column
deaths_update$city_state=paste0(deaths_update$city, ', ', deaths_update$state)

##geocode additional cities ommitted in first round
latlon2=geocode(deaths_update$city_state[2416:2452], output='latlon')
deaths_update=deaths_update[2416:2452,]
deaths_update$lon=latlon2$lon
deaths_update$lat=latlon2$lat

#date formatting
deaths_update$date=as.Date(deaths_update$date)
deaths_update$full_date=format(deaths_update$date, "%A, %B %d, %Y")

#create name_date column
deaths_update$name_date=paste0(deaths_update$name, ' was fatally shot by police on ', deaths_update$full_date, '. Rest in power.')
deaths_update$name_date=sub('TK TK', 'An unidentified person', deaths_update$name_date)
deaths_update$name_date=sub('Tk Tk', 'An unidentified person', deaths_update$name_date)
deaths_update$name_date=sub('TK Tk', 'An unidentified person', deaths_update$name_date)

#trim original datasets of extraneous columns
deaths=deaths[,3:21]

#paste deaths_update
deaths_7.3.17=rbind(deaths, deaths_update)

#export
write.csv(deaths_7.3.17, file='deaths_7.3.17.csv')


#make map
state = readOGR(dsn=getwd(), layer="State_2010Census_DP1")
mapStates = map("state", fill = TRUE, plot = FALSE)
map = leaflet(data = mapStates) %>% addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(
    radius=12,
    color='firebrick',
    lng = deaths$lon,
    lat = deaths$lat,
    popup = htmlEscape(deaths$name_date),
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
saveWidget(map, 'map.html')
