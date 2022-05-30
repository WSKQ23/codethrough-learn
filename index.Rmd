---
title: "Mapping Census Data in R"
author: "William Sahr Kamanda"
date: "`r format(Sys.time(), '%d %B %Y')`"
output:
  html_document:
    theme: cerulean
    df_print: paged
    highlight: tango
    toc: yes
    toc_float: yes
---

```{r include = FALSE}

# SET GLOBAL KNITR OPTIONS

knitr::opts_chunk$set(echo = TRUE, 
                      message = FALSE, 
                      warning = FALSE, 
                      fig.width = 10, 
                      fig.height = 8)



# LOAD PACKAGES
library(tidycensus)
library(censusapi)
library(tidyverse)
library(viridis)
library(dplyr)
library(tidyr)
library(DT)

library(pander)
library(kableExtra)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggmap)
library(pander)
library(scales)
library(prettydoc)



census_api_key("312b9edfc29781d3596a1fd71a3f5230d774cd25")

```

<br>

# **Introduction**

The United States census has been the leading source for analyzing neighborhoods since 1790, and it has been of great help to data scientists. Data scientists often face challenges in understanding data the Census Bureau publish and what R packages on CRAN help analyze the census data [here](https://watts-college.github.io/cpp-529-spr-2022/lectures/MappingIntro.html#/). 
<br>

## Content Overview

In this session, learners would learn about the three approaches use for mapping census data and shapefiles, and how to **create maps in R** using the two most recent approaches.

The three approaches for mapping census data and shapefiles are:

1. The historical or old school way of downloading census data and shapefiles into R. This involves going to the Census website and downloading the census data and shapefiles into your computer before analyzing the data.

2. The second approach uses the API w/tigris for maps and gets census for census data. The approach is far more advanced and less time-consuming than the old-school method.

3. The most recent approach, which is the easiest and super fast, is the use of API w/tidycensus for maps and census data. This approach allows access to both census data and shapefiles together.


The **Old School Approach** mapping approach involves the following steps: 

1) Transforming data using **excel**
2) Finding and downloading shapefiles using **Census TIGER** 
3) Importing maps and joining with data and style using **ArcGIS or QGIS**
4) Export the data set into stattisitical packages like **Tableau**, **CartoDB** and **IIustator**

Using the **Tigris package** to download census shapefiles you simply call the following functions depending what you want:

1. **tracts()**
2. **counties()**
3. **school_districts()**
4. **roads()** 

We also need to use the **census API package** from Hannah Resht of Bloomberg, which helps download the census demographic data.
<br>

## Why You Should Care

Data scientists using R face a couple of problems mapping census data in R. Most time, it is not easy to find data published by Census Bureau. Even when you get the census data needed, it is also challenging to understand what package(s)to use in R. The session will help you understand the steps and packages you need for mapping census data in R. 
<br>

## Learning Objectives

To enhance learner's skills in finding and mapping census data through the use of appropriate packages and functions.
<br>

# **Getting started**

For this session, we will concentrate on using the two most recent approaches (API w/tigris and API w/tidycenus)  for downloading census data and shapefiles and how we can further analyze by joining both the census data and shape files to produce a well-informed report.

## Step One 
**Install packages**

Install or call all relevant package. See below some of the relevant package needed. 

1. **censusapi()**
2. **tigris()**
3. **tidycensus()**
4. **tidyverse()**
4. **viridis()**
5. **dplyr()**
6. **tidyr()**
7. **DT()**
<br>

## Steps two 
**Sign up for a Census Key**

The second step is to apply for your census key [here](https://api.census.gov/data/key_signup.html). Install your Census API in your .Renviron File for repeated use through **Source: R/helpers.R**. This function will add your census API key to R.environ file that will help you call the key without key being store in your code. 

Install your key using ***census_api_key(put your key, install = FALSE)*** and ***census_api_key("put your key here", overwrite = TRUE, install = TRUE)*** if you need to overwrite an existing key. 

After you have installed your key, it can be called any time by typing ***Sys.getenv("CENSUS_API_KEY")***.Read more about the census key [here](https://walker-data.com/tidycensus/reference/census_api_key.html#:~:text=After%20you%20have%20installed%20your%20key%2C%20it%20can,file%2C%20the%20function%20will%20create%20on%20for%20you.)
<br>

## Using API w/tigris

This approach is far more advanced and less time-consuming than the old-school method.

### Downloard Census Data

The use of getCensus() function from the package will make an API call and returns a data frame of result. To pass the getCensus() function, you need the following arguments: ***Name*** - the Name of the Census data set, ***Vinatge*** - the year of the data set, ***Vars*** - the Name of the variables you want to access, ***Region*** - the geography level of data, like county or tracts.

However, for you to access all the Census metadata you need to run the function for census metadata as 
```{r, results='hide'}
acs_vars <- listCensusMetadata(name = "acs/acs5", 
                               type = "variables", vintage = 2016)
```
which will help you to have all the variables in **scs and acs5** files. From the table you get from the code above you can search for the variable you want from the data set. For instead you can have variables names like; B21004_001E, B190013_001M and so no. It is up to you base on your data need to decide which variable name you want. For exam A14009 is the variable name for Average Household income by Race.


### Basic Example

Let say we have search through the metadata and we want to download the median income from 2016. Lets start by loading the relevant package and use the function below;
```{r}
library(tigris)

pa_income <- getCensus(name = "acs/acs5", 
                       vintage = 2016, vars = c("NAME", "B19013_001E", "B19013_001M"), 
                       region = "county", regionin = "state:42", 
                       key = "312b9edfc29781d3596a1fd71a3f5230d774cd25") 
# you can use Sys.getenv("CENSUS_API_KEY") to save your key in Renviron

head(pa_income) %>% pander()
```
***Let continue with some basic example by wrangling the data using dplyr***. Now let say we want to rename the variables used in the above code chunk. We rename **B10013_001E as MHI_sss** and **B19013_00M as MHI_soe**. see below:
```{r}
library(dplyr)
pa_income %>% 
  rename(MHI_sss = B19013_001E, 
         MHI_soe = B19013_001M)%>%
  mutate(se = MHI_soe/1.632, cv = (se/MHI_sss)*100)

```

Now let download state shapefile. To download state shapefile we first make sure shape files downloaded as **sf** files.

```{r, warning=FALSE, results='hide'}
library(tigris)

options(tigris_use_cache = TRUE)
options(tigris_class = "sf")
# We can also use the state number in place of the state. For instate Pennsylvanian is the 42 state in US. 
pa <- counties("PA", cb=T)

view(pa)

```

Now let go further my mapping Pennsylvanian, and let try to join the census data of Pennsylvanian with the map
```{r}
library(tigris)

ggplot(pa)+ # we can use the state number in pace of the state
  geom_sf()+
  theme_void()+
  theme(panel.grid.major = element_line(colour = "transparent"))+
  labs(title = "Pennsylvanian counties")
```
<br>

### Advance Example

Let see how we can join both our census data for Pennsylvanian and the Pennsylvanian map as show below
```{r}
head(pa_income)

```

```{r}
pa[[2]]
```

```{r}
pa_for_now <- left_join(pa, pa_income, by=c("COUNTYFP"="county"))
```

```{r}
names(pa_for_now)
```

```{r}
head(pa_for_now, 1)
```

Using all the analysis above we can now plot Pennsylvanian median income using ggplot as show below

```{r, warning=FALSE}
ggplot(pa_for_now)+
  geom_sf(aes(fill=B19013_001E), color="white")+
  theme_void()+
  theme(panel.grid.major = element_line(colour = "transparent"))+
  scale_fill_distiller(palette = "brewer.paired", 
                       direction = 1, name="Median Income")+
  labs(title = "2016 pennsylvanian counties Median Income", 
       caption = "Source: US Census/ACs5")
```
<br>

<br>

## Using API w/tidycensus

Over the years, a lot has improved in mapping Census data. Let us get some idea on how we can download census data and shapefiles together. The most recent census package use to get census data and shapefiles is call **tidycensus**. With tidycensus we can download the shapefiles along with the data we need. With this new approach, you still need to load your census key.



Let's say we want to search for the median income as a variable as we did in the previous steps:
 
```{r, results='hide'}
library(tidycensus)

var_search <- load_variables(2016, "acs5", # Use load_variables to view and search for variables
                             cache = TRUE) # year=2016 and survey=acs5

head(var_search, 3)

var_search$label <- toupper(var_search$label)

income <- var_search %>% 
  mutate(contains.median_income = grepl("MEDIAN INCOME", 
                                        label)) %>% 
  filter(contains.median_income)

head(income, 3)
                          

```

### Example

Now, we are interested in the unemployment rate for a Delaware county in Pennsylvania. We find out the variables for unemployment are B23025_002E, and the variable for the labor force is B23025_005E. Note that we need the variable for the labor force because we will calculate the unemployment rate.

```{r}

library(tidycensus)

work_foc <- c(labor_force = "B23025_005",
              unemployed = "B23025_002")
Pennsylvanian <- get_acs(geography = "tract",  # get_acs() function is located inside the tidycensus package
                         year = 2017, 
                         survey = "acs5", 
                         variables = work_foc, # you need to call work_foc for the two variables
                         county = "Delaware", 
                         state = "42", geometry = T) # 42 shows that Pennsylvanian is the 42 state in US
                         
head(Pennsylvanian)
```

### Transform data

Now let transform the data using dplyr functions
```{r}
library(tidyr)

penns <- Pennsylvanian %>% 
  mutate(variable=case_when( 
    variable=="unemployed" ~ "populationUnemployed",
    variable=="labor_force" ~ "laborForce")) %>%
  select(-moe) %>% 
   spread(variable, estimate) %>%  #Spread moves rows into columns
  mutate(percent_unemployed=round(populationUnemployed/laborForce, 2)) 
 
head(penns)

```


The next step is to arrange the percentage of unemployed in descending order as shown below;
```{r, results='hide'}
arr_desc <- arrange( penns, 
                     desc(percent_unemployed) )

head(arr_desc)

```

### Join Census data and map

Let us close the analysis by showing a map of the unemployment rate in Delaware county in Pennsylvanian as shown below;
```{r}
ggplot(arr_desc) +
  geom_sf(aes(fill=percent_unemployed), color="NA") +
  labs(title = "Unemployment rate in Delaware County",
       subtitle = "",
       caption = "Source: ACS 5-year, 2017",
       fill = "Unemloyment ratio") +
  scale_fill_viridis(direction=-1)


```
<br>

<br>

# **Further Resources**

Learn more about [package, technique, dataset] with the following:

<br>

* Resource  [tidycensus](https://dplyr.tidyverse.org/)

* Resource  [The 5 verbs of dplyr](https://map-rfun.library.duke.edu/02_choropleth.html)

* Resource  [Data Practicum on Community Analytics ](https://watts-college.github.io/cpp-529-spr-2022/schedule/)

* Resource  [Data Practicum Community Analytics by Prof. Anthony Howell](https://watts-college.github.io/cpp-529-spr-2022/lectures/MappingIntro.html#/)

<br>
<br>

# **References**

This code through references and cites the following sources:

* Source I. [Hyperlink Text](https://dplyr.tidyverse.org/)

* Source II. [Hyperlink Text](https://map-rfun.library.duke.edu/02_choropleth.html)

* Source III. [Hyperlink Text](https://watts-college.github.io/cpp-529-spr-2022/schedule/)

<br>
<br>
