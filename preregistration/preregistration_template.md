# Pre-registration 

Name: David Du

Date: November 15th, 2021

### 1. What is the data source?  Do you have permission to use the data?

The source of this data is a subset from the [Living Planet Database](https://livingplanetindex.org/home/index).  The database is an aggregate of species population observations from multiple credible sources.  The Canada Goose data in Canada in paticular is sourced from   Data is availiable for use for all registered user online.  In terms of the observation for Canadian Goose, data samples are sourced from Rusch et al. (1995), Reiter and Andersen (2011), and Environment Canada (2015).  See references below.

### 2. What is the aim of this study?

My study aims to investigate factors influencing changes in abundance of Canada Goose (*Branta canadensis*) in Canada utilizing modeling approachings.

### 3. What's the main question being asked or hypothesis being tested in this study?

**Research Question**: How does the abundance of Canada Goose varies across **years** and **biomes** while taking into account random effects from location of monitoring, monitoring methods, and units defining abundance.

**Hypothesis**:  It is expected that overall abundance of Canada Goose in Canada do not differ across time but differ across different biomes.  This is in line with prior knowledge where many goose population in Canada have become non-migratory and have settled in warmer biomes due to the availiability of resources.

### 4. Describe the key independent and dependent variable(s).

**Independent Variables**: `Year`, `biome`

**Dependent Variable**: Abundance of Canada Goose measured by various methods and therefore requires scaling to standardize measurements.

### 5. What are the spatial and temporal structures to the data (number of sites, duration in years, etc.)?

**Spatial Structures**: Location of observation

**Temporal Structure**: Year of observation, season of observation within a year (since Canada Goose migrates to the US during winter)

**Other Structure I don't know how to classify**: Methods of observation

### 6. What is the overall sample size?

From my exploratory analysis, there are a total of 552 recorded observations. 

### 7. Specify exactly which analyses you will conduct to examine the main question/hypothesis.

I will construct a mix-effect linear model to explain variations in Canada Goose populations.  My proposed fixed effects are `Year` of observation and `biome` the observation is conducted in.  Subsequent random effects involve location of observation and the methods of observation.  I will then attempt to filter out variables to construct a parsimonious model as a final output. 

### 8. Is there any other study information you would like to pre-register?

I have decided to included observations only done in Canada and not long term monitoring obseservations across multiple countries (e.g. Such as migratory monitoring of geese migration across Atlantic Canadian and American coast).

**References**

Environment Canada (2015). North American Breeding Bird Survey - Canadian Trends Website. Data-version 2014. from http://www.ec.gc.ca/ron-bbs/P001/A001/?lang=e.

Reiter, M. E. and D. E. Andersen (2011). Arctic foxes lemmings and Canada goose nest survival at Cape Churchill Manitoba. The Wilson Journal of Ornithology 123(2): 266-276.

Rusch, D. H., R. E. Malecki, and R. E. Trost (1995). Canada Geese in North America. Our Living Resources: A report to the nation on the distribution abundance and health of U.S. plants animals  and ecosystems. from http://biology.usgs.gov/s+t/noframe/b011.htm





