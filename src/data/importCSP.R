# en l'absence de clarté sur comment ça marche les objets Storage, je vais
# prendre les timeseries de Ninja, et juste les balancer dans la timeseries
# Solaire. peut-être que je pourrai faire mieux à un moment, mais là..
library(dplyr)
library(tidyr)

source(".\\src\\data\\preprocessPlexosData.R")
source(".\\src\\data\\preprocessNinjaData.R")
source(".\\src\\objects\\r_objects.R")

# print(full_2015_generators_tbl)

# csp_timeseries <- getTableFromNinja(CSP_DATA_PATH)
# saveRDS(object = csp_timeseries, file = ".\\src\\objects\\csp_clusters_ninja_tbl.rds")

# print(csp_timeseries)

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

# csp_tbl <- getPropertiesCSP()
# saveRDS(object = csp_tbl, file = ".\\src\\objects\\csp_properties_plexos_tbl.rds")
# csp_tbl <- readRDS(".\\src\\objects\\csp_properties_plexos_tbl.rds")
# print(csp_tbl)

getCSPFromNodes <- function(nodes) {
  csp_tbl <- getPropertiesCSP()
  
  csp_tbl <- csp_tbl %>%
    filter(node %in% nodes)
  
  return(csp_tbl)
}

# print(getCSPFromNodes("EU-ESP"))

# Relou, faut refaire la fonction aggregateGeneratorTimeSeries parce que ça parse
# la colonne storage_name et pas generator_name
# si j'étais chaud je ferais une sorte de fonction fils là qui se décline
# mais flemme pour l'instant

aggregateStorageTimeSeries <- function(nodes, properties_tbl, timeseries_tbl) {
  # objectif : nodes donne champ d'étude, properties_tbl est un objet global avec tout,
  # ninja_tbl est un objet global avec tout, et on filtrera

  storages_tbl <- properties_tbl %>%
    #filter(node %in% nodes) %>%
    select(storage_name, node) #, nominal_capacity, units)
  # On va pas multiplier par la nominal capacity, cette fois-ci.
  
  # nodes_studied <- generators_tbl$node
  # print(storages_tbl)
  
  product_tbl <- timeseries_tbl %>%
    gather(key = "storage_name", value = "production", -DATETIME) 
  
  # print(product_tbl, n = 9001)
  
  product_tbl <- product_tbl %>% 
    left_join(storages_tbl, by = "storage_name") %>%
    filter(node %in% nodes)
  
  # print(product_tbl)
  
  # product_tbl <- product_tbl %>%
  #   mutate(power_output = units * nominal_capacity * capacity_factor / 100)
  
  product_tbl <- product_tbl %>%
    select(DATETIME, node, production)
  
  # print(product_tbl)
  
  aggregated_tbl <- product_tbl %>%
    group_by(DATETIME, node) %>%
    summarize(node_production = sum(production, na.rm = FALSE), .groups = 'drop')
  
  # print(aggregated_tbl)

  aggregated_tbl <- aggregated_tbl %>%
    pivot_wider(names_from = node, values_from = node_production)
  
  # print(aggregated_tbl)
  
  return(aggregated_tbl)
}

# csp_properties_tbl <- readRDS(".\\src\\objects\\csp_properties_plexos_tbl.rds")
# csp_timeseries_tbl <- readRDS(".\\src\\objects\\csp_clusters_ninja_tbl.rds")
# 
# # nodes = c("EU-ESP", "AF-MAR")
# # aggregated_csp_tbl <- aggregateStorageTimeSeries(nodes, csp_properties_tbl, csp_timeseries_tbl)
# # print(aggregated_csp_tbl)
# 
# aggregated_csp_tbl <- aggregateStorageTimeSeries(all_deane_nodes_lst, csp_properties_tbl, csp_timeseries_tbl)
# saveRDS(aggregated_csp_tbl, file = ".\\src\\objects\\csp_aggregated_ninja_tbl.rds")
# aggregated_csp_tbl <- readRDS(".\\src\\objects\\csp_aggregated_ninja_tbl.rds")
# print(aggregated_csp_tbl)


# csp_timeseries <- readRDS(".\\src\\objects\\csp_clusters_ninja_tbl.rds")

### Plein de ressources pour implémenter CSP proprement avec stockage + timeseries apports
# mais pour l'instant... hm..
# Ptn la timeseries Ninja c'est des entiers et les apports sur Antares sont limités aux entiers mdr
# c'est quoi ce truc de fou furieux

# Est-ce que par exemple vu le fonctionnement on peut prendre "max_volume" en stock,
# et nominal_capacity en injection, mais pas en soutirage ? Vu que ça dépend du soleil
# et c'est que les apports qui... apportent
# Bon allez on va dire que c'est Other4 les CSP haha

addCSPToAntares <- function(nodes 
                            #all_csp_tbl = csp
                            ) {
  
  
}
  
  # for (row in 1:nrow(csp_tbl)) {
  #   csp_tbl <- getCSPFromNodes(nodes)
  #   node = csp_tbl$node[row]
  #   cluster_type = "Other4"
  #   max_storage_capacity = csp_tbl$max_volume[row]
    
    ## cf discussions riches avec jean yves et nicolas sur teams :
    ## comment modéliser tous ces aspects des CSP ?
    
    ## et euh faire une petite enquête sur le solaire : que représentent les
    # TS Ninja CSP, les TS Ninja qu'on a vu dans le PV mais qu'on a reconnu comme CSP ?
    # sont-elles corrélées ? y a-t-il du double comptage ? (pas sur mon code en tout cas)
    
    # peut-être que les PV produisent à l'instant comme dans le ninja PV
    # (et dans ce cas là j'ai bien fait de récupérer la capacité nominale
    # (même s'il y aura écrit Sol et pas Csp dans la ligne trop rleou)
    # ET le Storage repérsente bah le stock
    
    # max_power = batteries_tbl$max_power[row]
    # initial_state = 0
    
  }

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