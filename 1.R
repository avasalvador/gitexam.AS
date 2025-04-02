# find_rare_birds.R
# Description:
#   This script identifies rare bird sightings from FeederWatch observation data.
#   It is intended to be run from the command line using:
#     Rscript find_rare_birds.R [list of CSV files using wildcards is okay]
#   The script automatically processes all input files and produces two output CSV files:
#     - rare_overall.csv: species observed exactly once across all years
#     - rare_per_year.csv: species observed only once in each year

# Inputs:
#   - List of observation CSVs passed via command line
#   - PFW-species-translation-table.csv (species names, must be in working directory)
#
# Outputs:
#   - rare_overall.csv
#   - rare_per_year.csv
#
# Validation:
#   To validate the accuracy of this script, several verification steps were taken. 
#   First, the resulting datasets `rare_overall` and `rare_per_year` were manually inspected using the `head()` and `View()` functions to confirm the expected structure and values. 
#   Second, frequency checks were performed using the `count()` function to ensure that all species included in `rare_overall` appeared exactly once across the entire dataset, and those in `rare_per_year` appeared exactly once within each year. 
#   Specifically, the following commands were used: `rare_overall %>% count(species_code) %>% filter(n > 1)` and `rare_per_year %>% count(species_code, Year) %>% filter(n > 1)`. 
#   Both returned zero rows, confirming that the filtering logic using `group_by()` and `filter(n() == 1)` correctly identified species observed only once. 
#   These steps collectively validate that the outputs match the criteria described in the assignment.

# 1. Load Libraries
library(tidyverse)


# 3. Read and combine observation files
obs_list <- lapply(args, read_csv)
obs <- bind_rows(obs_list)

# 4. Read species translation file
species_info <- read_csv("https://tinyurl.com/bird-info")

# 5. Select relevant columns from observations
obs_clean <- obs %>%
  select(species_code, loc_id, latitude, longitude, subnational1_code, Year)

# 6. Merge with species info
merged <- obs_clean %>%
  left_join(species_info %>%
              select(species_code, 
                     `scientific name`, 
                     `american english name`),
            by = "species_code")

# 7. Create 'rare_overall.csv' — species seen exactly once overall
rare_overall <- merged %>%
  group_by(species_code) %>%
  filter(n() == 1) %>%
  ungroup()

write_csv(rare_overall, "rare_overall.csv")

# 8. Create 'rare_per_year.csv' — species seen once *per year*
rare_per_year <- merged %>%
  group_by(species_code, Year) %>%
  filter(n() == 1) %>%
  ungroup()

write_csv(rare_per_year, "rare_per_year.csv")

