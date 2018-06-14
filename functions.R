get_locations <- function(data){
  locs <- do.call(rbind, lapply(data, "[[", "location")) %>% 
    as.data.frame
  locs$id <- names(data)
  locs$name <- sapply(data, "[[", "name")
  locs$lon <- as.numeric(locs$lon)
  locs$lat <- as.numeric(locs$lat)
  return(locs)
}


show_playground_popup <- function(id, lat, lng){
  
  play <- data[[id]]
  
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

