# Coded by Henrique Barbosa
# hbarbosa@imf.org

# Run this next line if you are running a new install of Rstudio
# and you are not sure if you have all the packages
# install.packages(c("ggplot2", "dismo", "maptools", "raster", "sp", "rgdal","rgeos"))

# Importing the necessary libraries to run the code
libs <- c("ggplot2", "dismo", "maptools", "raster", "sp", "rgdal","ggmap","maps", "mapproj")
lapply(libs, library, character.only=TRUE)

# Establishing two different working directories - one for the data
# and one to save the files in
direc <- "Q:\\DATA\\S1\\BRA\\Inequality\\All figures"
direcmaps <- "Q:\\DATA\\S1\\BRA\\Inequality\\All figures\\RMaps"
setwd(direc)

# Reading the spatial data for Brazil contained in the shapefile BRA_adm1
adm<-readShapeSpatial("RMaps\\BRA_adm_shp\\BRA_adm1.shp")

# The fortify function turns a map into a data frame 
# that can more easily be plotted with ggplot2. Note that
# we are also pointing out in the function what is the "map id"
# variable - in this case, HASC_1 or the codes for each state (BR.AC, BR.DF etc)
adm<-fortify(adm, region = "HASC_1")


# Reading the Gini panel data into R
gini <- read.csv("ginicsv.csv")

# The map id is written with a "BR." in front of the state ID whereas
# the Gini data brings the state ID only. So we're just adding the "BR."
# to ensure the join between the map and the dataset
gini$state <- as.character(gini$state)
gini$state <- paste0("BR.",gini$state)

# Calculating the minimum and maximum Gini numbers we'll be looking into
# They will be later used to draw the scale in the map
mingini <- min(gini$X2004, gini$X2014)
maxgini <- max(gini$X2004, gini$X2014)

setwd(direcmaps)

# These next 6 lines draw the map. We start with ggplot() to open the plot
ggplot() +
  # The geom_map function will basically join the Gini data with the map
  geom_map(data = gini, aes(map_id = state, fill=X2004), map=adm) +
  # expand_limits will make sure the whole area is included in the map
  expand_limits(x=adm$long, y=adm$lat) +
  # theme sets some basic graphic elements to the map - in this case we
  # are setting y and x axis to blank, because we don't want the latitude
  # and longitude shown in the final figure
  theme(axis.text.x=element_blank(), axis.text.y=element_blank(), axis.title.x=element_blank(), axis.title.y=element_blank()) +
  # labs(fill) will change the title of the legend
  labs(fill="Gini (2004)") +
  # scale_fill_gradient2 will set up the colors and limits of the legend
  scale_fill_gradient2(low="darkgreen",  midpoint = 0.525, mid = "white", high="red4", limits=(c(mingini, maxgini))) +
  # Finally, geom_polygon will plot the state boundaries over the map
  # we just created, so we'll have a better view of the differences in color.
  # It is important to bear in mind that these lines are all the same command
  # and are separated here for reading ease. Note how each line has a plus
  # sign at the end.
  geom_polygon(data=adm, aes(x = long, y=lat, group=group), colour="black", fill=NA, size=0.1)

# These two commands save the map we just created in PDF and WMF
ggsave("gini2004pdf5.pdf", plot=last_plot(), device="pdf", dpi=20)
ggsave("gini2004wmf5.wmf", plot=last_plot(), device="wmf", dpi=20)


# Just repeating what was done above but for 2014 instead of 2004.
ggplot() +
  geom_map(data = gini, aes(map_id = state, fill=X2014), map=adm) +
  expand_limits(x=adm$long, y=adm$lat) +
  theme(axis.text.x=element_blank(), axis.text.y=element_blank(), axis.title.x=element_blank(), axis.title.y=element_blank()) +
  labs(fill="Gini (2014)") +
  scale_fill_gradient2(low="darkgreen", midpoint = 0.525, mid = "white", high="red4", limits=(c(mingini, maxgini))) +
  geom_polygon(data=adm, aes(x = long, y=lat, group=group), colour="black", fill=NA, size=0.1)

ggsave("gini2014pdf5.pdf", plot=last_plot(), device="pdf", dpi=20)
ggsave("gini2014wmf5.wmf", plot=last_plot(), device="wmf", dpi=20)