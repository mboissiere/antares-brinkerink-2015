# en l'absence de clarté sur comment ça marche les objets Storage, je vais
# prendre les timeseries de Ninja, et juste les balancer dans la timeseries
# Solaire. peut-être que je pourrai faire mieux à un moment, mais là..
library(dplyr)
library(tidyr)

source(".\\src\\data\\preprocessPlexosData.R")
source(".\\src\\data\\preprocessNinjaData.R")
source(".\\src\\objects\\r_objects.R")

print(full_2015_generators_tbl)

csp_timeseries <- getTableFromNinja(CSP_DATA_PATH)

print(csp_timeseries)

# applyFilterForCSP <- function(properties_tbl) %>%
#   rows_to_remove <- properties_tbl %>%
#   filter(scenario == "{Object}Exclude CSP") %>%
#   pull(child_object) %>%
#   unique() %>%
#   toupper()
# 
# generators_tbl <- generators_tbl %>%
#   filter(!generator_name %in% generator_names_to_remove)


getPropertiesCSP <- function() {
  csp_generators_tbl <- full_2015_generators_tbl %>%
    filter(cluster_type == "Solar Thermal") %>%
    select(generator_name, continent, node)
  
  #print(csp_generators_tbl)
  
  generator_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Generators") %>%
    mutate(generator_name = toupper(child_object)) %>%
    # not yet pivot_table, we got some funky scenarios to filter
    # or, i can preprocess that exclude csp stuff in preprocessPlexosData along with 2015 filters...
    filter(scenario != "{Object}Exclude CSP") %>%
    select(generator_name, property, value)
  
  # print(generator_properties_tbl)
    # Obligé de select avant le pivot_wider, sinon les différences dans certaines colonnes
    # comme scenario etc cassent le truc en deux et forcent à faire deux entries
    
    # also de filtrer par la technologie qu'on veut sinon y a des max capacity month de l'hydro qui viennent dire coucou
    # ou whatever autre duplicata d'un scénario qu'on aurait pas filtré, bref relou
    # le left_join avant !! le left_join avant !!
    
  csp_generators_tbl <- csp_generators_tbl %>%
    left_join(generator_properties_tbl, by = "generator_name") %>%
    pivot_wider(names_from = property, values_from = value) %>%
    rename(nominal_capacity = `Max Capacity`,
           units = Units,
           start_cost = `Start Cost`,
           min_stable_factor = `Min Stable Factor`
    ) %>%
    select(generator_name, continent, node, nominal_capacity, units, start_cost, min_stable_factor)
  
    # select(generator_name, property, value) %>%
  
  # print(csp_generators_tbl)
    
    # select(generator_name, property, value)
  
  # print(generator_properties_tbl)
  
  csp_storages_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Storage") %>%
    mutate(storage_name = toupper(name),
           continent = category) %>%
    select(storage_name, continent)
  # continent is useless actually oop
  
# y a des propriétés en sah relou mais ouais

  storage_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Storages") %>%
    mutate(storage_name = toupper(child_object)) %>%
    filter(scenario != "{Object}Exclude CSP") %>%
    filter(scenario != "{Object}Include Solar Multiplier") %>%
    # Not that solar multipliers are evil,
    # but they create a duplicate of Natural Inflow which could fuck pivot_wider up
    select(storage_name, property, value)
  
  csp_storages_tbl <- csp_storages_tbl %>%
    left_join(storage_properties_tbl, by = "storage_name") %>%
    pivot_wider(names_from = property, values_from = value) %>%
    rename(max_volume = `Max Volume`) %>%
    select(storage_name, max_volume)
  
  association_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Generator" & child_class == "Storage") %>%
    mutate(generator_name = toupper(parent_object),
           storage_name = toupper(child_object)
           ) %>%
  select(generator_name, storage_name)
  
  # print(association_tbl)
  
  csp_tbl <- csp_generators_tbl %>%
    left_join(association_tbl, by = "generator_name") %>%
    left_join(csp_storages_tbl, by = "storage_name") %>%
    select(generator_name, storage_name, continent, node, nominal_capacity, max_volume, min_stable_factor)
  # Units are always 1 and start cost is always 0.
  
  
  return(csp_tbl)
}

csp_tbl <- getPropertiesCSP() 
print(csp_tbl)

getCSPFromNodes(nodes) <- function() {
  csp_tbl <- getPropertiesCSP()
  
  csp_tbl <- csp_tbl %>%
    filter(node %in% nodes)
  
  return(csp_tbl)
}

print(getCSPFromNodes("EU-ESP"))




### NEXT STEP : actually model it as a storage with inputs ?
### And seperate onshore, offshore etc into clusters

# tbl <- read.table(CSP_DATA_PATH,
#                   header = TRUE,
#                   sep = ",",
#                   stringsAsFactors = FALSE,
#                   encoding = "UTF-8",
#                   check.names = FALSE
# )
# 
# print(tbl)
# 
# names(tbl) <- toupper(names(tbl))
# 
# print(tbl)
# 
# duplicate_columns <- which(duplicated(names(tbl)))
# print(duplicate_columns)
# tbl <- tbl[ , -duplicate_columns]
# 
# tbl <- tbl[ , -duplicate_columns]
# 
# Since duplicate_columns is an empty vector, -duplicate_columns also results in an empty vector. 
# Subsetting tbl with an empty vector of columns (tbl[ , ]) returns a data frame with no columns 
# but retains the original number of rows.
# 
# ah ouais la sournoiserie de fou
# print(tbl)
# tbl <- as_tibble(tbl)
# 
# print(tbl)

# A chaque fois je m'embete avec une fonction qui va chercher les properties...
# Alors oui quand c'est unique c'est pertinent mais bon.