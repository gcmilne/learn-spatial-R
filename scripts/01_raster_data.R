#----------------------#
# Intro to raster data #
#----------------------#

# 0. Session details ----

# Intro to learn how to use raster data, following this tutorial:
# https://datacarpentry.org/r-raster-vector-geospatial/01-raster-structure.html#:~:text=The%20GeoTIFF%20format%20contains%20a,this%20before%20importing%20your%20data
# R version 4.3.1 (2023-06-16)
# Running under: Windows 11 x64 (build 22631)

# 1. Load libraries ----
pacman::p_load(terra, dplyr, ggplot2)

# 2. Load & summarise raster data ----

# Describe the raster data without loading into environment
describe("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

# Load raster data
dsm.harv <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif") # Harvard forest

# Summarise data
dsm.harv
summary(dsm.harv) # function uses a uses random sample of 100,000 cells

# Calculate min & max elevation
minmax(dsm.harv)

# Same as doing...
range(values(dsm.harv))

# How many bands (i.e. layers) in the raster data?
nlyr(dsm.harv)

# 3. Plot raster data ----

# Convert to data frame using as.data.frame() from package terra
dsm.harv.df <- terra::as.data.frame(dsm.harv, xy = TRUE)

# What do the data look like?
str(dsm.harv.df)

# Plot the data
dsm.harv.df %>%
  ggplot() + 
  geom_raster(aes(x = x, y = y, fill = HARV_dsmCrop)) + 
  scale_fill_viridis_c() +
  coord_quickmap()  #approximate Mercator projection (suitable for small areas)

# NB for faster plotting, can use plot() directly on geotiff data
# plot(dsm.harv)

# 4. Inspect Coordinate Reference System (CRS) and associated metadata ----

# Use crs() from terra to view the CRS string associated with R object
crs(dsm.harv, proj = TRUE)

# 5. Dealing with missing & bad data values

# Use describe() & sources() to see what values are treated as NA
describe(sources(dsm.harv)) #NoData Value=-9999

# Can use hist to find bad data values (those that fall outside of applicable range)
dsm.harv.df %>%
  ggplot() +
  geom_histogram(aes(HARV_dsmCrop))
