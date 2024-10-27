# End-use/sector: Industry sector total,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# Data: Monthly electricity demand for weekday,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# Unit: kWh,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,,,,,,,,,,,,

## ATTENTION !! kWh !!!

library(dplyr)
library(tidyr)

KWH_COLUMNS = c("Canada", "USA", "Mexico", "Rest Central America", "Brazil", 
                "Rest South America", "Northern Africa", "Western Africa", "Eastern Africa",
                "Southern Africa", "Western Europe", "Central Europe", "Turkey", 
                "Ukraine +", "Asia-Stan", "Russia +", "Middle East", "India +", 
                "Korea", "China +", "Southeastern Asia", "Indonesia +", "Japan", 
                "Oceania", "Rest S.Asia", "Rest S.Africa")

NB_KWH_IN_MWH = 1000

nodes_timezones_path <- ".\\input\\deane_castillo\\PLEXOS_countries_TZ.txt"
nodes_image_path <- ".\\input\\deane_castillo\\IMAGE_Deane_codes.txt"

#getTableFromCastillo <- function(castillo_data_path) {
nodes_timezones_tbl <- read.table(nodes_timezones_path,
                                  header = TRUE,
                                  sep = ";",
                                  # dec = ".",
                                  stringsAsFactors = FALSE,
                                  encoding = "UTF-8",
                                  check.names = FALSE,
                                  fill = TRUE
)
nodes_timezones_tbl <- as_tibble(nodes_timezones_tbl) %>%
  rename(node = Node, timezone = `Time Zone Delta`, utc_delta = Delta) %>%
  select(node, timezone, utc_delta)
# return(nodes_timezones_tbl)
#}
nodes_image_tbl <- read.table(nodes_image_path,
                              header = TRUE,
                              sep = ";",
                              # dec = ".",
                              stringsAsFactors = FALSE,
                              encoding = "UTF-8",
                              check.names = FALSE,
                              fill = TRUE
)
nodes_image_tbl <- as_tibble(nodes_image_tbl) %>%
  rename(node = Node, image_id = `IMAGE Id`, region_name = `Region Name`) %>%
  select(node, image_id, region_name)

print(nodes_timezones_tbl)
print(nodes_image_tbl)

deane_load_path <- ".\\input\\deane_castillo\\All Demand UTC 2015.txt"

deane_load_tbl <- read.table(deane_load_path,
                             header = TRUE,
                             sep = ",",
                             # dec = ".",
                             stringsAsFactors = FALSE,
                             encoding = "UTF-8",
                             check.names = FALSE,
                             fill = TRUE
)
deane_load_tbl <- as_tibble(deane_load_tbl)

# Calculate annual load for each country and pivot the table
annual_load_tbl <- deane_load_tbl %>%
  select(-Datetime) %>%                      # Remove the Datetime column
  summarise(across(everything(), sum)) %>%   # Sum the values for each country
  pivot_longer(cols = everything(),          # Pivot all columns to rows
               names_to = "node", 
               values_to = "annual_load")

# Print the result
print(annual_load_tbl)

deane_castillo_tbl <- nodes_image_tbl %>%
  left_join(nodes_timezones_tbl, by = "node") %>%
  left_join(annual_load_tbl, by = "node") %>%
  replace_na(list(annual_load = 0)) %>%
  mutate(node = tolower(node))

print(deane_castillo_tbl, n = 300)

total_world_load <- sum(deane_castillo_tbl %>% pull(annual_load))

deane_castillo_tbl <- deane_castillo_tbl %>%
  group_by(image_id) %>%
  mutate(image_region_load = sum(annual_load, na.rm = TRUE),
         region_proportion_to_world = image_region_load / total_world_load) %>% # Calculate total load for each macro-region
  ungroup() %>% # Ungroup after the operation is complete
  mutate(node_proportion_to_region = annual_load / image_region_load, # Calculate each node's load proportion
         node_proportion_to_world = region_proportion_to_world * node_proportion_to_region)
# Print the result
print(deane_castillo_tbl, n = 300)

saveRDS(deane_castillo_tbl, ".\\src\\2060\\node_regions_timezones_tbl.rds")


# source(".\\src\\utils.R")

#### Checks sympa à faire :

# > prop <- node_regions_timezones_tbl %>% pull(node_proportion_to_world)
# > sum(prop)
# [1] 1
## on pourrait faire aussi region proportion to world et node proportion to region mais flm