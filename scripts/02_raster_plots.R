#------------------#
# Plot raster data #
#------------------#

# 0. Session details ----

# Learn how to make plots with raster data, following this tutorial:
# https://datacarpentry.org/r-raster-vector-geospatial/02-raster-plot.html
# R version 4.3.1 (2023-06-16)
# Running under: Windows 11 x64 (build 22631)

# 1. Load libraries ----
pacman::p_load(terra, dplyr, ggplot2)

# 2. Load raster data ----
dsm.harv    <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif") # Harvard forest
dsm.harv.df <- as.data.frame(dsm.harv, xy = TRUE)

# 3. Plotting data using breaks ----

# Create elevation factor splitting data into 3 levels
dsm.harv.df <- dsm.harv.df %>%
  mutate(elevation_fct = cut(HARV_dsmCrop, breaks = 3))

# Bar plot of elevation as factor
dsm.harv.df %>%
  ggplot() + 
  geom_bar(aes(elevation_fct))

# Count no. in each level using group_by() and  count()
dsm.harv.df %>%
  group_by(elevation_fct) %>%
  count()

# Can also specify custom cut points for a factor
custom_bins <- seq(300,450,50)

dsm.harv.df <- dsm.harv.df %>%
  mutate(elevation_fct2 = cut(HARV_dsmCrop, breaks = custom_bins))

# Plot using custom bins
dsm.harv.df %>%
  ggplot() + 
  geom_bar(aes(elevation_fct2))

# And again get elevation factor level-specific counts
dsm.harv.df %>%
  group_by(elevation_fct2) %>%
  count()

# Use elevation factor to colour a raster plot
dsm.harv.df %>%
  ggplot() + 
  geom_raster(aes(x = x, y = y, fill = elevation_fct2)) + 
  # terrain.colours() gives hexcodes for terrain plotting
  scale_fill_manual(values = terrain.colors(n = 3)) + 
  labs(x="", y="", fill = "Elevation (m)") + 
  theme_minimal() + 
  coord_quickmap()

# Challenge: evenly divide the breaks among the range of elevation values
dsm.harv.df %>%
  mutate(elevation_fct3 = cut(
    HARV_dsmCrop, breaks = quantile(
      HARV_dsmCrop, probs = seq(0,1,1/6)
    ), 
    include.lowest = TRUE)) %>%
  ggplot() + 
  geom_raster(aes(x = x, y = y, fill = elevation_fct3)) + 
  scale_fill_manual(values = terrain.colors(n = 6)) + 
  labs(x="", y="", fill = "Elevation (m)") + 
  theme_minimal() + 
  coord_quickmap()

# 4. Layering rasters ----

# Load hillshade raster
# "A hillshade is a raster that maps the shadows and texture that you would see 
#  from above when viewing terrain"
dsm.harv.hill <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif")

# Summarise the data
dsm.harv.hill

# Convert to dataframe
dsm.harv.hill.df <- as.data.frame(dsm.harv.hill, xy = TRUE)

# Plot hillshade data using transparency factor to give 3 dimensionality
dsm.harv.hill.df %>%
  ggplot() + 
  geom_raster(aes(x = x, y = y, alpha = HARV_DSMhill)) + 
  scale_alpha(range = c(0.15, 0.65), guide = "none") + 
  coord_quickmap()

# Plot layered raster: hillshade + elevation data
ggplot() + 
  geom_raster(data = dsm.harv.df,      aes(x = x, y = y, fill = HARV_dsmCrop)) + 
  geom_raster(data = dsm.harv.hill.df, aes(x = x, y = y, alpha = HARV_DSMhill)) + 
  scale_fill_viridis_c() + 
  scale_alpha(range = c(0.15, 0.65), guide = "none") + 
  labs(title="Elevation with hillshade") + 
  coord_quickmap()

# Challenge: create Digital Terrain Model map & Digital Surface Model map of
# San Joaquin Experimental Range field site

# Load DTM data
dtm.sjer.df <- rast("data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif") %>%
  as.data.frame(., xy = TRUE)

# Load DTM hillshade data
dtm.sjer.hill.df <- rast("data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmHill.tif") %>%
  as.data.frame(., xy = TRUE)

# Load DSM data
dsm.sjer.df <- rast("data/NEON-DS-Airborne-Remote-Sensing/SJER/DSM/SJER_dsmCrop.tif") %>%
  as.data.frame(., xy = TRUE)

# Load DSM hillshade data
dsm.sjer.hill.df <- rast("data/NEON-DS-Airborne-Remote-Sensing/SJER/DSM/SJER_dsmHill.tif") %>%
  as.data.frame(., xy = TRUE)

# Make DTM map
ggplot() + 
  geom_raster(data = dtm.sjer.df, aes(x = x, y = y, fill = SJER_dtmCrop)) + 
  scale_fill_viridis_c() + 
  geom_raster(data = dtm.sjer.hill.df, aes(x = x, y = y, alpha = SJER_dtmHill)) + 
  scale_alpha(range = c(0.15, 0.65), guide = "none") + 
  theme(axis.title = element_blank())

# Make DSM map
ggplot() + 
  geom_raster(data = dsm.sjer.df, aes(x = x, y = y, fill = SJER_dsmCrop)) + 
  scale_fill_viridis_c() + 
  geom_raster(data = dsm.sjer.hill.df, aes(x = x, y = y, alpha = SJER_dsmHill)) + 
  scale_alpha(range = c(0.05, 0.55), guide = "none") + 
  theme(axis.title = element_blank())
