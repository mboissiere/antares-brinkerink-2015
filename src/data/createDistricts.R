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

################################################################################

# study_name = "Deane_World_Agg_new__2024_08_19_19_19_44"
# study_path = file.path("input", "antares_presets", study_name,
#                        fsep = .Platform$file.sep)
# simulation_name = "20240819-2115eco-World_thermal15clustering_accurateUCM"
# # study_opts <- setSimulationPath(study_path, simulation_name)
# setSimulationPath(study_path, simulation_name)
# # I'm not sure you can create districts on already existing simulations and things will be fine...
# # I think you gotta start from scratch..sadly.
# # Let's try the following : do Districts on a small run just for the debut
# # then try another World at home, with createsimulation AND readresults and stuff.
# 
# nodes = DEANE_ALL_NODES
# 
# # createDistrictsFromContinents(nodes, study_opts)
# # createDistrictsFromRegionalNodes(nodes, study_opts)
# createDistrictsFromContinents(nodes)
# createDistrictsFromRegionalNodes(nodes)
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
# districts <- getDistricts(districts_data)
# print(districts)
# 
# districts_tbl <- as_tibble(districts_data)
# print(districts_tbl)