# Introduction to mapping in R
if (!require("pacman")) install.packages("pacman")
pacman::p_load(terra, sf, purrr, leaflet, htmlwidgets, RColorBrewer, dplyr)

# Working directory
wd <- getwd()

# Area of interest
shp <- geodata::gadm(country = "KEN", level=1, path = paste0(wd), version="latest") %>% sf::st_as_sf()

# Travel time layer
travel_time <- terra::rast(paste0(wd, "/traveltimetomarket_ssa_020k.tif"))

# Extract travel time
county_travel_time <- travel_time %>% 
  terra::extract(., shp, fun = mean, na.rm = TRUE)

# Merge the extracted data to the polygons
shp <- st_as_sf(shp) %>% 
  mutate(ID := seq_len(nrow(.))) %>% 
  left_join(., county_travel_time, by = "ID")

# Color palette
pal <- colorBin("YlOrRd", domain = shp$traveltimetomarket_ssa_020k)

# Leaflet
sample_map <- leaflet(shp) %>%
  addTiles() %>% 
  addPolygons(
    stroke = TRUE, 
    color = "black",
    weight = 1,
    fillOpacity = 0.5,
    fillColor =  ~pal(traveltimetomarket_ssa_020k),
    highlight = highlightOptions(weight = 5, color = "white", bringToFront = TRUE),
    label = paste0(shp$NAME_1, ": ", round(shp$traveltimetomarket_ssa_020k, 1)),
    labelOptions = leaflet::labelOptions(direction = "top", textsize = "14px")) %>%
  addLegend(pal = pal, 
            values = shp$traveltimetomarket_ssa_020k,
            opacity = 0.7, title = "Travel time (Hours)", position = "topright")

#. Save map
saveWidget(sample_map, file="sample_map.html")
