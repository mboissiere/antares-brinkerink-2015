########## IMPORTS ##########

preprocessNinjaData_module = file.path("src", "data", "preprocessNinjaData.R")
source(preprocessNinjaData_module)
library(tidyr)

# source("properties.R")

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


addAggregatedSolar <- function(nodes,
                               generators_tbl,
                               add_csp #= IMPORT_CSP # default value AND adding in main
                               # isn't that a bit much ? maybe no default value is best idk
                                ) {
  tryCatch({
    # solar_pv_generators_tbl <- getSolarPVPropertiesTable(generators_tbl)
    # solar_pv_aggregated_TS <- aggregateGeneratorTimeSeries(solar_pv_generators_tbl, PV_DATA_PATH)
    
    solar_aggregated_file <- ".\\src\\objects\\solar_aggregated_ninja_tbl.rds"
    solar_aggregated_TS <- readRDS(solar_aggregated_file)
    # print(solar_aggregated_TS) # ok phew its the production, if it was capacity factors i woulda died
    
    # add_csp = TRUE
    # 
    if (add_csp) {
      csp_aggregated_file <- ".\\src\\objects\\csp_aggregated_ninja_tbl.rds"
      csp_aggregated_TS <- readRDS(csp_aggregated_file)
      # print(csp_aggregated_TS)
      
      # Ensure that the column names in both tibbles are identical except for DATETIME
      csp_columns <- setdiff(colnames(csp_aggregated_TS), "DATETIME")
      # for (col in csp_columns) {
      # #   print(col)
      # # }
      # col = "AF-DZA"
      # print(solar_aggregated_TS[[col]])
      # print(csp_aggregated_TS[[col]])
      # print(solar_aggregated_TS[[col]] + csp_aggregated_TS[[col]])
      
      # Iterate over each column in CSP and add it to the corresponding column in Solar
      for (col in csp_columns) {
        # msgTest = paste("Now working on column:", col)
        # # Crazy how I always have spicy stuff
        # print(msgTest)
        # # Add CSP column to the corresponding Solar column
        # all_solar_ts = solar_aggregated_TS[[col]] + csp_aggregated_TS[[col]]
        # solar_aggregated_TS[[col]] <- all_solar_ts
        # 
        # msgTest = paste("All good for column", col)
        # # Oh it's AF-MAR. Yeah there isn't PV in AF-MAR oops.
        # # Was sloppy of me to not include an existence check anyway.
        # # I remember I was much more rigid back in the day lmao
        # msgTest = paste("Now working on column:", col)
        # # Crazy how I always have spicy stuff
        # print(msgTest)
        if (col %in% colnames(solar_aggregated_TS)) {
          # If column exists in solar_aggregated_TS, add the values
          solar_aggregated_TS[[col]] <- solar_aggregated_TS[[col]] + csp_aggregated_TS[[col]]
        } else {
          # If column does not exist in solar_aggregated_TS, add it as a new column
          solar_aggregated_TS[[col]] <- csp_aggregated_TS[[col]]
        # }
        # msgTest = paste("All good for column", col)
        # print(msgTest)
        }
        }
      
      # The solar_aggregated_TS now contains the summed values
      # print(solar_aggregated_TS)
    }
    
    for (node in nodes) {
      solar_ts <- solar_aggregated_TS[[node]]
      # Best way to check if my new feature works correctly : Morocco :)
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
    msg = paste("[WARN] - Skipped adding solar data for all nodes (no generators found in PLEXOS).")
    logError(msg)
  }
  )
}