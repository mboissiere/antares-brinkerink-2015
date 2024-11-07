

source(".\\src\\antaresCreateStudy_aux\\addNodes.R")

deane_all_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")

nodes_tbl <- getNodesTable(deane_all_nodes_lst) %>%
  mutate(area = tolower(node),
         continent = tolower(continent) # encore une fois, faudrait le faire depuis le début...
         ) %>%
  # Là du coup c'est ptet redondant ?
  select(area, continent)
# print(nodes_tbl)
  
getPollution <- function() {
  clusters_info <- readClusterDesc()
  clusters_info_tbl <- as_tibble(clusters_info)
  # print(clusters_info_tbl)
  
  clusters_prod <- readAntaresClusters("all", selected = "production", timeStep = "annual", showProgress = TRUE)
  clusters_prod_tbl <- as_tibble(clusters_prod)
  # print(clusters_prod_tbl)
  
  clusters_tbl <- clusters_info_tbl %>%
    left_join(clusters_prod_tbl, by = c("area", "cluster")) %>%
    left_join(nodes_tbl, by = "area") %>%
    select(continent, area, cluster, group, production, co2)
  
  # print(clusters_tbl)
  clusters_pollution_tbl <- clusters_tbl %>%
    mutate(pollution = production * co2)
  
  # print(clusters_pollution_tbl)
  
  return(clusters_pollution_tbl)
}

getContinentalPollution <- function() {
  
  clusters_pollution_tbl <- getPollution()
  
  continent_pollution_tbl <- clusters_pollution_tbl %>%
    group_by(continent, group) %>%
    summarize(pollution_tons = sum(pollution, na.rm = TRUE)) %>%
    select(continent, group, pollution_tons)
  
  # print(continent_pollution_tbl)
  
  filtered_pollution_tbl <- continent_pollution_tbl %>%
    rename(area = continent) %>%
    mutate(fuel = case_when(
      group == "Gas" ~ "Gas",
      group == "Oil" ~ "Oil",
      group == "Hard Coal" ~ "Coal",
      TRUE ~ NA_character_ # In case there are other types not listed
    )) %>%
    filter(fuel %in% c("Gas", "Coal", "Oil")) %>%
    select(area, fuel, pollution_tons)
  
  # print(filtered_pollution_tbl)
  
  # Calculate total pollution per continent
  total_pollution_per_continent <- filtered_pollution_tbl %>%
    group_by(area) %>%
    summarize(pollution_tons = sum(pollution_tons, na.rm = TRUE)) %>%
    mutate(fuel = "Total")
  
  # print(total_pollution_per_continent)
  
  # Combine the original data with the total data
  continent_pollution_with_totals <- filtered_pollution_tbl %>%
    bind_rows(total_pollution_per_continent) %>%
    arrange(area, fuel)
  
  # print(continent_pollution_with_totals)
  
  return(continent_pollution_with_totals)
}

getGlobalPollution <- function() {
  
  area_fuel_pollution_tbl <- getContinentalPollution()
  
  world_pollution_tbl <- area_fuel_pollution_tbl %>%
    filter(fuel == "Total") %>%
    select(area, pollution_tons)
  
  # print(world_pollution_tbl)
  
  world_pollution_tbl <- world_pollution_tbl %>%
    mutate(area = recode(area,
                         "africa" = "Africa", 
                         "asia" = "Asia", 
                         "europe" = "Europe", 
                         "north america" = "North America", 
                         "oceania" = "Oceania", 
                         "south america" = "South America"))
  
  # print(world_pollution_tbl)
  
  # Summing pollution data and adding a "Global" row
  # 1. Create a table with just the continental data (no "Global")
  continental_tbl <- world_pollution_tbl %>%
    filter(area != "Global") %>%
    ungroup()
  
  # 2. Create a separate table for the "Global" total, ungrouping any previous grouping
  global_tbl <- continental_tbl %>%
    summarise(area = "Global", pollution_tons = sum(pollution_tons))
  
  # 3. Combine the two tables (continental data + global data)
  final_tbl <- bind_rows(continental_tbl, global_tbl) %>%
    arrange(desc(pollution_tons))
  
  # print(final_tbl)
  return(final_tbl)
}

# continent_pollution_tbl <- getContinentalPollution()
# print(continent_pollution_tbl, n = 100)
# print(clusters_tbl, n = 50)
