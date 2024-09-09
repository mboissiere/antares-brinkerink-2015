# source("architecture.R")

deane_all_nodes_name <- "deane_all_nodes_lst.rds"
deane_all_nodes_path <- file.path(OBJECTS_PATH, deane_all_nodes_name)
if (REGENERATE_OBJECTS | !file.exists(deane_all_nodes_path)) {
  source(addNodes_module)
  deane_all_nodes_lst <- getAllNodes()
  # So far, AllNodes isn't tolowered.
  saveRDS(object = deane_all_nodes_lst,
          file = deane_all_nodes_path)
}


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
print(solarpv_2015_properties_tbl)

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