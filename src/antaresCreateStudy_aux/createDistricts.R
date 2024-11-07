library(antaresRead)
library(antaresEditObject)

source(".\\src\\antaresCreateStudy_aux\\addNodes.R")

DEANE_ALL_NODES <- getAllNodes()

nodes_tbl <- getNodesTable(DEANE_ALL_NODES)

source(".\\src\\logging.R")

# print(nodes_tbl)

# tout ça pourrait aller dans utils

isRegionalNode <- function(node) {
  regional_check <- (nchar(node) == 9)
  return(regional_check)
}

# isRegionalNode("AS-CHN-FU")
# isRegionalNode("EU-FRA")

# Une idée de feature qui pourrait etre fun dans une version publiée :
# un générateur de district simplifié
# l'utilisateur pourrait par exemple dire "hm je veux voir les exports de l'UE"

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

createGeographyTable <- function(nodes_lst) {
  
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

geography_tbl <- createGeographyTable(DEANE_ALL_NODES)
saveRDS(geography_tbl, ".\\src\\objects\\geography_tbl.rds")
geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
# print(geography_tbl, n = 258)
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
    msg = paste("[DISTRICTS] - Creating", district_name, "national district from regional nodes...")
    logFull(msg)
    createDistrict(name = district_name,
                   #caption, comments
                   add_area = nodes_in_district,
                   output = TRUE #,
                   # opts = study_opts
                   )
    msg = paste("[DISTRICTS] - Done creating", district_name, "national district!")
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
  msg = "[DISTRICTS] - Done creating global district!"
  logFull(msg)
  # mettre une exception "could not create, skipping" parce que si les nodes et
  # le district existent déjà, y a une erreur qui fait planter le truc
  }

################################################################################
