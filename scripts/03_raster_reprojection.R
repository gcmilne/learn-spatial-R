#-----------------------#
# Reproject raster data #
#-----------------------#

# 0. Session details ----

# Learn how to reproject raster data so you can work with raster data in different
# projections, following this tutorial:
# https://datacarpentry.org/r-raster-vector-geospatial/03-raster-reproject-in-r.html
# R version 4.3.1 (2023-06-16)
# Running under: Windows 11 x64 (build 22631)

# 1. Load libraries ----
pacman::p_load(terra, dplyr, ggplot2)

# 2. Load data ----

# digital terrain model
dtm.harv <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif") %>%
  as.data.frame(., xy = TRUE)

# hillshade for digital terrain model
dtm.harv.hill <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif") %>%
  as.data.frame(., xy = TRUE)

# 3. Try to plot map with both rasters overlaid ----

ggplot() + 
  geom_raster(data = dtm.harv, aes(x = x, y = y, fill = HARV_dtmCrop)) + 
  scale_fill_viridis_c() + 
  geom_raster(data = dtm.harv.hill, aes(x = x, y = y, alpha = HARV_DTMhill_WGS84)) + 
  coord_quickmap()

# Noticing that the maps don't plot, we can try each one individually
ggplot() + 
  geom_raster(data = dtm.harv, aes(x = x, y = y, fill = HARV_dtmCrop)) + 
  scale_fill_gradientn(name = "Elevation (m)", colours = terrain.colors(12)) + 
  coord_quickmap()

ggplot() + 
  geom_raster(data = dtm.harv.hill, aes(x = x, y = y, alpha = HARV_DTMhill_WGS84)) + 
  coord_quickmap()

# Note that coordinates for both maps are different, so check their CRSs

# Uses UTM projection
crs.dtm.harv <- crs(rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"), parse = TRUE)
crs.dtm.harv

# Uses Geographic WGS84 projection
crs.dtm.harv.hill <- crs(rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif"), parse = TRUE)
crs.dtm.harv.hill

# 4. Reproject rasters ----

# NB: when we reproject we are moving the data from one grid to another; thus 
#     modifying the data

# use project(object_to_reproject, crs_to_reproject_to); want hillshade CRS to match other raster 
to_reproject <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif")
crs_to_use   <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")
reprojected.dtm.harv.hill <- project(to_reproject, crs(crs_to_use))

# Compare new CRS to old one
crs(reprojected.dtm.harv.hill, parse = TRUE)  #now UTM
crs(to_reproject, parse = TRUE)

# Compare spatial extents
ext(reprojected.dtm.harv.hill)  # UTM so extent is in metres
ext(to_reproject)  # lat/long so in decimal degrees

# Check raster resolution of new projection vs. old
res(reprojected.dtm.harv.hill)  # 1.001 x 1.001 m
res(crs_to_use)  # 1 x 1 m

# Reproject & force matched resolutions between the 2 rasters
reprojected.dtm.harv.hill <- project(to_reproject, crs(crs_to_use), 
                                     res = res(crs_to_use))

# Double check resolution
res(reprojected.dtm.harv.hill)

# Now plot rasters together
reprojected.dtm.harv.hill.df <- as.data.frame(reprojected.dtm.harv.hill, xy = TRUE)

ggplot() + 
  geom_raster(data = dtm.harv, aes(x = x, y = y, fill = HARV_dtmCrop)) + 
  scale_fill_gradientn(name = "Elevation (m)", colours = terrain.colors(10)) + 
  geom_raster(data = reprojected.dtm.harv.hill.df, aes(x = x, y = y, alpha = HARV_DTMhill_WGS84)) + 
  coord_quickmap()
