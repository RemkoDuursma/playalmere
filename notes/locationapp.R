
# from https://github.com/AugustT/shiny_geolocation

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
  
  verbatimTextOutput("lat"),
  verbatimTextOutput("long"),
  verbatimTextOutput("geolocation")

)


server <- function(input, output, session){
  
  output$lat <- renderPrint({input$lat})
  output$long <- renderPrint({input$long})
  output$geolocation <- renderPrint({input$geolocation})
}




shinyApp(ui, server)