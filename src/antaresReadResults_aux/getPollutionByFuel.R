
# geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
# print(geography_tbl)
# 
# continents_nodes <- geography_tbl %>%

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
  
  # Deux possibilités ici :
  # # A tibble: 4,897 x 13
  # area   group unitcount nominalcapacity min.stable.power marginal.cost startup.cost market.bid.cost cluster                     co2 timeId  time production
  # <chr>  <chr>     <int>           <dbl>            <dbl>         <dbl>        <dbl>           <dbl> <fct>                     <dbl>  <int> <dbl>      <int>
  #   1 af-ago Gas           1             12               2.4          76.8         883             76.8 ago_gas_namibe59         0.0509      1  2015          0
  # faire confiance à co2 (sachant que POUR L'INSTANT je l'ai mal importé, il fallait faire Production Rate x Heat Rate) et juste le sommer (x production)
  # ou, faire production x heat rate x production rate
  
  # de toute façon, je corrigerai bien un jour l'implémentation de co2, autant le faire...
  
  
  clusters_tbl <- clusters_info_tbl %>%
    left_join(clusters_prod_tbl, by = c("area", "cluster")) %>%
    left_join(nodes_tbl, by = "area") %>%
    select(continent, area, cluster, group, production, co2)
  
  # print(clusters_tbl)
  
  # Gods, I really should just put EVERYTHING in tolower() and it would be soooo much easier.
  
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

# continent_pollution_tbl <- getContinentalPollution()
# print(continent_pollution_tbl, n = 100)
# print(clusters_tbl, n = 50)
