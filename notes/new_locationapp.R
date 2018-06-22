

# TODO: https://github.com/daattali/advanced-shiny/tree/master/busy-indicator


library(shiny)
library(shinyjs)
library(shinyWidgets)

tags_list <- c("glijbaan","zandbak","gratis","school",
               "klimrek","kabelbaan","binnen","betaald")

library(mongolite)

options(mongodb = list(
  "host" = "ds113738.mlab.com:13738",
  "username" = "remko",
  "password" = "playpass123"   
))
databaseName <- "playgrounds"
collectionName <- "loggertest"

db <- mongo(collection = collectionName,
            url = sprintf(
              "mongodb://%s:%s@%s/%s",
              options()$mongodb$username,
              options()$mongodb$password,
              options()$mongodb$host,
              databaseName))




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
                Shiny.onInputChange("accuracy", coords.accuracy);
                }, 1100)
                }
                ;
                '),
  
  h1("PlayAlmere logger"),
  
  textInput("name", "Playground name"),
  pickerInput("tags", "Tags", choices = tags_list,
              multiple=TRUE),
  textInput("description", "Description"),
  #textOutput("tags_selected"),
  strong(p("Location")),
  actionButton("logbutton","Get location"),
  textOutput("location", inline=TRUE),
  br(),
  br(),
  textInput("footnote", "Footnote"),
  
  actionButton("save", HTML("<strong>Save record</strong>")),
  actionButton("reset", "Reset")

  
  )


server <- function(input, output, session){
  
  observeEvent(input$logbutton, {
    js$getlocation()
  })
  
  output$location <- eventReactive(input$geolocation, {
    sprintf("Location: %s, %s", 
            round(as.numeric(input$lat),2), 
            round(as.numeric(input$long),2)
    )
  })
  
  #output$tags_selected <- reactive(input$tags)
  
  observeEvent(input$save, {
    
    out <- data.frame(name = input$name,
                      tags = paste(input$tags, collapse="; "),
                      description = input$description,
                      footnote = input$footnote,
                      latitude = input$lat,  # for consistency, and mlab tableview
                      longitude = input$long,
                      accuracy = input$accuracy)
    db$insert(out)
  })

  observeEvent(input$reset, {
    reset("tags")
    reset("description")
    reset("footnote")
    reset("name")
    output$location <- NULL
  })
}


shinyApp(ui, server)

