get_locations <- function(data){
  locs <- do.call(rbind, lapply(data, "[[", "location")) %>% 
    as.data.frame
  locs$id <- names(data)
  locs$name <- sapply(data, "[[", "name")
  locs$lon <- as.numeric(locs$lon)
  locs$lat <- as.numeric(locs$lat)
  return(locs)
}

# Hmisc
capitalize <- function (string) {
  capped <- grep("^[A-Z]", string, invert = TRUE)
  substr(string[capped], 1, 1) <- toupper(substr(string[capped], 
                                                 1, 1))
  return(string)
}

format_tagsplay <- function(x){
  
  gsub(";", ", ", x) %>% 
    capitalize
  
}

str_in <- function(x, y, ...){
  any(grepl(x,y), ...)
}


show_playground_popup <- function(id, lat, lng, data){
  
  play <- data[data$id == id,]
  
  showModal(modalDialog(
    inputId = 'Dialog1',
    easyClose = TRUE,    
    footer = NULL,
    title = HTML('<span class="modaltitle">PlayAlmere
                 <span>
                 <button type = "button" class="close" data-dismiss="modal" ">
                 <span style="color:black; "><font size="5">&times;</font> <span>
                 </button> '),
    div(strong(play$name)),
    #div(play$description),
    div(format_tagsplay(play$tagsplay)),
    div(if(str_in("school",play$tagsother)){
      em("Deze speeltuin is alleen buiten schooltijd toegangkelijk.")
    } else ""),
    div(if(str_in("betaald", play$tagsother)){
      em("Let op: deze speeltuin is niet gratis!")
    } else ""),
    br(),
    br(),
    div(if(play$images == ""){
        "" 
      } else {
        mapply(make_img_div, 
               img=file.path("images", unsplit(play$images)),
               SIMPLIFY=FALSE)
      }, id="div_images", class="photolist"),
    div(play$footnote)
    
    ))
}

make_img_div <- function(img, description=""){
  
    tags$div(class="gallery", 
             tags$img(src=img, width="300", height="200"),
             tags$div(description, class="desc")
    )
}



read_playdata <- function(){
  # Read data.
  # Must have config.yml in the working dir with password.
  cg <- config::get()
  
  # Open database connection (hosted on mlab.com)
  options(mongodb = list(
    "host" = "ds113738.mlab.com:13738",
    "username" = cg$username,
    "password" = cg$password   
  ))
  databaseName <- "playgrounds"
  
  om <- options()$mongodb
  db <- mongo(collection = "speeltuinen",
              url = sprintf(
                "mongodb://%s:%s@%s/%s",
                om$username, om$password, om$host,
                databaseName))
  
  #
  playdata <- db$find()
  playdata$id <- paste0("p", 1:nrow(playdata))
  
return(playdata)
}


# Functions for matching images to playgrounds
get_loc <- function(file){
  lon <- system(sprintf('identify -format "%%[EXIF:*GPSLong*]" %s', file), intern=TRUE)
  lat <- system(sprintf('identify -format "%%[EXIF:*GPSLat*]" %s', file), intern=TRUE)
  
  conv <- function(x){
    out <- as.numeric(str_extract_all(x[1], "(\\d+)")[[1]][c(1,3,5)])
    out[1] + out[2]/60 + out[3]/3600
  }
  
  c(lat=conv(lat), lon=conv(lon))
}


distance <- function(x1,y1,x2,y2)sqrt((x1 - x2)^2 + (y1 - y2)^2)


read_images_loc <- function(){
  images <- dir("www/images", pattern="jpg|jpeg", full.names=TRUE)
  images_loc <- as.data.frame(t(sapply(images, get_loc)))
  images_loc$image <- basename(images)
  rownames(images_loc) <- NULL
  
  # save copy for use in app
  saveRDS(images_loc, "data/images_loc.rds")
  return(images_loc)
}

assign_images <- function(playdata, images_loc){
  
  for(i in 1:nrow(images_loc)){
    
    dists <- mapply(distance, x1 = images_loc$lat[i], y1=images_loc$lon[i],
                    x2 = playdata$latitude, y2 = playdata$longitude)
    
    jj <- which.min(dists)
    
    playdata$images[jj] <- paste(playdata$images[jj], images_loc$image[i], sep=";")
  }
  
  return(playdata)
}


unsplit <- function(x){
  out <- strsplit(x, ";")[[1]]
  out[out != ""]
}


