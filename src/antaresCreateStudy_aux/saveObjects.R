# En fait on va faire un output folder dès la phase de création d'étude.

STUDY_DATA_FOLDER_NAME = "Antares input - Study data"
SIMUS_DATA_FOLDER_NAME = "Antares output - Simulations data"

initializeOutputFolderStudy <- function(study_name = IMPORT_STUDY_NAME) {
  folder_dir <- paste0("./output/results_", 
                      study_name)
  
  # output_dir <- truncateString(output_dir, 75) # temp number for testing
  # Can actually be too long for Windows. Maximum is 260, we should find what the max file is.
  
  if (!dir.exists(folder_dir)) {
    dir.create(folder_dir)
  }
  
  study_input_dir <- file.path(folder_dir, STUDY_DATA_FOLDER_NAME)
  if (!dir.exists(study_input_dir)) {
    dir.create(study_input_dir)
  }
  
  simus_output_dir <- file.path(folder_dir, SIMUS_DATA_FOLDER_NAME)
  if (!dir.exists(simus_output_dir)) {
    dir.create(simus_output_dir)
  }
  
  return(folder_dir)
}

##############

# source("architecture.R")
# source("parameters.R")
source(".\\src\\antaresCreateStudy_aux\\generateObjects.R") # Provisoire pour le test ?
# library(dplyr)
# library(tidyr)

# wind_2015_properties_tbl <- readRDS(wind_2015_properties_path)
# wind_cf_ts_tbl <- readRDS(wind_cf_ts_path)
# print(wind_2015_properties_tbl)
# print(wind_cf_ts_tbl)
# # ah mais faut filtrer pour les trucs qui pop ici...
# # sinon y a énoooormément de colonnes inutiles
# solarpv_2015_properties_tbl <- readRDS(solarpv_2015_properties_path)
# solarpv_cf_ts_tbl <- readRDS(solarpv_cf_ts_path)
# print(solarpv_2015_properties_tbl)
# print(solarpv_cf_ts_tbl)
# Avec cette histoire de filtrer dans la boucle pour garder les NA, on perd un peu
# la vérification exacte de vraiment prendre Le Tableau Qui Va Etre Parsé Dans La Fonction
# ce qui peut poser des problèmes si on ne surveille pas de près cette fonction plus tard... Attention.

saveAggregatedWindTable <- function(nodes, #properties_tbl, cf_ts_tbl, 
                                    folder_dir) {
  wind_2015_aggregated_tbl <- getAggregatedTSFromClusters(nodes,
                                                          wind_2015_properties_tbl,
                                                          wind_cf_ts_tbl)
  # Attention c'est pas dépendant de l'année alors que !!! en fait globalement c'est le bordel !!!
  # c'est pas le but de cette fonction de nommer l'année je pense !! si ??
  wind_2015_aggregated_name <- "wind_aggregated_2015.csv"
  wind_2015_aggregated_path <- file.path(folder_dir, wind_2015_aggregated_name)
  
  write.table(wind_2015_aggregated_tbl, 
              file = wind_2015_aggregated_path,
              sep = ";",
              dec = ",",
              col.names = TRUE,
              row.names = FALSE
              )
}

# saveRenewablesTables <- function(nodes, base_properties_tbl, folder_dir) {
#   properties_tbl <- base_properties_tbl %>%
#     filter(active_in_2015 & node %in% nodes) %>%
#     # select(generator_name, node, nominal_capacity, nb_units)
#     
#     # renewables_properties_name <- ""
#     # renewables_properties_path <- file.path(folder_dir, renewables_properties_name)
#     ## euh non, c'est après aggrégation qu'il faudrait sauvegarder le délire, non ?
#     
#     write.table(file =)
#   # Ce serait bien de configurer si on veut l'écriture avec ; en sep et , en dec
#   # ou bien avec , en sep et . en dec
#   
#   print(aggregated_tbl)
# }

# study_name <- # Provisoire, pour test

# saveAggregatedRenewablesTable(deane_europe_nodes_lst, wind_2015_properties_tbl)
# saveAggregatedRenewablesTable(deane_europe_nodes_lst, solarpv_2015_properties_tbl)

