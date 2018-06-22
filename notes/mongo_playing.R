

# following
# https://shiny.rstudio.com/articles/persistent-data-storage.html#mongodb

# things learned
# - password for user cannot have @ in it (a URL delimiter!)
# - database hosting on mlab.com, not mongolab.com as the article says


library(mongolite)

options(mongodb = list(
  "host" = "ds113738.mlab.com:13738",
  "username" = "remko",
  "password" = "playpass123"   
))
databaseName <- "playgrounds"
collectionName <- "playgrounds_almere"

db <- mongo(collection = collectionName,
            url = sprintf(
              "mongodb://%s:%s@%s/%s",
              options()$mongodb$username,
              options()$mongodb$password,
              options()$mongodb$host,
              databaseName))

col <- function(..., sep="; ")paste(..., sep=sep)
data <- data.frame(id="p001", images=col("a.jpg","b.jpg"), tags=col("glijbaan","klimrek","toiletten"))

db$insert(data)

# count rows
# db$count()

# run query
# mongo uses JSON based syntax (nice!)
db$find('{"id" : "p001"}')



# we can upload JSON directly, either as a string, or even as result from fromJSON,
# so actually a list.
json_data <- jsonlite::fromJSON("data/playgrounds_almere.json")
db$insert(json_data)

# better is to loop and insert each separately
for(i in seq_along(json_data)){
  db$insert(json_data[[i]])  
}

# and this returns a dataframe-like thing:
dat <- db$find('{"id" : "p001"}')

# a bit inconvenient
dat$location$lat[[1]]


# Dump the whole thing into JSON instead
db$export(file("play.json"))

# this then attempts to make a dataframe
# but that's not so convenient for our nested format
mydata <- jsonlite::stream_in(file("play.json"), verbose = FALSE)

# apparently there is an iterate() method, as explained here:
# https://github.com/jeroen/mongolite/issues/3

# this is the example that works, however :
# 1 - nobody can read this and make sense of it
# 2 - result is just as nested as before!
# data[[1]]$locations$lon[[1]]
iter <- db$iterate(fields = '{}')
results <- new.env()
while(length(x <- iter$one())){
  id <- x[["_id"]]
  results[[id]] <- x
}
data <- as.list(results)
names(data) <- NULL




