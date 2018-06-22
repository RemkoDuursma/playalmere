get_locations <- function(data){
  locs <- do.call(rbind, lapply(data, "[[", "location")) %>% 
    as.data.frame
  locs$id <- names(data)
  locs$name <- sapply(data, "[[", "name")
  locs$lon <- as.numeric(locs$lon)
  locs$lat <- as.numeric(locs$lat)
  return(locs)
}


show_playground_popup <- function(id, lat, lng, data){
  
  play <- data[data$id == id,]
  
  showModal(modalDialog(
    inputId = 'Dialog1',
    easyClose = TRUE,    
    footer = NULL,
    title = HTML('<span class="modaltitle">Info
                 <span>
                 <button type = "button" class="close" data-dismiss="modal" ">
                 <span style="color:black; "><font size="5">&times;</font> <span>
                 </button> '),
    div(strong(play$name)),
    div(play$description),
    div("Spelen:", play$tagsplay),
    div("Voorzieningen:", play$tagsother),
    br(),
    br(),
    div(if(play$images == ""){
        "" 
      } else {
        mapply(make_img_div, 
               img=file.path("images", play$images),
               SIMPLIFY=FALSE)
      }, id="div_images", class="photolist"),
    div(play$footnote)
    
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

