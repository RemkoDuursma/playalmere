
# click button, show lat and long
# here location is retrieved once when the document loads.


# adapted from https://github.com/AugustT/shiny_geolocation

library(shiny)


ui <- fluidPage(
  
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
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("long", coords.longitude);
              }, 1100)
              }
              });
              '),  
  
  verbatimTextOutput("location"),
  actionButton("logbutton","Log!")

)


server <- function(input, output, session){
  
  output$location <- eventReactive(input$logbutton, {
    if(input$geolocation){
      sprintf("Lat: %s  Long: %s", 
              round(as.numeric(input$lat),2), 
              round(as.numeric(input$long),2))
    } else {
      ""
    }
  })
  
}




shinyApp(ui, server)
