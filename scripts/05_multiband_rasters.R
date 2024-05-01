#--------------------#
# Multi-band rasters #
#--------------------#

# 0. Session details ----

# Work with multi-band rasters, following this tutorial:
# https://datacarpentry.org/r-raster-vector-geospatial/05-raster-multi-band-in-r.html
# R version 4.3.1 (2023-06-16)
# Running under: Windows 11 x64 (build 22631)

# 1. Load libraries ----
pacman::p_load(terra, dplyr, ggplot2)

# 2. Define functions ----

# Function for reading in a specific layer of a multi-band raster 
read.raster <- function(filename, layer.num){
  imported.raster <- rast(filename, lyrs = layer.num)
  return(imported.raster)
}

# 3. Import a specific raster band ----

# rast() with `lyrs` argument - specify which layer(s) to import from multiband raster
# For an RGB image, layer 1 is the red band, 2 the green & 3 the blue
rgb.band1 <- read.raster(filename = "data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif", 
                         layer.num = 1)

rgb.band2 <- read.raster(filename = "data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif", 
                         layer.num = 2)

# Convert to data frame
rgb.band1.df <- as.data.frame(rgb.band1, xy = TRUE)
rgb.band2.df <- as.data.frame(rgb.band2, xy = TRUE)

# 4. Summarise & plot the single layer rasters ----

# Summarise the raster
rgb.band1  # note that values range 0-255 on the RGB scale, 0 lightest, 255 brightest
rgb.band2
describe(sources(rgb.band1))

# Plot red band
rgb.band1.df %>% 
  ggplot() + 
  geom_raster(aes(x = x, y = y, alpha = HARV_RGB_Ortho_1)) + 
  coord_quickmap()

# Plot green band
rgb.band2.df %>% 
  ggplot() + 
  geom_raster(aes(x = x, y = y, alpha = HARV_RGB_Ortho_2)) + 
  coord_quickmap()

# Compare frequencies: trees reflect back more green than red light - so green brighter
ggplot() + 
  geom_histogram(data = rgb.band1.df, aes(x = HARV_RGB_Ortho_1), fill = "red", alpha=.3) + 
  geom_histogram(data = rgb.band2.df, aes(x = HARV_RGB_Ortho_2), fill = "green", alpha=.3)

# 5. Working with raster stacks (multi-band rasters) ----

# Read in multi-band raster
rgb.stack <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif")

# Inspect attributes
rgb.stack

# Use object[[index]] notation to access specific layers, e.g.:
rgb.stack[[1]]

# Convert stack to dataframe
rgb.stack.df <- rgb.stack %>% 
  as.data.frame(., xy = TRUE)

# Note how each layer gets its own column
head(rgb.stack.df)

# Create histogram of all three bands
rgb.stack.df %>% 
  tidyr::pivot_longer(cols = !c(x,y)) %>%
  ggplot() + 
  geom_histogram(aes(x = value, fill = name), alpha = .3) + 
  labs(fill = "Band")

# Create raster of one specific band
rgb.stack.df %>%
  ggplot() + 
  geom_raster(aes(x = x, y = y, alpha = HARV_RGB_Ortho_1))
  
# Create a multi-band image using terra::RGBstack()
plotRGB(rgb.stack)  #can optionally define ordering (defaults to red = 1, green = 2, blue = 3)

# If distribution of pixel brightness skewed towards 0 or 255, can "stretch" values
plotRGB(rgb.stack, stretch = "lin") #linear stretch
plotRGB(rgb.stack, stretch = "hist") #histogram stretch
  
# 6.  Challenge: NoData values ----

# Load data
ortho <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_Ortho_wNA.tif")

# Check attributes
ortho  # 3 bands
describe(sources(ortho))  #NoData value of -9999

# Plot as true colour image
plotRGB(ortho)  #black edges not plotted since values of -9999 defined as NA

# 7. Building a SpatRasterDataset ----

# Use terra::sds() to create a SpatRasterDataset
rgb.sds <- sds(rgb.stack)  # can use a single multi-band SpatialRaster
rgb.sds <- sds(list(rgb.stack, rgb.stack))  # or a list of SpatialRasters

# What methods can be applied to SpatialRaster objects?
methods(class=class(rgb.stack))
methods(class=class(rgb.stack[[1]]))

# Confirming the same methods can be applied, irrespective of no. of bands
all(methods(class=class(rgb.stack)) %in% methods(class=class(rgb.stack[[1]])))
