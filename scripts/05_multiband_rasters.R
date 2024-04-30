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

# 2. Load data ----
rgb.band1.harv <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif", 
                       lyrs = 1)
