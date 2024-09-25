########## IMPORTS ##########

library(dplyr) # To be commented if the main script has that

########## PARAMETERS ##########

NINJA_PATH = file.path(".", "input", "dataverse_files")

WIND_DATA_PATH = file.path(NINJA_PATH, "Renewables.ninja.wind.output.Full.adjusted.txt")
# WIND_DATA_PATH = file.path(NINJA_PATH, "Renewables.ninja.wind.output.Full.txt")
SOLARPV_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Solar.farms.output.full.adjusted.txt")
# SOLARPV_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Solar.farms.output.full.txt")
CSP_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Csp.output.full.adjusted.txt")
# c'est vrai qu'on a toujours pas le CSP intégré dans le mode clusters,
# ni en mode batteries

# Et un ptit print de log main "preprocessing Wind data..." pour faire patienter l'utilisateur, en vrai.
# datetime - [CATEGORY] machin c'est la meilleure nomenclature en vrai

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

# # 
# > if (GENERATE_WIND) {
#   +   if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
#     +     importWind_module = file.path("src", "data", "importWind.R")
#     +     source(importWind_module)
#     +     addAggregatedWind(nodes, generators_tbl, log_verbose, console_verbose, fullLog_file, errorsLog_file)
#     +     message = paste(Sys.time(), "[MAIN] Added wind !")
#     +     log_message(message, fullLog_file, console_verbose)
#     +   }
#   + }
# Error in `rename()`:
#   ! Can't rename columns that don't exist.
# x Column `Max Capacity` doesn't exist.
# Run `rlang::last_trace()` to see where the error occurred.
# > 
# 
# > if (GENERATE_SOLAR_PV) {
#   +   if (RENEWABLE_GENERATION_MODELLING == "aggregated") {
#     +     importSolarPV_module = file.path("src", "data", "importSolarPV.R")
#     +     source(importSolarPV_module)
#     +     addAggregatedSolarPV(nodes, generators_tbl, log_verbose, console_verbose, fullLog_file, errorsLog_file)
#     +     message = paste(Sys.time(), "[MAIN] Added solar PV !")
#     +     log_message(message, fullLog_file, console_verbose)
#     +   }
#   + }
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
  
  # # for temporary testing
  # nodes_tbl <- getNodesTable(getAllNodes())
  # generators_tbl <- getGeneratorsFromNodes(nodes_tbl)
  # generators_tbl <- addGeneralFuelInfo(generators_tbl)
  # # C'est tellement clair comme code que je me suis trompé 5 fois avant de l'avoir..
  # # pourrait servir : un FullyInitialize qui combine les deux mais bon bref
  # timeseries_data_path <- WIND_DATA_PATH
  # source(".\\src\\data\\importWind.R")
  # generators_tbl <- getWindPropertiesTable(generators_tbl)
  
  
  # Au passage, si on est dans aggregate, osef des clusters du coup
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
    # Encore plus de robustesse impliquerait de faire de "generator_name" des variables GLOBALES
    # dont on vérifierait le postprocessing, mais là j'y vais un peu fort sur les mouches
    left_join(generators_tbl, by = "generator_name") %>%
    # Ptet que le pb est là, et qu'il faudrait filtrer avant un left join ?
    # Ca me donne moins de NA mais j'ai toujours 8759 lignes au lieu de 8760...
    filter(node %in% nodes_studied)
  
  # 
  # print(product_tbl)
  # 
  product_tbl <- product_tbl %>%
    mutate(power_output = units * nominal_capacity * capacity_factor / 100)
  
  product_tbl <- product_tbl %>%
    # Après tout, pourquoi pas ?
    # Quoique... Est-ce que y a pas un truc dans tibble qui va enlever les duplicates ?
    # Si jamais deux jours il y a exactement la même production,pas forcément la même centrale ou quoi.
    select(DATETIME, node, power_output)
  
  # print(product_tbl)
  
  # print(product_tbl)
  # last_row <- product_tbl %>% slice(n())
  # print(last_row)
  
  
  # # Sum/group by country
  # aggregated_tbl <- product_tbl %>%
  #   group_by(DATETIME, node) %>%
  #   mutate(node_power_output = sum(power_output))
  # #%>%
  #   # mutate(node_power_output)
  #   # # summarize(total_power_output = sum(power_output,
  #   # #                                    na.rm = FALSE)) %>%
  #   # #   ungroup()
  #   #                                    # Si y a pas de bug ça veut dire y a pas de NA
  #   #                                    #na.rm = TRUE # mais en vrai j'hésite à remettre cette ligne
  #   # # Ce serait pas mal de faire des sortes de tests unitaires genre a-t-on bien 8760 lignes
  #   # # C'est fou qu'une fois que j'ai commencé à faire ça j'aie eu des pb
  #   # 
  #   # # ungroup()
  #   # 
  # print(aggregated_tbl, n = 8761)
  
  # C'est toujours à partir de là que ça capote.
  aggregated_tbl <- product_tbl %>%
    group_by(DATETIME, node) %>%
    summarize(node_power_output = sum(power_output, na.rm = FALSE), .groups = 'drop')
    #ungroup() %>%
  # print(aggregated_tbl)
  # 
  # last_row <- aggregated_tbl %>% slice(n())
  # print(last_row)
  # 
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
