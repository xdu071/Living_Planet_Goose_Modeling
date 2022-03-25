# Exploratory Analysis of Goose Data

# Edited by David 
# November 13th, 2021


# Libraries ----
library(tidyverse)
library(GGally)
library(lme4)
library(stargazer)
library(MuMIn)
library(ggeffects)
library(sjPlot)

# Themes ----
style <- function(){
        font <- "Helvetica"
        theme(plot.title = element_text(family = font, size = 10, face = "bold", color = "#222222", hjust = 0.5), 
              plot.subtitle = element_text(family = font, size = 8, margin = margin(9, 0, 9, 0)), 
              plot.caption = element_blank(),
              plot.margin = unit(c(1,1,1,1), units = , "cm"),
              legend.text.align = 0, 
              legend.position = "bottom",
              legend.title = element_text(family = font, size = 7, face = "bold", color = "#222222",  hjust = 0.5), 
              legend.key = element_blank(), 
              legend.text = element_text(family = font, size = 7, color = "#222222"),
              axis.text = element_text(family = font, size = 7, color = "#222222"), 
              axis.text.x = element_text(margin = margin(7, b = 10)), 
              axis.title = element_text(family = font, size = 9, face = "bold", color = "#222222"), 
              axis.ticks = element_blank(), 
              axis.line = element_line(colour = "black"),
              panel.grid.minor = element_line(color = "#cbcbcb"), 
              panel.grid.major.y = element_line(color = "#cbcbcb"), 
              panel.grid.major.x = element_line(color = "#cbcbcb"), 
              panel.background = element_blank(), 
              strip.background = element_rect(fill = "white"), 
              strip.text = element_text(size = 9, hjust = 0))
}

# Load Living Planet Data ----
load("data/LPI_species.Rdata")

## Clean Data -----------------------------------------------------------------

# Turn years into numeric
LPI_species$year <- parse_number(as.character(LPI_species$year))

# Turn id into factor
LPI_species$id <- as.factor(LPI_species$id)

# Filter Canada goose and observations conducted in Canada
goose <- LPI_species %>%
        filter(Common.Name == "Canada goose" & Country.list %in% "Canada") %>%
        select(-scalepop)

# Remove observations with 'Canada' as location of observation
goose <- goose %>% 
        filter(Location.of.population != "Canada") 

# Rename Quebec into its actual name 
goose$Location.of.population <- gsub("Qu<ed><a9>bec", 
                                     "Quebec", goose$Location.of.population) 

# Turn location of data into a factor
goose$Location.of.population <- as.factor(goose$Location.of.population)

# See location of our data
goose %>%
        group_by(Location.of.population) %>%
        summarize(n = n()) %>%
        ungroup()  # We have 2 locations that are nested within existing provinces

## Exploratory Analysis --------------------------------------------------------

# Investigate the sources of data
goose %>% 
        group_by(Data.source.citation) %>%
        summarize(count = n()) # most from Environment Canada, 471 obs

# Data distribution and Scaling ----

# Original abundance distribution
ggplot(data = goose, aes(x = pop)) +
        geom_histogram(bins = sqrt(nrow(goose))) + # different data collection methods, different units
        style()  # See majority of counts around 0 with a few counts with population > 100,0000

# Try different methods of scaling
goose <- goose %>%
        group_by(id) %>% 
        mutate(rscalepop = (pop - min(pop)) / (max(pop) - min(pop))) %>%  # range scale according to id
        mutate(sscalepop = scale(pop)) %>%  # standardization scaling according to id
        mutate(logpop = log(pop))  # logorithmic scaling

# Distribution of range-scaled population
ggplot(data = goose, aes(x = rscalepop)) +
        geom_histogram(bins = sqrt(nrow(goose))) + 
        style()  # heavily right skewed, data point concentrated at 0

# Distribution of standardized population
ggplot(data = goose, aes(x = sscalepop)) +
        geom_histogram(bins = sqrt(nrow(goose))) + 
        style()  # heavily right skewed, less so than range scaled

# Distribution of log transformed values
ggplot(data = goose, aes(x = logpop)) +
        geom_histogram(bins = sqrt(nrow(goose))) + # set number of bins to sqrt(num of obs)
        style()  # around 24 data points have visibily higher logpop > 10

# Exploring relationship of interest ----

# Scatter plot of standardized pop over time (divided by biome)
ggplot(data = goose, aes(x = year, y = sscalepop, color = biome)) +
        geom_point() + 
        style()  # there is an exponential increase in pop over time, boreal forest has high variation 

# Scatter plot of log scaled pop over time (divided by biome)
ggplot(data = goose, aes(x = year, y = logpop, color = biome)) +
        geom_point() + 
        style()  # again see the group of outliers with logpop > 10 

# **Scatter plot of log scaled pop over time (divided by location of obs)**
ggplot(data = goose, aes(x = year, y = logpop, color = Location.of.population)) +
        geom_point() + 
        style()  #source of variation, observations in Southern James Bay

# **Boxplot (sampling methods vs. location)**
ggplot(data = goose, aes(x = Location.of.population, y = logpop, color = Sampling.method)) +
        geom_boxplot() + 
        style() +
        theme(axis.text.x = element_text(angle = 90))  # South James Bay Obs method diff, during fall
# volunteer survey common across all province

# Boxplot (population ids)
ggplot(data = goose, aes(x = id, y = logpop, color = Location.of.population)) +
        geom_boxplot() + 
        style()  # populations are basically distinct to regions, except ontario, can remove

# No paticular pattern of biome found across different different location of obs
ggplot(data = goose, aes(x = Location.of.population, y = logpop, color = biome)) +
        geom_boxplot() + 
        style() +
        theme(axis.text.x = element_text(angle = 90))

## Extra ----   

# Look at the entire Canada goose population
overall_goose <- LPI_species %>%
        filter(Common.Name == "Canada goose")

overall_goose %>%
        group_by(Country.list) %>%
        summarize(count = n()) %>%
        ungroup()

# Did not consider observations listed as "United States and Canada" since it 
# is not possible to partition by location of observation
overall_goose %>%
        filter(Country.list == "United States, Canada") %>%
        group_by(Location.of.population) %>%
        summarize(count = n()) %>%
        ungroup()