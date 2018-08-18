source("load_packages.R")

# Center of map on open, and on clicking Home button.
almere <- list(lat=52.367546, lon=5.216377)

# Read data
playdata <- read_playdata()

# Read image locations. Re-run script "assign_images" when new images added.
images_loc <- readRDS("data/images_loc.rds")
playdata <- assign_images(playdata, images_loc)

# Icon to plot playgrounds
playground_icon <- makeIcon(
  iconUrl="icons/playground.png",
  iconWidth=64, iconHeight=64,
  iconAnchorX = 0, iconAnchorY = 64
)



code_locate <- "function(btn, map){ 
                 map.locate({setView: true, maxZoom: 12})
                     .on('locationfound', function(e){
            var marker = L.marker([e.latitude, e.longitude]).bindPopup('You are here :)');
            var circle = L.circle([e.latitude, e.longitude], e.accuracy/2, {
                weight: 1,
                color: '#ADD8E6',
                fillColor: '#ADD8E6',
                fillOpacity: 0.65
            });
            map.addLayer(marker);
            map.addLayer(circle); }) 
                     }"

code_gohome <- sprintf("function(btn,map){map.setView([%s, %s], 12);}", almere$lat, almere$lon)



shinyApp(
  ui <- fluidPage(theme="bootstrap_flatly_custom.css",
        img(src="playalmere_logo.png", width=150, height= 50),
        h4(em(sprintf("Vind een van %s speeltuinen in Almere!", nrow(playdata)))),
        tags$style(type = "text/css", "#map {height: calc(100vh - 160px) !important;}"),
        withSpinner(leafletOutput("map"), type = 8),
        p("Samengesteld door Peli, Remko en Daisy, geproduceerd door", 
          a("www.remkoduursma.com", href="https://www.remkoduursma.com"))
        ),
  
  server <- function(input, output){
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        setView(lng=almere$lon, lat=almere$lat, zoom=12) %>%
        addEasyButtonBar(
          easyButton(
          icon="fa-crosshairs", title="Locate Me", onClick=JS(code_locate)),
          easyButton(icon="fa-home", title="Almere", onClick=JS(code_gohome))
        ) 
      # %>%
      #   addLogo("playalmere_logo.png",
      #           position = "topright",
      #           width = 200,
      #           height = 200,
      #           offset.x=10, 
      #           offset.y=10)
    })
    
    # This is reactive but does not have to be if just plotting playgrounds statically.
    # However we can add a filter option later.
    observe({
      leafletProxy("map", data=playdata) %>%
        clearShapes %>%
        addMarkers(~longitude, ~latitude, 
                   layerId = ~id,
                   icon = playground_icon,
                   clusterOptions = markerClusterOptions(showCoverageOnHover = FALSE))
    })
    
    # Event when clicking on a marker
    observe({
      event <- input$map_marker_click
      
      if (is.null(event)){
        return()
      } else { 
        show_playground_popup(event$id, event$lat, event$lng, data=playdata)
      }
      
    })
    
  }
  )






