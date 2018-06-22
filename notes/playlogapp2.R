
# click button, show lat and long

# PART 2
# here we try: location is shown and updated every time we push the button

# adapted from https://github.com/AugustT/shiny_geolocation

library(shiny)
library(shinyjs)


ui <- fluidPage(
  
  useShinyjs(),
  extendShinyjs(text = '
              shinyjs.getlocation = function(){
                 navigator.geolocation.getCurrentPosition(onSuccess, onError);
              }

              function onError (err) {
              Shiny.onInputChange("geolocation", false);
              }

              function onSuccess (position) {
              setTimeout(function () {
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", true);
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("long", coords.longitude);
              }, 1100)
              }
              ;
              '),
  
  
  verbatimTextOutput("location"),
  actionButton("logbutton","Log!")
  
  )


server <- function(input, output, session){

  # Also works, but there is a delay after clicking and actually retrieving the 
  # location. This way, we have to press the button twice or more to actually see the result.
  # output$location <- eventReactive(input$logbutton, {
  #   js$getlocation()
  # 
  #   return(as.character(input$lat))
  # })
  
  observeEvent(input$logbutton, {
    js$getlocation()
  })
  
  output$location <- eventReactive(input$geolocation, {
    paste(input$lat, input$long)
  })
  
  
}


shinyApp(ui, server)

