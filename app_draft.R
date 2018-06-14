library(shiny)
library(leaflet)
library(shinyjs)
library(jsonlite)
library(dplyr)

# - TO ADD LOGO: mapview::addLogo


almere <- list(lat=52.367546, lon=5.216377)

data <- jsonlite::fromJSON("data/playgrounds_almere.json")

get_locations <- function(data){
  locs <- lapply(data, "[[", "location") %>% bind_rows %>% as.data.frame
  locs$id <- names(data)
  locs$name <- sapply(data, "[[", "name")
  locs$lon <- as.numeric(locs$lon)
  locs$lat <- as.numeric(locs$lat)
return(locs)
}

locations <- get_locations(data)


playground_icon <- makeIcon(
  iconUrl="icons/playground.png",
  iconWidth=64, iconHeight=64,
  iconAnchorX = 0, iconAnchorY = 64
)


show_playground_popup <- function(id, lat, lng){
  
  play <- data[[id]]
  
  showModal(modalDialog(
    inputId = 'Dialog1',
    easyClose = TRUE,    
    footer = NULL,
    title = HTML('<span style="color:black; font-size: 20px; font-weight:bold; font-family:sans-serif ">Info<span>
                 <button type = "button" class="close" data-dismiss="modal" ">
                 <span style="color:black; ">&times; <span>
                 </button> '),
    div("Playground name:", play$name),
    div("Tags:", paste(play$tags, collapse =", ")),
    div("Nearest address:", play$nearest_address),
    br(),
    br(),
    div(mapply(make_img_div, 
               img=file.path("images", play$images),
               SIMPLIFY=FALSE), id="div_images", class="photolist")
    
    ))
}

make_img_div <- function(img, description=""){
  
    tags$div(class="gallery", 
             tags$a(href=img, #target="_blank",
                    tags$img(src=img, width="300", height="200") 
             ),
             tags$div(description, class="desc")
    )
}


shinyApp(
  ui <- fluidPage(
    
    inlineCSS(
      "div.outer {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      overflow: hidden;
      padding: 0;
      }
      #modal1 .modal-body {
      padding: 10px
      }
      #modal1 .modal-content  {
      -webkit-border-radius: 6px !important;
      -moz-border-radius: 6px !important;
      border-radius: 6px !important;
      }
      #modal1 .modal-dialog { 
      width: 480px; 
      display: inline-block; 
      text-align: left; 
      vertical-align: top;
      }
      #modal1 .modal-header {
      background-color: #339FFF; 
      border-top-left-radius: 6px; 
      border-top-right-radius: 6px
      }
      #modal1 .modal { 
      text-align: right; 
      padding-right:10px; 
      padding-top: 24px;
      }
      #moda1 .close { 
      font-size: 16px
      }
      div.photolist {
      overflow: hidden
      }
      div.gallery {
      overflow: hidden;
      margin: 5px;
      border: 1px solid #ccc;
      float: left;
      width: 240px;
      height: 160px;
      }
      
      div.gallery:hover {
      border: 1px solid #777;
      }
      
      div.gallery img {
      width: 100%;
      height: auto;
      }
      
      div.desc {
      padding: 15px;
      text-align: center;
      }"),
    
    tags$script('
      $(document).ready(function () {
        navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
        function onError (err) {
          Shiny.onInputChange("geolocation", false);
        }
              
        function onSuccess (position) {
          setTimeout(function () {
            var coords = position.coords;
            console.log(coords.latitude + ", " + coords.longitude);
            Shiny.onInputChange("geolocation", true);
            Shiny.onInputChange("userlat", coords.latitude);
            Shiny.onInputChange("userlon", coords.longitude);
          }, 1100)
        }
      });
              '),
    
    div(class="outer", 
        
        leafletOutput("map", width="100%", height="100%")
        
    )
    ),
  server <- function(input, output){
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        #addProviderTiles(providers$CartoDB.Positron) %>%
        setView(lng=almere$lon, lat=almere$lat, zoom=12)
    })
    
    # Find geolocalisation coordinates when user clicks
    observeEvent(input$geoloc, {
      js$geoloc()
    })
    
    observe({
      leafletProxy("map", data=locations) %>%
        clearShapes %>%
        addMarkers(~lon, ~lat, 
                         layerId = ~id,
                   icon = playground_icon,
                   clusterOptions = markerClusterOptions())
    })
    
    observe({
      if(!is.null(input$userlat)){
        map <- leafletProxy("map")
        dist <- 0.5
        lat <- input$userlat
        lng <- input$userlon
        map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
      }
    })
    
    observe({
      event <- input$map_marker_click
      
      if (is.null(event))
        return()
      
      isolate({
        show_playground_popup(event$id, event$lat, event$lng)
      })
    })
    
  }
  )






