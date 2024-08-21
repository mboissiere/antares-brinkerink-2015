library(antaresRead)
library(antaresEditObject)

source(".\\src\\data\\addNodes.R")

DEANE_ALL_NODES <- getAllNodes()

nodes_tbl <- getNodesTable(DEANE_ALL_NODES)

source(".\\src\\logging.R")

# print(nodes_tbl)

# tout ça pourrait aller dans utils mais pour l'instant flemme
isRegionalNode <- function(node) {
  regional_check <- (nchar(node) == 9)
  return(regional_check)
}

# isRegionalNode("AS-CHN-FU")
# isRegionalNode("EU-FRA")

getCountryFromRegionalNode <- function(regional_node) {
  country_node <- substring(regional_node, 1, 6)
  return(country_node)
}

# test_tbl <- nodes_tbl %>%
#   mutate(name_length = nchar(node))

#print(test_tbl, n = 200)

regional_nodes_tbl <- nodes_tbl %>%
  filter(isRegionalNode(node)) %>%
  mutate(district = getCountryFromRegionalNode(node))

createGeographyTable <- function(nodes_lst) { # things would be more robust if this was
  # nodes and not NODES everywhere
  nodes_tbl <- getNodesTable(nodes_lst)
  
  regional_nodes_tbl <- nodes_tbl %>%
    filter(isRegionalNode(node)) %>%
    mutate(district = getCountryFromRegionalNode(node))
  
  # Step 1: Prepare the regional_nodes_tbl
  regional_nodes_prepared <- regional_nodes_tbl %>%
    mutate(
      country = substr(node, 1, 6),  # Extract the first 6 characters as country code (e.g., NA-CAN)
      region = node,                  # The node itself will serve as the region
      node = node
    ) %>%
    select(continent, country, region, node)
  
  # Step 2: Prepare the nodes_tbl
  nodes_prepared <- nodes_tbl %>%
    filter(!node %in% regional_nodes_tbl$node) %>%  # Filter out nodes that are already regions
    mutate(
      country = node,                # The node itself is the country
      region = NA,                    # Countries without regions will have NA in the region column
      node = node
    ) %>%
    select(continent, country, region, node)
  
  # Step 3: Combine both prepared tibbles
  geography_tbl <- bind_rows(regional_nodes_prepared, nodes_prepared)
  
  # Optional: Arrange by continent and country
  geography_tbl <- geography_tbl %>%
    arrange(continent, country, region, node)
  
  return(geography_tbl)
}

geography_tbl <- createGeographyTable(all_deane_nodes_lst)
saveRDS(geography_tbl, ".\\src\\objects\\geography_tbl.rds")
geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
print(geography_tbl, n = 258)
# print(createGeographyTable(north_america_nodes_lst))

# print(regional_nodes_tbl, n = 100)
# 
# getDeaneCountries # sous entendu, pas la régionalisation Deane
# # En vrai, s'embêter à faire une liste Deane "mais avec les districts des régionalisés" etc
# # c'est se prendre la tête alors que dans readAntares on pourra faire un "all" jpense

createDistrictsFromRegionalNodes <- function(nodes #, 
                                             #study_opts
                                             ) {
  nodes_tbl <- getNodesTable(nodes)
  
  regional_nodes_tbl <- nodes_tbl %>%
    filter(isRegionalNode(node)) %>%
    mutate(country = getCountryFromRegionalNode(node))
  
  districts_in_tbl <- regional_nodes_tbl$country %>%
    unique()
  
  for (district in districts_in_tbl) {
    district_tbl <- regional_nodes_tbl %>%
      filter(country == district)
    
    district_name <- tolower(district)
    nodes_in_district <- tolower(district_tbl$node)
    msg = paste("[DISTRICTS] - Creating", district_name, "district from regional nodes...")
    logFull(msg)
    createDistrict(name = district_name,
                   #caption, comments
                   add_area = nodes_in_district,
                   output = TRUE #,
                   # opts = study_opts
                   )
    msg = paste("[DISTRICTS] - Done creating", district_name, "district!")
    logFull(msg)
    
    # print(district_name)
    # print(nodes_in_district)
  }
}

################################################################################

createDistrictsFromContinents <- function(nodes #, 
                                          # study_opts
                                          ) {
  nodes_tbl <- getNodesTable(nodes)
  
  nodes_tbl <- nodes_tbl %>% # everything be in lowercase u kno how it is
    mutate(node = tolower(node),
           continent = tolower(continent)
           )
  
  continents <- nodes_tbl$continent %>% unique()
  # print(continents)
  
  for (district in continents) {
    district_tbl <- nodes_tbl %>%
      filter(continent == district)
    
    district_name <- tolower(district)
    nodes_in_district <- tolower(district_tbl$node)
    
    # print(district_name)
    # print(nodes_in_district)
    
    msg = paste("[DISTRICTS] - Creating", district_name, "continental district...")
    logFull(msg)
    createDistrict(name = district_name,
                   #caption, comments
                   add_area = nodes_in_district,
                   output = TRUE #,
                   #opts = study_opts
                   )
    msg = paste("[DISTRICTS] - Done creating", district_name, "continental district!")
    logFull(msg)

  }
}

createGlobalDistrict <- function(nodes #, 
                                          # study_opts
                                 ) {
  all_areas = tolower(nodes)
  msg = "[DISTRICTS] - Creating global district..."
  logFull(msg)
  createDistrict(name = "world",
                 add_area = all_areas,
                 output = TRUE
                 )
  msg = "[DISTRICTS] - Done creating global district..."
  logFull(msg)
  }

################################################################################

# # study_name = "Deane_World_Agg_new__2024_08_19_19_19_44"
# study_name = "Deane_SA__2024_08_20_15_34_00"
# study_path = file.path("input", "antares_presets", study_name,
#                        fsep = .Platform$file.sep)
# # simulation_name = "20240819-2115eco-World_thermal15clustering_accurateUCM"
# simulation_name = "20240820-1537eco-15thmclu_accucm_districtstest"
# # study_opts <- setSimulationPath(study_path, simulation_name)
# setSimulationPath(study_path, simulation_name)
# # I'm not sure you can create districts on already existing simulations and things will be fine...
# # I think you gotta start from scratch..sadly.
# # Let's try the following : do Districts on a small run just for the debut
# # then try another World at home, with createsimulation AND readresults and stuff.
# 
# nodes = south_america_nodes_lst
# 
# # createDistrictsFromContinents(nodes, study_opts)
# # createDistrictsFromRegionalNodes(nodes, study_opts)
# # createDistrictsFromContinents(nodes)
# # createDistrictsFromRegionalNodes(nodes)
# 
# ################################################################################
# 
# library(dplyr)
# library(tidyr)
# 
# variables_of_interest <- c("SOLAR", "WIND",
#                            "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
#                            "LOAD",
#                            "H. STOR",
#                            "BALANCE",
#                            "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
#                            "UNSP. ENRG",
#                            "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
#                            "Battery_injection", "Battery_withdrawal", "Battery_level",
#                            "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
#                            "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
#                            "Other3_injection", "Other3_withdrawal", "Other3_level") # Rappel : CAE
# 
# setSimulationPath(study_path, simulation_name)
# 
# districts_data <- readAntares(areas = "all",
#                               districts = "all",
#                               timeStep = "daily",
#                               select = variables_of_interest
#                               )
# 
# districts <- getDistricts(NULL)
# print(districts)
# areas <- getAreas(NULL)
# print(areas)
# 
# # districts_tbl <- as_tibble(districts_data)
# # # Error in `recycle_columns()`:
# # #   ! Tibble columns must have compatible sizes.
# # # * Size 728: Column `districts`.
# # # * Size 7644: Column `areas`.
# # # i Only values of size one are recycled.
# print(districts_data)
# print(districts_data$districts)
# districts_tbl <- as_tibble(districts_data$districts)
# print(districts_tbl)
# # Ok !!! Yes !! It works !! I Understand Districts actually
# # and they should be able to give me yummy yummy country/continental data if I run another World Deane
# # with districts in them
# # (and screw the edit/updateStudy where i'd make functions for studies that already exist, honestly)
# # print(districts_tbl$district %>% unique())
# 
# #########
# 
# no_districts_data <- readAntares(areas = "all",
#                               #districts = "all",
#                               timeStep = "daily",
#                               select = variables_of_interest
# )
# 
# print(no_districts_data)
# print(no_districts_data$areas)
# #> print(no_districts_data$areas)
# #NULL
# 
# # attention donc aux imports !
# # dans l'idéal il faudrait faire genre... un continent check, country check, region check