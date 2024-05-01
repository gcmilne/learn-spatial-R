#---------------#
# Vector layers #
#---------------#

# 0. Session details ----

# Introduction to working with point, line & polygon vector data, following this tutorial:
# https://datacarpentry.org/r-raster-vector-geospatial/06-vector-open-shapefile-in-r.html
# R version 4.3.1 (2023-06-16)
# Running under: Windows 11 x64 (build 22631)

# 1. Load libraries ----
pacman::p_load(terra, sf, dplyr, ggplot2)

# 2. Load data ----

# Use sf::st_read() to import a vector layer from a shape (.shp) file
field.boundary <- st_read("data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")

# 3. Spatial metadata ----

# We can view a vector layer's metadata with st_geometry_type(), st_crs() & st_bbox()

# sf::st_geometry_type() tells you the type of spatial object
st_geometry_type(field.boundary)  #polygon

# These are the possible categories of the geometry type:
levels(st_geometry_type(field.boundary))

# Check the CRS using sf::st_crs()
st_crs(field.boundary)

# Find the spatial extent using sf::st_bbox()
st_bbox(field.boundary)

# View all metadata by printing object
field.boundary

# 4. Plot a vector layer ----

# Plot the vector boundary using sf::geom_sf()
field.boundary %>%  # Unlike raster data, don't need to convert to df for ggplot
  ggplot() + 
  geom_sf(fill = "lightblue", size = 3) +
  ggtitle("Boundary plot") +
  coord_sf()  # Coordinate system for plotting sf objects in ggplot

# 5. Challenge: import line & point vector layers ----

# Import road (line) layer
roads <- st_read("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")

# Import tower (point) layer
towers <- st_read("data/NEON-DS-Site-Layout-Files/HARV/HARVtower_UTM18N.shp")

# Plot all layers together: polygon, line & point vector data
ggplot() + 
  geom_sf(data = field.boundary, fill = "lightblue", alpha = 0.5) + 
  geom_sf(data = roads, col = "grey") +
  geom_sf(data = towers, col = "red") + 
  theme_classic()
  