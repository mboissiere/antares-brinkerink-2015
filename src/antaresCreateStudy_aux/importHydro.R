preprocessPlexosData_module = file.path("src", "antaresCreateStudy_aux", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source(".\\src\\objects\\r_objects.R")

library(tidyr)

# print(full_2015_generators_tbl)

# generators_tbl <- full_2015_generators_tbl %>%
#   filter(fuel_type == "Hydro")

getHydroGeneratorsProperties <- function() {
  hydro_generators_tbl <- base_generators_properties_tbl %>%
    filter(plexos_fuel_type == "Hydro") %>%
    select(generator_name, node)
  
  hydro_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Generators") %>%
    mutate(generator_name = tolower(child_object)) %>%
    select(generator_name, property, value)
  
  hydro_generators_tbl <- hydro_generators_tbl %>%
    left_join(hydro_properties_tbl, by = "generator_name") %>%
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(nominal_capacity = `Max Capacity` * Units) %>%
    select(generator_name, node, nominal_capacity, `Max Capacity`, Units)
  
  hydro_generators_tbl <- hydro_generators_tbl %>%
    select(generator_name, node, nominal_capacity)
  
  return(hydro_generators_tbl)
}

####################

# hydro_countries_2015 <- readRDS(".\\src\\objects\\hydro_monthly_production_countries_2015_tbl.rds")
# print(hydro_countries_2015)

# initializeHydro <- function(nodes) {
#   list_params = list("intra-daily-modulation" = 2) # Let's assume that by default the rest is ok
#   #print(list_params)
#   for (node in nodes) {
#     writeIniHydro(area = node,
#                   params = list_params
#                   )
#   }
#   
# }

source(".\\src\\utils\\timeSeriesConversion.R")
library("data.table")

addHydroStorageToAntares <- function(nodes) {
  msg = "[MAIN] - Beginning hydro implementation..."
  logMain(msg)
  hydro_countries_2015 <- readRDS(".\\src\\objects\\hydro_monthly_production_countries_2015_tbl.rds")
  
  hydro_countries_2015 <- hydro_countries_2015 %>%
    mutate(node = tolower(node)) %>%
    filter(node %in% nodes)
  
  for (row in 1:nrow(hydro_countries_2015)) {
    #row = 1
    node_info <- hydro_countries_2015[row,]
    
    node <- node_info$node
    #print(node)
    
    hydro_capacity <- node_info$total_nominal_capacity
    max_power_matrix = as.data.table(matrix(c(hydro_capacity, 24, 0, 24), ncol = 4, nrow = 365, byrow = TRUE))
    
    #max_power_matrix = matrix(c(10000, 24, 0, 24), ncol = 4, nrow = 365, byrow = TRUE)
    #print(max_power_matrix)
    list_params = list("inter-daily-breakdown" = 2)
    
    tryCatch({
      writeIniHydro(area = node,
                    params = list_params
      )
      msg = paste("[HYDRO] - Initializing", node, "hydro parameters...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[HYDRO] - Couldn't initialize", node, "hydro parameters, skipping...")
      logError(msg)
    })
    tryCatch({
      writeHydroValues(
        area = node,
        type = "maxpower",
        data = max_power_matrix,
        overwrite = TRUE
      )
      msg = paste("[HYDRO] - Adding", node, "max power timeseries...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[HYDRO] - Couldn't add", node, "max power timeseries, skipping...")
      logError(msg)
    })
    
    
    #print(reservoir_capacity)
    
    monthly_tbl <- node_info %>%
      select(starts_with("M"))
    
    #print(monthly_tbl)
    # Extract the values into a simple vector
    monthly_ts <- unlist(monthly_tbl, use.names = FALSE)
    #print(monthly_ts)
    
    daily_ts <- monthly_to_daily(monthly_ts, 2015)
    #print(daily_ts)
    tryCatch({
      writeInputTS(
        daily_ts,
        type = "hydroSTOR",
        area = node
      )
      msg = paste("[HYDRO] - Adding", node, "hydro profiles...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[HYDRO] - Couldn't add", node, "hydro profiles, skipping...")
      logError(msg)
    })
    
    
  }
  msg = "[MAIN] - Done adding hydro!"
  logMain(msg)
}


# print(hydro_countries_2015)
# 
# test_2015 <- 
# 
# addHydroStorageToAntares("EU-FRA")

###################


# hydro_generators_tbl <- getHydroGeneratorsProperties()
# print(hydro_generators_tbl)
# saveRDS(hydro_generators_tbl, file = ".\\src\\objects\\hydro_nominal_capacities_2015.rds")
# 
# ###################
# 
# hydro_tbl <- readRDS(file = ".\\src\\objects\\hydro_daily_capacity_factors_2015.rds")
# print(hydro_tbl)

##################

# for (row in 1:nrow(hydro_generators_tbl)) {
#   
# }

##################

# Ah mais en vrai on va effectivement sommer par pays. 
# Et puis lire les monthly de Ninja en en faisant de l'horaire.
# Il faudrait d'ailleurs demander aux auteurs de Deane : dans les simus qui
# ont donné leurs graphiques, ont-ils utilisé 2015 ou 15 year average pour l'hydro.


