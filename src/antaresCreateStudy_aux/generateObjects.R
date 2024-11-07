source("architecture.R")

deane_all_nodes_name <- "deane_all_nodes_lst.rds"
deane_all_nodes_path <- file.path(OBJECTS_PATH, deane_all_nodes_name)
if (REGENERATE_OBJECTS | !file.exists(deane_all_nodes_path)) {
  source(addNodes_module)
  deane_all_nodes_lst <- getAllNodes()
  # So far, AllNodes isn't tolowered.
  saveRDS(object = deane_all_nodes_lst,
          file = deane_all_nodes_path)
}

deane_all_nodes_lst <- readRDS(deane_all_nodes_path)

deane_europe_nodes_name <- "deane_europe_nodes_lst.rds"
deane_europe_nodes_path <- file.path(OBJECTS_PATH, deane_europe_nodes_name)
if (REGENERATE_OBJECTS | !file.exists(deane_europe_nodes_path)) {
  source(addNodes_module)
  deane_europe_nodes_lst <- getNodesFromContinents("Europe")
  # So far, AllNodes isn't tolowered.
  saveRDS(object = deane_europe_nodes_lst,
          file = deane_europe_nodes_path)
}
deane_europe_nodes_lst <- readRDS(deane_europe_nodes_path)

deane_asia_nodes_name <- "deane_asia_nodes_lst.rds"
deane_asia_nodes_path <- file.path(OBJECTS_PATH, deane_asia_nodes_name)
if (REGENERATE_OBJECTS | !file.exists(deane_asia_nodes_path)) {
  source(addNodes_module)
  deane_asia_nodes_lst <- getNodesFromContinents("Asia")
  # So far, AllNodes isn't tolowered.
  saveRDS(object = deane_asia_nodes_lst,
          file = deane_asia_nodes_path)
}
deane_asia_nodes_lst <- readRDS(deane_asia_nodes_path)





# Great !! We just need to make the generation of objects conditional
# (no need for useless ones) so like, just put it in a generate... function
# and also to put logs so that we have some visibility of it happening.

base_generators_properties_name = "base_generators_properties_tbl.rds"
base_generators_properties_path <- file.path(OBJECTS_PATH, base_generators_properties_name)
if (REGENERATE_OBJECTS | !file.exists(base_generators_properties_path)) {
  source(preprocessPlexosData_module)
  base_generators_properties_tbl <- getGeneratorsFromNodes(deane_all_nodes_lst)
  base_generators_properties_tbl <- addGeneralFuelInfo(base_generators_properties_tbl)
  base_generators_properties_tbl <- getBaseGeneratorData(base_generators_properties_tbl)
  # NB : pas 100% sûr que toutes les colonnes sont utiles, plexos_fuel_type par exemple... On garde au cas où / pour la transparence du join
  # print(base_generators_properties_tbl, n = 200)
  # print(base_generators_tbl %>% filter(node == "as-jpn-ce" & antares_cluster_type == "Nuclear"))
  saveRDS(object = base_generators_properties_tbl,
          file = base_generators_properties_path)
}

# Un approfondissement qui serait bien pour MATER : un "getGeneratorTable" qui prendrait "year" en argument
# et, avec des données de durée de vie des centrales, filtrerait sur "commmission_date" (avec l'exception nucléaire pour 2015)
# tout en virant des centrales trop anciennes.

# Bon, batteries time
# Mais en fait... tout cette phase là on pourrait pas la skip aussi si on n'importe pas les batteries ??
batteries_table_name = "full_2015_batteries_tbl.rds"
batteries_table_path <- file.path(OBJECTS_PATH, batteries_table_name)
if (GENERATE_BATTERIES & (REGENERATE_OBJECTS | !file.exists(batteries_table_path))) {
  source(importBatteries_module)
  full_2015_batteries_tbl <- generateBatteriesTable(deane_all_nodes_lst)
  print("generated abtteries table")
  saveRDS(object = full_2015_batteries_tbl,
          file = batteries_table_path)
}

##

wind_cf_ts_name = "wind_cf_ts_tbl.rds"
wind_cf_ts_path <- file.path(OBJECTS_PATH, wind_cf_ts_name)
if (REGENERATE_OBJECTS | !file.exists(wind_cf_ts_path)) {
  source(preprocessNinjaData_module)
  wind_cf_ts_tbl <- getTableFromNinja(WIND_DATA_PATH)
  # print(wind_cf_ts_tbl)
  saveRDS(object = wind_cf_ts_tbl,
          file = wind_cf_ts_path)
}

solarpv_cf_ts_name = "solarpv_cf_ts_tbl.rds"
solarpv_cf_ts_path <- file.path(OBJECTS_PATH, solarpv_cf_ts_name)
if (REGENERATE_OBJECTS | !file.exists(solarpv_cf_ts_path)) {
  source(preprocessNinjaData_module)
  solarpv_cf_ts_tbl <- getTableFromNinja(SOLARPV_DATA_PATH)
  # print(solarpv_cf_ts_tbl)
  saveRDS(object = solarpv_cf_ts_tbl,
          file = solarpv_cf_ts_path)
}


solarpv_2015_properties_name = "solarpv_2015_properties_tbl.rds"
solarpv_2015_properties_path <- file.path(OBJECTS_PATH, solarpv_2015_properties_name)
if (REGENERATE_OBJECTS | !file.exists(solarpv_2015_properties_path)) {
  solarpv_generators_properties_tbl <- base_generators_properties_tbl %>% filter(antares_cluster_type == "Solar PV")
  # Could be useful to save also
  
  ninja_solarpv_generators_lst <- colnames(solarpv_cf_ts_tbl %>% select(-datetime))
  solarpv_2015_properties_tbl <- tibble(generator_name = ninja_solarpv_generators_lst) %>%
    full_join(solarpv_generators_properties_tbl, by = "generator_name") %>%
    # filter(active_in_2015 == TRUE)
  ## En fait faire ça enlève les NA... garder les NA peut être bien pour les printer.
  
  # print(solarpv_2015_properties_tbl)

    select(generator_name, node, nominal_capacity, nb_units, active_in_2015)
  
  saveRDS(object = solarpv_2015_properties_tbl,
          file = solarpv_2015_properties_path)
}


wind_2015_properties_name = "wind_2015_properties_tbl.rds"
wind_2015_properties_path <- file.path(OBJECTS_PATH, wind_2015_properties_name)
if (REGENERATE_OBJECTS | !file.exists(wind_2015_properties_path)) {
  wind_generators_properties_tbl <- base_generators_properties_tbl %>% filter(plexos_fuel_type == "Wind")
  
  # print(wind_generators_properties_tbl)
  # Could be useful to save also
  
  ninja_wind_generators_lst <- colnames(wind_cf_ts_tbl %>% select(-datetime))
  wind_2015_properties_tbl <- tibble(generator_name = ninja_wind_generators_lst) %>%
    full_join(wind_generators_properties_tbl, by = "generator_name") %>%
    # filter(active_in_2015 == TRUE)
    ## En fait faire ça enlève les NA... garder les NA peut être bien pour les printer.
    
    # print(solarpv_2015_properties_tbl)
    
    select(generator_name, node, nominal_capacity, nb_units, antares_cluster_type, active_in_2015)
  
  saveRDS(object = wind_2015_properties_tbl,
          file = wind_2015_properties_path)
}

###########
# Territory of aggregation

# dans l'utilisation finale, ce serait bien d'avoir en fin de truc genre
# si jamais on importe les objets qui sont déjà crées, un log qui dit
# "importing already existing aggregated ninja table.." machin histoire
# de suivre
# et aussi de log si on crée bien sûr

# print(wind_cf_ts_tbl)
# print(wind_2015_properties_tbl, n = 100)

# wind_ninja_not_in_plexos_lst <- wind_2015_properties_tbl %>%
#   filter(is.na(nominal_capacity)) %>%
#   pull(generator_name)
# 
# # print(wind_ninja_not_in_plexos_lst)

getAggregatedTSFromClusters <- function(nodes, properties_tbl, timeseries_tbl) {
  # Mais il serait bien de mettre tout de même qqch comme :
  # "were not in PLEXOS : ..."
  # nodes <- deane_europe_nodes_lst
  # properties_tbl <- wind_2015_properties_tbl
  # timeseries_tbl <- wind_cf_ts_tbl
  
  not_in_plexos_lst <- properties_tbl %>%
    filter(is.na(nominal_capacity)) %>%
    pull(generator_name)
  
  msg = paste("[WARN] - The following generators have Ninja timeseries, but no PLEXOS properties:", paste(not_in_plexos_lst, collapse = ", "))
  logError(msg)
  logError("[WARN] - Nominal capacities are unknown, so they cannot be imported into the simulation.")
  
  properties_tbl <- properties_tbl %>%
    filter(active_in_2015) %>%
    mutate(nominal_capacity = nominal_capacity * nb_units) %>%
    select(generator_name, node, nominal_capacity)
  
  # print(properties_tbl)
  # print(timeseries_tbl)
  
  product_tbl <- timeseries_tbl %>%
    gather(key = "generator_name", value = "capacity_factor", -datetime) 
  
  # print(product_tbl)
  
  product_tbl <- product_tbl %>%
    left_join(properties_tbl, by = "generator_name") %>%
    filter(node %in% nodes)
  
  # print(product_tbl)
  
  product_tbl <- product_tbl %>%
    mutate(power_output = nominal_capacity * capacity_factor / 100)
  # peut etre que pour lecture des données, faudrait mettre _mw ? ou bien dire dans doc..
  
  # print("Production table:")
  # print(product_tbl)
  # 
  # # Calculate the sum of the "power_output" column
  # total_power_output <- product_tbl %>% 
  #   summarise(total_power_output = sum(power_output))
  # 
  # # print("Total production:")
  # # print(total_power_output)
  # 
  # filtered_power <- product_tbl %>% 
  #   filter(!grepl("capacity scaler$", generator_name))
  # 
  # # print("Production table without capacity scalers:")
  # # print(filtered_power)
  # 
  # filtered_power_output <- filtered_power %>%
  #   summarise(filtered_power_output = sum(power_output))
  # 
  # # print("Total production without capacity scalers:")
  # # print(filtered_power_output)
  # 
  # # product_tbl <- product_tbl %>%
  # #   select(datetime, node, power_output)
  # 
  # # print(product_tbl)
  # 
  aggregated_tbl <- product_tbl %>%
    group_by(datetime, node) %>%
    summarize(node_power_output = sum(power_output, na.rm = FALSE), .groups = 'drop')
  
  # print(aggregated_tbl)
  
  aggregated_tbl <- aggregated_tbl %>%
    pivot_wider(names_from = node, values_from = node_power_output)
  
  # print(aggregated_tbl)
  return(aggregated_tbl)
}

# nodes <- deane_europe_nodes_lst
# properties_tbl <- wind_2015_properties_tbl
# timeseries_tbl <- wind_cf_ts_tbl*

# getAggregatedTSFromClusters(deane_europe_nodes_lst, wind_2015_properties_tbl, wind_cf_ts_tbl)
# getAggregatedTSFromClusters(deane_asia_nodes_lst, wind_2015_properties_tbl, wind_cf_ts_tbl)


wind_2015_aggregated_name = "wind_2015_aggregated_tbl.rds"
wind_2015_aggregated_path <- file.path(OBJECTS_PATH, wind_2015_aggregated_name)
if (REGENERATE_OBJECTS | !file.exists(wind_2015_aggregated_path)) {
  wind_2015_aggregated_tbl <- getAggregatedTSFromClusters(deane_all_nodes_lst,
                                                          wind_2015_properties_tbl,
                                                          wind_cf_ts_tbl)
  # Quel enfer, je crée une fonction qui permet de filtrer par nodes, mais finalement
  # j'en fais une pour chaque node que je sauvegarde, et puis ensuite je filtre sur les nodes ?
  
  # Je crois qu'à terme il faudrait que les objets ce soit :
  # on garde que les nodes qui nous intéressent à chaque fois, non ?
  # pourquoi stocker des robjects et des csv trop grands si jamais un jour on ne s'intéresse qu'aux nodes ?
  
  # en vrai non. objects est un accélérateur de processus donc faut des globaux.
  # mais les sorties csv qu'on met dans un output folder, ça oui, pas une miette qui dépasse.
  
  
  saveRDS(object = wind_2015_aggregated_tbl,
          file = wind_2015_aggregated_path)
}

solarpv_2015_aggregated_name = "solarpv_2015_aggregated_tbl.rds"
solarpv_2015_aggregated_path <- file.path(OBJECTS_PATH, solarpv_2015_aggregated_name)
if (REGENERATE_OBJECTS | !file.exists(solarpv_2015_aggregated_path)) {
  solarpv_2015_aggregated_tbl <- getAggregatedTSFromClusters(deane_all_nodes_lst,
                                                             solarpv_2015_properties_tbl,
                                                             solarpv_cf_ts_tbl)
  
  
  saveRDS(object = solarpv_2015_aggregated_tbl,
          file = solarpv_2015_aggregated_path)
}

# print(wind_2015_aggregated_tbl)
# print(solarpv_2015_aggregated_tbl)

# print(wind_2015_properties_tbl, n = 4000)

# print(solarpv_2015_properties_tbl)

# > print(new_solarpv_capacity_tbl, n = 100)
# # A tibble: 6,191 x 5
# generator_name             node      nominal_capacity nb_units active_in_2015
# <chr>                      <chr>                <dbl>    <dbl> <lgl>         
#   1 arg_sol_chimbera1107       sa-arg                   2        1 TRUE          
# 2 arg_sol_plantapilotof263   sa-arg                   1        1 TRUE          
# 3 aus_sol_adelaideshowgr303  oc-aus-sa                1        1 TRUE          
# 4 aus_sol_brokenhillsol343   oc-aus-sw               53        1 TRUE          
# 5 aus_sol_csiroenergyce355   oc-aus-sw                2        1 TRUE          
# 6 aus_sol_greenoughriver435  oc-aus-wa               10        1 TRUE          
# 7 aus_sol_liddellsolart507   NA                      NA       NA NA            
# 8 aus_sol_mildurasolarf531   oc-aus-sw                2        1 TRUE          
# 9 aus_sol_nyngansolarpl573   oc-aus-sw              102        1 TRUE          
# 10 aus_sol_perthzoo587        oc-aus-wa                2        1 TRUE  




# new_solarpv_capacity_tbl <- new_solarpv_capacity_tbl %>%
#   mutate(cf_ts = solarpv_cf_ts_tbl[[generator_name]])
# 
# print(new_solarpv_capacity_tbl, n = 100)

# # Reshape the solarpv_cf_ts_tbl from wide to long format
# long_solarpv_tbl <- solarpv_cf_ts_tbl %>%
#   pivot_longer(
#     cols = -datetime,               # Exclude the datetime column
#     names_to = "generator_name",    # Create a new column for generator names
#     values_to = "cf_ts"             # Create a new column for timeseries values
#   )
# print(long_solarpv_tbl)