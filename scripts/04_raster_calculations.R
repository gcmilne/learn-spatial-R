#---------------------#
# Raster calculations #
#---------------------#

# 0. Session details ----

# Use raster math to subtract one raster from another, following this tutorial:
# https://datacarpentry.org/r-raster-vector-geospatial/04-raster-calculations-in-r.html
# R version 4.3.1 (2023-06-16)
# Running under: Windows 11 x64 (build 22631)

# 1. Load libraries ----
pacman::p_load(terra, dplyr, ggplot2)

# 2. Load data ----

# Harvard forest data
dsm.harv <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
dtm.harv <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")

# Reminder of what the data look like
patchwork::wrap_plots(

    dsm.harv %>%
      as.data.frame(., xy = TRUE) %>%
      ggplot() + 
      geom_raster(aes(x=x, y=y, fill=HARV_dsmCrop)) + 
      scale_fill_gradientn(name = "Elevation (m)", colors = terrain.colors(n=10)) + 
      ggtitle("Digital surface model") + 
      coord_quickmap(), 
    
    dtm.harv %>%
      as.data.frame(., xy = TRUE) %>%
      ggplot() + 
      geom_raster(aes(x=x, y=y, fill=HARV_dtmCrop)) + 
      scale_fill_gradientn(name = "Elevation (m)", colors = terrain.colors(n=10)) + 
      ggtitle("Digital terrain model") + 
      coord_quickmap()
  
)

# 3. Simple raster math ----

# Create Canopy Height Model (CHM) by simply subtracting DTM from DSM
chm.harv <- dsm.harv - dtm.harv

# Plot CHM raster
chm.harv %>% 
  as.data.frame(., xy = TRUE) %>%
  ggplot() + 
  geom_raster(aes(x=x, y=y, fill=HARV_dsmCrop)) + 
  scale_fill_gradientn(name = "Canopy height (m)", colors = terrain.colors(10)) + 
  coord_quickmap()

# Plot CHM distribution (NB most tree heights 0-30 m)
chm.harv %>% 
  as.data.frame(., xy = TRUE) %>%
  ggplot() + 
  geom_histogram(aes(x=HARV_dsmCrop))

# Check range of tree heights
chm.harv %>% 
  as.data.frame(., xy = TRUE) %>%
  select(HARV_dsmCrop) %>%
  range()

# Discretise tree height and replot the raster map
chm.harv %>% 
  as.data.frame(., xy = TRUE) %>%
  mutate(canopy_discrete = cut(HARV_dsmCrop, breaks = seq(0,40,10), include.lowest = TRUE)) %>%
  ggplot() + 
  geom_raster(aes(x = x, y = y, fill = canopy_discrete)) + 
  scale_fill_manual(values = RColorBrewer::brewer.pal(length(seq(0,40,10)), "Greens")) + 
  labs(fill="Discretised canopy height (m)") + 
  coord_quickmap()

# 4. Efficient raster calculations ----

# Raster math is OK for small rasters & simple calculations, but we can use more 
# efficient methods for larger rasters &/or more complex calculations

# Use lapp() to apply user-defined function to raster inputs
chm.efficient <- lapp(x = sds(dsm.harv, dtm.harv),  # sds() creates a SpatRasterDataset
                      fun = function(r1, r2){ return(r1 - r2) })


# Plot CHM calculated using these more efficient method
chm.efficient %>% 
  as.data.frame(., xy = TRUE) %>%
  ggplot() + 
  geom_raster(aes(x=x, y=y, fill=HARV_dsmCrop)) + 
  scale_fill_gradientn(name = "Canopy height (m)", colors = terrain.colors(10)) + 
  coord_quickmap()

# 5. Export a GeoTIFF file ----
writeRaster(x = chm.efficient,  # file to export
            filename = "generated_rasters/CHM_harvard_forest.tiff",
            filetype = "GTiff", # output format
            overwrite = TRUE,   # if file with same exists, overwrite
            NAflag = -9999)     # set the GeoTIFF tag for NoDataValue t
