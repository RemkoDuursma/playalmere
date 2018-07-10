

library(stringr)
source("load_packages.R")


# Read online database
playdata <- read_playdata()

# Extract locations from images (EXIF)
# Also saves result in data/images_loc
images_loc <- read_images_loc()

# Add imags to playdata
# This is how used in the app - not needed here though.
# playdata <- assign_images(playdata, images_loc)

