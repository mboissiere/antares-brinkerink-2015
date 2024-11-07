preprocessPlexosData_module = file.path("src", "antaresCreateStudy_aux", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

# source(".\\src\\objects\\r_objects.R")
#source("parameters.R")


library(tidyr)

# print(full_2015_batteries_tbl)

generateBatteriesTable <- function(nodes = deane_all_nodes_lst) {
  batteries_tbl <- getTableFromPlexos(PLEXOS_OBJECTS_PATH) %>%
    # Initialization of batteries table with only generator names and continent of origin
    filter(class == "Battery") %>%
    select(name, category) %>%
    rename(battery_name = name,
           continent = category)
  
  # print(batteries_tbl)
  
  # Adding country/node info to each battery
  batteries_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Battery" & child_class == "Node") %>%
    rename(battery_name = parent_object,
           node = child_object) %>%
    mutate(node = tolower(node)) %>%
    left_join(batteries_tbl, by = "battery_name")
  
  # No need for mutating the battery names to uppercase, because no Ninja dataset.
  
  batteries_tbl <- batteries_tbl %>%
    select(battery_name, continent, node)
  
  battery_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Batteries") %>% #& scenario == "{Object}Include All Storage") %>%
    # No bueno, le include all storage est que sur units et du coup ça fait disparaitre le reste
    # Mais comment sélectionner le bon units du coup...
    filter(!(property == "Units" & scenario != "{Object}Include All Storage")) %>%
    # Bien, mais ça suffit pas : il y a une duplication sur "Max Power" là où
    # il y a à la fois includePHS et include all storage
    # le plus simple est de virer les include PHS (même si ça veut pas dire qu'on
    # exclut les PHS, ça vaut bien de le rendre clair ptet)
    filter(!(property == "Max Power" & scenario == "{Object}Include PHS")) %>%
    rename(battery_name = child_object)
  
  batteries_tbl <- batteries_tbl %>%
    left_join(battery_properties_tbl, by = "battery_name") %>%
    select(battery_name, continent, node, property, value)
  
  batteries_tbl <- batteries_tbl %>%
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(
      units = Units,
      #capacity = 1000 * `Capacity`,
      capacity = Capacity,
      max_power = `Max Power`,
      initial_state = `Initial SoC`,
      efficiency = `Charge Efficiency`
    )
  # In supplementary material, capacity is actually written to be in GWh !
  # Though I should try to produce a document to double check.
  # Edit : no, not in PLEXOS documentation.
  
  full_2015_batteries_tbl <- batteries_tbl
  # print(full_2015_batteries_tbl)
  
  # Note : I might have to manually make categories for THE, CHE, PHS etc etc...
  # Oh wait, there it is actually, since I want to filter by PHS
  
  # Define a function to extract the middle string from the battery_name
  extract_middle_string <- function(battery_name) {
    return(substr(battery_name, 5, 7))
  }
  
  # Add the battery_group column to the tibble
  full_2015_batteries_tbl <- full_2015_batteries_tbl %>%
    mutate(battery_group = case_when(
      extract_middle_string(battery_name) == "CHE" ~ "Chemical Battery",
      extract_middle_string(battery_name) == "THE" ~ "Thermal",
      extract_middle_string(battery_name) == "PHS" ~ "Pumped Hydro Storage",
      extract_middle_string(battery_name) == "HYD" ~ "Hydrogen",
      extract_middle_string(battery_name) == "CAE" ~ "Compressed Air Energy",
      TRUE ~ NA_character_ # In case there are other types not listed
    )) %>%
    select(battery_name, continent, node, battery_group, units, capacity, max_power, initial_state, efficiency)
  
  # This is the part where we add Antares cluster types and it's just gonna be "Other" a bunch
  # Also, we have no way of getting intakes, so all "open-loop" PHS
  # will just be taken as closed-loop
  full_2015_batteries_tbl <- full_2015_batteries_tbl %>%
    mutate(antares_cluster_type = case_when(
      battery_group == "Pumped Hydro Storage" ~ "PSP_closed",
      battery_group == "Chemical Battery" ~ "Battery",
      battery_group == "Thermal" ~ "Other1",
      battery_group == "Hydrogen" ~ "Other2",
      battery_group == "Compressed Air Energy" ~ "Other3",
      TRUE ~ NA_character_ # In case there are other types not listed
    )) %>%
    select(battery_name, continent, node, battery_group, antares_cluster_type, units, capacity, max_power, initial_state, efficiency) %>%
    filter(node %in% nodes)
  
  return(full_2015_batteries_tbl)
}



library("data.table")

addBatteriesToAntares <- function(batteries_tbl) {
  
  for (row in 1:nrow(batteries_tbl)) {
    
    node = batteries_tbl$node[row]
    cluster_type = batteries_tbl$antares_cluster_type[row]
    
    units = batteries_tbl$units[row]
    # à partir de là vu qu'il y a pas de "units" je peux faire plusieurs approches
    # que je peux mettre en paramètre.
    # soit : for k in units, créer une batterie que je nomme _k
    # soit, faire max_power x units
    # (et soit, agréger encore plus)
    capacity = batteries_tbl$capacity[row]
    
    max_power = batteries_tbl$max_power[row]
    initial_state = batteries_tbl$initial_state[row]
    efficiency = batteries_tbl$efficiency[row]
    # storage_parameters_list = list("injectionnominalcapacity" = max_power,
    #                           "withdrawalnominalcapacity" = max_power,
    #                           "reservoircapacity" = capacity,
    #                           "efficiency" = efficiency,
    #                           "initiallevel" = initial_state,
    #                           "initialleveloptim" = FALSE)
    storage_parameters_list <- storage_values_default()
    storage_parameters_list$injectionnominalcapacity <- max_power
    storage_parameters_list$withdrawalnominalcapacity <- max_power
    # Petit piège : "injection" c'est pompage parce que c'est du POV de
    # la batterie
    storage_parameters_list$reservoircapacity <- capacity
    storage_parameters_list$efficiency <- efficiency/100
    storage_parameters_list$initiallevel <- initial_state/100
    storage_parameters_list$initialleveloptim <- FALSE
    
    
    #storage_parameters <- as.data.table(storage_parameters_list)
    
    for (k in 1:units) {
      battery_name = paste0(batteries_tbl$battery_name[row], "_", k)
      
      # print(node)
      # print(battery_name)
      # print(cluster_type)
      # print(storage_parameters_list)
      # print(as.matrix(storage_parameters_list))
      # print(as.data.table(as.matrix(storage_parameters_list)))
      
      tryCatch({
        createClusterST(
          area = node,
          #cluster_name = battery_name,
          cluster_name = battery_name,
          group = cluster_type,
          storage_parameters = storage_parameters_list,
          
          PMAX_injection = hourly_ones_datatable,
          PMAX_withdrawal = hourly_ones_datatable,
          inflows = hourly_zeros_datatable,
          lower_rule_curve = hourly_zeros_datatable,
          upper_rule_curve = hourly_ones_datatable,
          overwrite = TRUE,
          
          add_prefix = FALSE
        )
        msg = paste("[BATTERY] - Adding", battery_name, "battery to", node, "node...")
        logFull(msg)
      }, error = function(e) {
        msg = paste("[WARN] - Failed to add", battery_name, "battery to", node, "node, skipping...")
        # Tiens, possible qu'à des endroit j'ai mis WARN et d'autres THERMAL/etc
        logError(msg)
      })
     
    }
  }
}

addBatteriesToAntaresAggregated <- function(batteries_tbl) {
  
  for (row in 1:nrow(batteries_tbl)) {
    battery_name = batteries_tbl$battery_name[row]
    node = batteries_tbl$node[row]
    cluster_type = batteries_tbl$antares_cluster_type[row]
    
    units = batteries_tbl$units[row]
    max_power = batteries_tbl$max_power[row]
    capacity = batteries_tbl$capacity[row]
    
    nominal_capacity = max_power * units
    reservoir_capacity = capacity * units
    
    initial_state = batteries_tbl$initial_state[row]
    efficiency = batteries_tbl$efficiency[row]
    
    storage_parameters_list <- storage_values_default()
    storage_parameters_list$injectionnominalcapacity <- nominal_capacity
    storage_parameters_list$withdrawalnominalcapacity <- nominal_capacity
    storage_parameters_list$reservoircapacity <- reservoir_capacity
    storage_parameters_list$efficiency <- efficiency/100
    storage_parameters_list$initiallevel <- initial_state/100
    storage_parameters_list$initialleveloptim <- FALSE
    tryCatch({
      createClusterST(
        area = node,
        cluster_name = battery_name,
        group = cluster_type,
        storage_parameters = storage_parameters_list,
        
        PMAX_injection = hourly_ones_datatable,
        PMAX_withdrawal = hourly_ones_datatable,
        inflows = hourly_zeros_datatable,
        lower_rule_curve = hourly_zeros_datatable,
        upper_rule_curve = hourly_ones_datatable,
        overwrite = TRUE,
        add_prefix = FALSE
      )
      msg = paste("[BATTERY] - Adding", battery_name, "battery to", node, "node...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Failed to add", battery_name, "battery to", node, "node, skipping...")
      logError(msg)
    })
  }
}

# INFO [2024-08-08 13:55:10] [MAIN] - Starting simulation__2024_08_08_13_55_10 simulation...
# WARNING: All log messages before absl::InitializeLog() is called are written to STDERR
# W0000 00:00:1723118110.813430   11744 environment.cc:195] Environment variable XPRESSDIR undefined.
# W0000 00:00:1723118110.813731   11744 environment.cc:261] NOT_FOUND: Could not find the Xpress shared library. Looked in: [C:\xpressmp\bin\xprs.dll', 'C:\Program Files\xpressmp\bin\xprs.dll]. Please check environment variable XPRESSDIR
# 
# [2024-08-08 13:55:33][solver][warns] I/O error: Maximum path length limitation (> 256 characters)
# [2024-08-08 13:55:33][solver][warns] I/O error: Maximum path length limitation (> 256 characters)
# [2024-08-08 13:55:33][solver][warns] I/O error: Maximum path length limitation (> 256 characters)
# 
# lmao what


# 
# Group: 'Other 2' is not a valid name recognized by Antares, you should be using one of: PSP_open, PSP_closed, Pondage, Battery, Other1, Other2, Other3, Other4, Other5
# 17: No cluster description available.
# 18: In createClusterST(area = node, cluster_name = battery_name,  ... :
#                          Group: 'PSP Closed' is not a valid name recognized by Antares, you should be using one of: PSP_open, PSP_closed, Pondage, Battery, Other1, Other2, Other3, Other4, Other5
#                        19: No cluster description available.
#                        
# maaais décidez vous mdr

# Et failed to add les batteries Battery aussi zut

# le warning c'est No cluster description available.
# peut-être que c'est une histoire de limite de caractères ? typiquement mon CSV a exporté en FRA_PHS_SuperBissortePu393
# à vvérifier sur antares web en vrai mais eh
# nop c'est pas ça, manuellement c'est ok