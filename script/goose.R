# Challenge 3 Statistical Modelling
# Data Science in EES 2021
# Starter script written by Isla Myers-Smith
# 4th November 2021

# Edited by David 
# November 12th, 2021


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
        theme(plot.title = element_text(family = font, size = 14, face = "bold", color = "#222222", hjust = 0.5), 
              plot.subtitle = element_text(family = font, size = 12, margin = margin(9, 0, 9, 0)), 
              plot.caption = element_blank(),
              plot.margin = unit(c(1,1,1,1), units = , "cm"),
              legend.text.align = 0, 
              legend.position = "bottom",
              legend.title = element_text(family = font, size = 9, face = "bold", color = "#222222",  hjust = 0.5), 
              legend.key = element_blank(), 
              legend.text = element_text(family = font, size = 9, color = "#222222"),
              axis.text = element_text(family = font, size = 9, color = "#222222"), 
              axis.text.x = element_text(margin = margin(5, b = 10)), 
              axis.title = element_text(family = font, size = 12, face = "bold", color = "#222222"), 
              axis.ticks = element_blank(), 
              axis.line = element_line(colour = "black"),
              panel.grid.minor = element_line(color = "#cbcbcb"), 
              panel.grid.major.y = element_line(color = "#cbcbcb"), 
              panel.grid.major.x = element_line(color = "#cbcbcb"), 
              panel.background = element_blank(), 
              strip.background = element_rect(fill = "white"), 
              strip.text = element_text(size = 12, hjust = 0))
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

# Try different methods of scaling
goose <- goose %>%
        group_by(id) %>% 
        mutate(rscalepop = (pop - min(pop)) / (max(pop) - min(pop))) %>%  # range scale according to id
        mutate(sscalepop = scale(pop)) %>%  # standardization scaling according to id
        mutate(logpop = log(pop))  # logorithmic scaling

# Remove observations in Nestor One study Site and South James Bay since they
# did not utilize the same survey methods and the number of data points they
# have are too small
goose <- goose %>%
        filter(Location.of.population != "The Nestor One Study Area, Cape Churchil, Manitoba") %>%
        filter(Location.of.population != "Southern James Bay")

goose %>% group_by(Location.of.population) %>% summarize(n = n()) %>% ungroup()

ggplot(data = goose, aes(x = Location.of.population, y = logpop, color = biome)) +
        geom_boxplot() + 
        style() +
        theme(axis.text.x = element_text(angle = 90))

## Analysis of Variance on related variables ------------------------------------

anova(lm(logpop ~ year, data = goose)) 
anova(lm(logpop ~ biome, data = goose))
anova(lm(logpop ~ Location.of.population, data = goose))  # population differs significantly across ywears biomes and location

# Adjust year variable for first year to be 1
goose <- goose %>%
        mutate(adj_year = year - 1969)

# Hierarchical linear model -----------------------------------------------------

# Base Model
bm1 <- lm(logpop ~ adj_year, data = goose)
summary(bm1)  # p-value sig, R-2 0.07

bm2 <- lm(logpop ~ biome, data = goose)
        
bm3 <- lm(logpop ~ Location.of.population, data = goose)


# Mixed-Effect Models 
mm1 <- lmer(logpop ~ adj_year + biome + (1|Location.of.population), 
            data = goose, REML = FALSE)

mm2 <- lmer(logpop ~ adj_year + (1|Location.of.population), 
            data = goose, REML = FALSE)

# Compare based against base model
null <- lmer(logpop ~ 1 + 1 + (1|Location.of.population), 
             data = goose, REML = FALSE)
AICc(null, bm1, bm2, bm3, mm1, mm2)

# Model and data visualisation -------------------------------------------------

# Create a dataset of predicted values and their resulting error and uncertainties
pred.mm <- ggpredict(mm1, terms = c("adj_year"))  # this gives overall predictions for the model

# Presenting Model Output
ggplot(pred.mm) +
        geom_line(aes(x = (x+1969), y = predicted)) +
        geom_ribbon(aes(x = (x+1969), ymin = predicted - std.error, ymax = predicted + std.error), 
                    fill = "lightgrey", alpha = 0.5) + 
        geom_point(data = goose, aes(x = year, y = logpop, color = biome)) +
        labs(x = "Year", y = "log(population)", 
             title = "Change in Canada Goose Population Over Time") +
        style()

# Model output divided by our random effects
ggplot(goose, aes(x = (adj_year + 1969), y = logpop, colour = biome)) +
        facet_wrap(~Location.of.population, nrow=3) +   # a panel for each mountain range
        geom_point(alpha = 0.5) +
        labs(x = "Year", y = "log(population)", 
             title = "Change in Canada Goose Population Over Time by Provinces") +
        theme_classic() +
        geom_line(data = cbind(goose, pred = predict(mm1)), aes(y = pred), size = 1) + 
        theme(panel.spacing = unit(2, "lines"))


# Visualizing model Effects
plot_model(mm1, type = "re", show.values = TRUE)

# Model Diagnostics ------------------------------------------------------------

# Residual Plots
plot(mm1) # significant pattern evident, underestimate lower value, over estimate middle value

qqnorm(resid(mm1))
qqline(resid(mm1)) 


