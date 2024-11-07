# en l'absence de clarté sur comment ça marche les objets Storage, je vais
# prendre les timeseries de Ninja, et juste les balancer dans la timeseries
# Solaire. peut-être que je pourrai faire mieux à un moment, mais là..
library(dplyr)
library(tidyr)

source(".\\src\\data\\preprocessPlexosData.R")
source(".\\src\\data\\preprocessNinjaData.R")
source(".\\src\\objects\\r_objects.R")



getPropertiesCSP <- function() {
  csp_generators_tbl <- full_2015_generators_tbl %>%
    filter(cluster_type == "Solar Thermal") %>%
    select(generator_name, continent, node)
  
  #print(csp_generators_tbl)
  
  generator_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Generators") %>%
    mutate(generator_name = toupper(child_object)) %>%
    
    filter(scenario != "{Object}Exclude CSP") %>%
    select(generator_name, property, value)
  
  # print(generator_properties_tbl)
    # Obligé de select avant le pivot_wider, sinon les différences dans certaines colonnes
    # comme scenario etc cassent le truc en deux et forcent à faire deux entries
    
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

# Dur, faut refaire la fonction aggregateGeneratorTimeSeries parce que ça parse
# la colonne storage_name et pas generator_name
# si j'étais chaud je ferais une sorte de fonction fils là qui se décline
# mais pas pour l'instant

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



# csp_timeseries <- readRDS(".\\src\\objects\\csp_clusters_ninja_tbl.rds")

### Plein de ressources pour implémenter CSP proprement avec stockage + timeseries apports
# mais pour l'instant... hm..
# Wow la timeseries Ninja c'est des entiers et les apports sur Antares sont limités aux entiers 
# la chance

# Est-ce que par exemple vu le fonctionnement on peut prendre "max_volume" en stock,
# et nominal_capacity en injection, mais pas en soutirage ? Vu que ça dépend du soleil
# et c'est que les apports qui... apportent
# Bon allez on va dire que c'est Other4 les CSP peut etre


# aggregated_csp_tbl <- readRDS(".\\src\\objects\\csp_aggregated_ninja_tbl.rds")
# print(aggregated_csp_tbl)

library(data.table)

addCSPToAntares <- function(nodes
                            ) {
  # A l'ordre 1, donc, on va juste l'ajouter au PV.  
  # Je pense que pour une v2 il faudra un peu faire ça plus proprement.
  # Avec un objet Storage.
  
  # Oh là là ça va être d'une laideur (je vais devoir get le PV / le sommer puis l'ajouter)
  # En fait c'est techniquement pas dur mais l'architecture de mon code fait que
  # c'est horrible.
  # Je crois que je vais faire une modélisation storage et tant pis pour le Pmin.
  
  # nodes = c("EU-ESP", "AF-MAR")
  csp_properties_tbl <- readRDS(".\\src\\objects\\csp_properties_plexos_tbl.rds")
  
  csp_tbl <- csp_properties_tbl %>%
    filter(node %in% nodes)
  
  # print(csp_tbl)
  
  csp_timeseries_tbl <- readRDS(".\\src\\objects\\csp_clusters_ninja_tbl.rds")
  # print(csp_timeseries_tbl)
  
  # tryCatch({
  #   juste regarder si csp_tbl est vide nan ?
  # c'est ptet déjà le cas d'un for vide ?
  # })
  
  
  
  for (row in 1:nrow(csp_tbl)) {
    storage_name = csp_tbl$storage_name[row]
    #print(storage_name)
    node = csp_tbl$node[row]
    max_storage_volume = csp_tbl$max_volume[row]
    nominal_capacity = csp_tbl$nominal_capacity[row]
    
    storage_parameters_list <- storage_values_default()
    # Encore une fois, injection = charge d'après doc
    # en gros on dit ici que le CSP ne se charge pas du réseau, seulement des apports
    
    storage_parameters_list$injectionnominalcapacity <- 0
    storage_parameters_list$withdrawalnominalcapacity <- nominal_capacity
    
    # TEST, A MODIFIER APRES
    # storage_parameters_list$withdrawalnominalcapacity <- 0
    # storage_parameters_list$injectionnominalcapacity <- nominal_capacity
    
    #storage_parameters_list$reservoircapacity <- max_storage_volume * 1000
    # storage_parameters_list$reservoircapacity <- max_storage_volume * 1000000 # test, a vocation à être changé
    # je vois pas comment ça peut être autrement, parce que c'est trop bizarre
    # on a ESP_PLANTASOLARTE qui a 0.0011 de max_volume,
    # mais dans sa timeseries il peut atteindre un apport de 22 ??
    storage_parameters_list$reservoircapacity <- max_storage_volume
    # Nicolas a dit pas multiplier, on multiplie pas
    storage_parameters_list$initiallevel <- 0
    #print(storage_parameters_list)
    # pour le faire proprement il faudrait l'extraire du deane etc ce que j'ai juste zappé.
    # je me souviens que c'est 0.
    
    storage_ts <- csp_timeseries_tbl[[storage_name]]
    if (is.null(storage_ts)) {
      msg = paste("[WARN] - Timeseries for", storage_name, "is null.")
      logError(msg)
    }
    # put a null TS warning
    #print(storage_ts)
    # is_integer_col <- sapply(storage_ts, function(col) all(col == as.integer(col)))
    # print(is_integer_col)
    # perhaps one important thing is for them to be integers ?
    
    storage_ts <- as.data.table(-storage_ts) # et si apports c'était inversé ?
    # ça l'est ! C'est plus des outflows que des inflows ! Mais ça ne résout pas
    # le problème pour autant
    tryCatch({
      createClusterST(
        area = node,
        #cluster_name = battery_name,
        cluster_name = storage_name,
        group = "Other4",
        storage_parameters = storage_parameters_list,
        
        inflows = storage_ts,
        PMAX_injection = hourly_ones_datatable,
        PMAX_withdrawal = hourly_ones_datatable,
        lower_rule_curve = hourly_zeros_datatable, # pmin mayhaps ??
        upper_rule_curve = hourly_ones_datatable,
        #inflows = as.data.table(storage_ts),
        # lower_rule_curve = hourly_zeros_datatable,
        # envisager de mettre min_stable_factor en pourcentage ? pourquoi/pourquoi pas?
        overwrite = TRUE,
        add_prefix = FALSE
      )
      msg = paste("[CSP] - Adding", storage_name, "CSP generator to", node, "node...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Failed to add", storage_name, "CSP generator to", node, "node, skipping...")
      logError(msg)
    })
  }
}
    
    # Erreur incompréhensible.... time to regarder le code source !
    # https://github.com/rte-antares-rpackage/antaresEditObject/blob/c9adc8e13bc2ec238b4a8d7f57afb3531219bbd4/R/createClusterST.R#L77
    