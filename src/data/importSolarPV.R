########## IMPORTS ##########

preprocessNinjaData_module = file.path("src", "data", "preprocessNinjaData.R")
source(preprocessNinjaData_module)
library(tidyr)

# Copié collé de importWind, à modifier

getSolarPVPropertiesTable <- function(generators_tbl) {
  
  solar_pv_generators_tbl <- generators_tbl %>%
    filter(cluster_type == "Solar PV")
  
  properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(property %in% c("Max Capacity", "Units")) %>%
    rename(generator_name = child_object) %>%
    mutate(generator_name = toupper(generator_name)) %>%
    select(generator_name, property, value)
  
  solar_pv_properties_tbl <- solar_pv_generators_tbl %>%
    left_join(properties_tbl, by = "generator_name") %>%
    pivot_wider(names_from = property, values_from = value) %>%
    rename(
      nominal_capacity = "Max Capacity",
      units = Units
    ) %>%
    select(generator_name, node, cluster_type, nominal_capacity, units)
  
  return(solar_pv_properties_tbl)
}


addAggregatedSolarPV <- function(nodes,
                                generators_tbl
                                ) {
  tryCatch({
    # solar_pv_generators_tbl <- getSolarPVPropertiesTable(generators_tbl)
    # solar_pv_aggregated_TS <- aggregateGeneratorTimeSeries(solar_pv_generators_tbl, PV_DATA_PATH)
    
    solar_aggregated_file <- ".\\src\\objects\\solar_aggregated_ninja_tbl.rds"
    solar_aggregated_TS <- readRDS(solar_aggregated_file)
    
    for (node in nodes) {
      solar_ts <- solar_aggregated_TS[[node]]
      tryCatch({
        writeInputTS(
          data = solar_ts,
          type = "solar",
          area = node
        )
        msg = paste("[SOLAR] - Adding", node, "aggregated solar data...")
        logFull(msg)
      }, error = function(e) {
        msg = paste("[WARN] - Skipped adding solar data for", node, "(no generators found in PLEXOS).")
        logError(msg)
      }
      
      )
    }
  }, error = function(e){
    msg = paste("[WARN] - Skipped adding solar PV data for all nodes (no generators found in PLEXOS).")
    logError(msg)
  }
  )
}