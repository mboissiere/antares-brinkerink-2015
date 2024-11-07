########## IMPORTS ##########

library(dplyr) # To be commented if the main script has that

########## PARAMETERS ##########

NINJA_PATH = file.path(".", "input", "dataverse_files")

WIND_DATA_PATH = file.path(NINJA_PATH, "Renewables.ninja.wind.output.Full.adjusted.txt")
# WIND_DATA_PATH = file.path(NINJA_PATH, "Renewables.ninja.wind.output.Full.txt")
SOLARPV_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Solar.farms.output.full.adjusted.txt")
# SOLARPV_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Solar.farms.output.full.txt")
CSP_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Csp.output.full.adjusted.txt")


########## FUNCTIONS ##########

getTableFromNinja <- function(ninja_data_path) {
  tbl <- read.table(ninja_data_path,
                    header = TRUE,
                    sep = ",",
                    stringsAsFactors = FALSE,
                    encoding = "UTF-8",
                    check.names = FALSE
  )
  # Forcing column names to lowercase to avoid discrepancies with PLEXOS dataset
  names(tbl) <- tolower(names(tbl))
  
  # Removing potential duplicates
  duplicate_columns <- which(duplicated(names(tbl)))
  if (length(duplicate_columns) > 0) {
    duplicate_column_names <- names(tbl)[duplicate_columns]
    msg = paste("[WARN] - The following columns were found as duplicates in input data:", 
                paste(duplicate_column_names, collapse = ", "))
    logError(msg)
    logError("[WARN] - Duplicates have been removed in import.")
    tbl <- tbl[, -duplicate_columns]
  }
  tbl <- as_tibble(tbl)
  return(tbl)
}


# Curiosité, pour certaines nodes problématiques, pas l'air d'être dans PLEXOS
# 
# 
# 2024-07-11 10:42:05 - ERROR: attempted to add wind data to node EU-MDA but failed, skipping...
# 
# 2024-07-11 10:42:05 - ERROR: attempted to add wind data to node EU-MKD but failed, skipping...
# 
# 2024-07-11 10:42:05 - ERROR: attempted to add wind data to node EU-MNE but failed, skipping...

# Très curieux, certains capacity scalers... n'existent pas dans PLEXOS.
# Ils existent dans Renewables.ninja, mais pas dans PLEXOS, ce qui signifie qu'il n'existe aucune propriété associée
# (Une capacité, notamment, à partir de laquelle on aurait des facteurs de charge...)
# Mais du coup si vraiment par exemple y a 0 éolienne, ok très bien, mais pourquoi inclure un wind capacity scaler dans les timeseries Ninja ??

# Pour l'instant, ça va bruteforce à coup de relevage d'exception et de warning. Mais tout de même,
# ça vaut le coup de le relever à Deane.

# # A tibble: 1 x 4
# generator_name          node   nominal_capacity units
# <chr>                   <chr>             <dbl> <dbl>
# #   1 MKD_SOL_CAPACITY SCALER EU-MKD               17     1
# 
# 2024-07-11 10:53:03 - Adding EU-MDA solar PV data...
# 2024-07-11 10:53:03 - ERROR: attempted to add solar PV data to node EU-MDA but failed, skipping...
# 2024-07-11 10:53:03 - Adding EU-MKD solar PV data...
# 2024-07-11 10:53:04 - Adding EU-MNE solar PV data...
# 2024-07-11 10:53:04 - ERROR: attempted to add solar PV data to node EU-MNE but failed, skipping...



aggregateGeneratorTimeSeries <- function(generators_tbl, timeseries_data_path) {
  
  generators_tbl <- generators_tbl %>%
  select(generator_name, node, nominal_capacity, units)
  # print(generators_tbl)
  
  nodes_studied <- generators_tbl$node
  
  timeseries_tbl <- getTableFromNinja(timeseries_data_path)
  # print(timeseries_tbl)
  
  product_tbl <- timeseries_tbl %>%
    gather(key = "generator_name", value = "capacity_factor", -DATETIME) 
  
  # print(product_tbl)
  
  product_tbl <- product_tbl %>% 
    left_join(generators_tbl, by = "generator_name") %>%
    filter(node %in% nodes_studied)
  
  # 
  # print(product_tbl)
  # 
  product_tbl <- product_tbl %>%
    mutate(power_output = units * nominal_capacity * capacity_factor / 100)
  
  product_tbl <- product_tbl %>%
    select(DATETIME, node, power_output)
  
  aggregated_tbl <- product_tbl %>%
    group_by(DATETIME, node) %>%
    summarize(node_power_output = sum(power_output, na.rm = FALSE), .groups = 'drop')

  # Artefact utile parce qu'à un moment le CSV de Deane était vraiment erroné :
  # (c'est fix dans le .txt utilisé dans /input/)
  
  # # Verify no missing datetime entries
  # missing_datetimes <- setdiff(seq(as.POSIXct("2015-01-01 00:00"), as.POSIXct("2015-12-31 23:00"), by = "hour"), 
  #                              as.POSIXct(aggregated_tbl$DATETIME, format="%d/%m/%Y %H:%M"))
  # if (length(missing_datetimes) > 0) {
  #   print("Missing datetime entries:")
  #   print(missing_datetimes)
  # }
  # 
  # Convert back to wide format with 8760 rows and one column per node
  aggregated_tbl <- aggregated_tbl %>%
    pivot_wider(names_from = node, values_from = node_power_output)
  
  # print(aggregated_tbl)
  
  return(aggregated_tbl)
}

########## OBJECTS ##########
