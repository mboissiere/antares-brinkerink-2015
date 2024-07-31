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
                                generators_tbl,
                                log_verbose,
                                console_verbose,
                                fullLog_file,
                                errorsLog_file
) {
  tryCatch({
    
    solar_pv_generators_tbl <- getSolarPVPropertiesTable(generators_tbl)
    solar_pv_aggregated_TS <- aggregateGeneratorTimeSeries(solar_pv_generators_tbl, PV_DATA_PATH)
    
    for (node in nodes) {
      solar_pv_ts <- solar_pv_aggregated_TS[[node]]
      tryCatch({
        if (log_verbose) {
          message = paste(Sys.time(),"- [SOLAR] Adding", node, "solar PV data...\n")
          log_message(message, fullLog_file, console_verbose)
        }
        writeInputTS(
          data = solar_pv_ts,
          type = "solar",
          area = node
        )
      }, error = function(e) {
        if (log_verbose) {
          error_message = paste(Sys.time(), "- [WARNING] Failed to add solar PV data to", node, "(no generators found in PLEXOS dataset), skipping...\n")
          log_message(error_message, fullLog_file, console_verbose)
          log_message(error_message, errorsLog_file, FALSE)
        }
      }
      
      )
    }
  }, error = function(e){
    warn_message = paste(Sys.time(), "- [WARNING] Generation of all solar PV data failed (no generators found in PLEXOS dataset), skipping...\n")
    log_message(warn_message, fullLog_file, console_verbose)
    log_message(warn_message, errorsLog_file, FALSE)
  }
  )
}