source(".\\src\\2060\\CapacityProratas.R")
# test_scenario <- "S1"
# if_generators_properties_tbl <- get2060ScenarioTable(test_scenario)

nodes <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
wind_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/wind_cf_ts_tbl.rds")
pv_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/solarpv_cf_ts_tbl.rds")
all_scenarios_generators_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")

################################################################################

addDistrictsTo2060 <- function(nodes) {
  msg = "[MAIN] - Adding districts...\n"
  logMain(msg)
  start_time <- Sys.time()
  
  source(".\\src\\antaresCreateStudy_aux\\createDistricts.R")
  createGlobalDistrict(nodes)
  createDistrictsFromContinents(nodes)
  createDistrictsFromRegionalNodes(nodes)
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "secs"), 2)
  msg = paste0("[MAIN] - Done adding districts! (run time : ", duration,"s).\n")
  logMain(msg)
}

################################################################################


getAggregatedTSFrom2060 <- function(nodes, properties_tbl, timeseries_tbl) {
  
  not_in_plexos_lst <- properties_tbl %>%
    filter(is.na(nominal_capacity)) %>%
    pull(generator_name)
  
  # msg = paste("[WARN] - The following generators have Ninja timeseries, but no PLEXOS properties:", paste(not_in_plexos_lst, collapse = ", "))
  # logError(msg)
  # logError("[WARN] - Nominal capacities are unknown, so they cannot be imported into the simulation.")
  
  properties_tbl <- properties_tbl %>%
    # filter(active_in_2015) %>%
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

# wind_agg_ts <- getAggregatedTSFromClusters(nodes, if_generators_properties_tbl, wind_cf_ts_tbl)
# print(wind_agg_ts)

# # Quick check :
# wind_agg_check <- wind_agg_ts %>%
#     select(-datetime) 
# 
# wind_agg_check <- wind_agg_check %>%
#     mutate(World = rowSums(across(all_of(colnames(wind_agg_check))))) %>%
#     pull(World)
# 
# wind_agg_sum <- sum(wind_agg_check)
# 
# print(wind_agg_sum)

################################################################################

source(".\\src\\utils\\timeSeriesConversion.R")
library("data.table")

DATA_PATH = file.path("input", "dataverse_files")
HYDRO_2015_PATH = file.path(DATA_PATH, "Hydro_Monthly_Profiles (2015).txt")

getCFTableFromHydro <- function(hydro_data_path) {
  tbl <- read.table(hydro_data_path,
                    header = TRUE,
                    sep = ",",
                    stringsAsFactors = FALSE,
                    encoding = "UTF-8",
                    check.names = FALSE
  )
  tbl$NAME <- tolower(tbl$NAME)
  tbl <- as_tibble(tbl)
  return(tbl)
}
# print(hydro_2015_cf_tbl)

# if_generators_properties_tbl

getProductionTableFromHydro <- function(hydro_nominal_tbl) {
  
  hydro_2015_cf_tbl <- getCFTableFromHydro(HYDRO_2015_PATH)
  
  combined_tbl <- hydro_2015_cf_tbl %>%
    mutate(generator_name = NAME) %>%
    left_join(hydro_nominal_tbl, by = "generator_name") %>%
    select(generator_name, node, nominal_capacity, nb_units, 
           M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12)
  
  # Multiply the monthly values by the nominal capacity
  result_tbl <- combined_tbl %>%
    mutate(across(starts_with("M"), ~ . / 100 * nominal_capacity))
  return(result_tbl)
}

# print(hydro_production_tbl)

getCountryTableFromHydro <- function(generators_properties_tbl) {
  hydro_production_tbl <- getProductionTableFromHydro(generators_properties_tbl)
  
  hydro_countries_2060_tbl <- hydro_production_tbl %>%
    group_by(node) %>%
    summarise(
      across(starts_with("M"), sum), # .names = "total_{col}"),
      total_nominal_capacity = sum(nominal_capacity)
    )
  
  return(hydro_countries_2060_tbl)
}

##

add2060HydroToAntares <- function(generators_properties_tbl) {
  msg = "[MAIN] - Beginning hydro implementation..."
  logMain(msg)
  
  # nodes <- deane_all_nodes_lst
  
  
  # hydro_countries_2015 <- readRDS(".\\src\\objects\\hydro_monthly_production_countries_2015_tbl.rds")
  
  # hydro_country_tbl <- hydro_country_tbl %>%
  #   mutate(node = tolower(node)) %>%
  #   filter(node %in% nodes)
  hydro_countries_2060_tbl <- getCountryTableFromHydro(generators_properties_tbl)
  
  for (row in 1:nrow(hydro_countries_2060_tbl)) {
    #row = 1
    node_info <- hydro_countries_2060_tbl[row,]
    
    node <- node_info$node
    #print(node)
    
    hydro_capacity <- node_info$total_nominal_capacity
    max_power_matrix = as.data.table(matrix(c(hydro_capacity, 24, 0, 24), ncol = 4, nrow = 365, byrow = TRUE))
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
    
    monthly_tbl <- node_info %>%
      select(starts_with("M"))
    
    # Extract the values into a simple vector
    monthly_ts <- unlist(monthly_tbl, use.names = FALSE)
    
    daily_ts <- monthly_to_daily(monthly_ts, 2015)
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

## TESTING HYDRO FOR A BIT
if_generators_properties_tbl <- get2060ScenarioTable("S1")
hydro_countries_2060_tbl <- getCountryTableFromHydro(if_generators_properties_tbl)
print(hydro_countries_2060_tbl)

# > print(hydro_countries_2060_tbl)
# # A tibble: 220 x 14
# node       M1     M2     M3     M4    M5     M6     M7     M8     M9    M10    M11    M12 total_nominal_capacity
# <chr>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>                  <dbl>
#   1 af-ago 405.   411.   391.   378.   387.  341.   310.   300.   317.   372.   412.   412.                    572. 
# 2 af-bdi  28.6   29.4   30.2   30.0   29.1  30.9   30.8   30.7   30.7   28.3   29.1   28.7                    42.4
# 3 af-bfa   8.68   8.75   9.67   9.36  10.7   9.32   9.18   8.16   9.36   9.86   9.75   8.52                   26.0
# 4 af-caf  13.2   12.5   11.4   11.0   10.4   9.92   9.87  10.3   10.2   11.0   11.1   12.6                    16.5
# 5 af-civ  60.2   65.4  103.   130.   161.  188.   151.   157.   197.   185.   132.    77.5                   519. 
# 6 af-cmr 404.   409.   452.   465.   484.  477.   458.   445.   461.   461.   469.   414.                    624. 
# 7 af-cod 715.   716.   622.   612.   610.  464.   353.   334.   338.   503.   717.   739.                   1199. 
# 8 af-cog 130.   130.   131.   104.    83.9  63.2   60.1   59.3   62.0   73.8  113.   130.                    190. 
# 9 af-dza  17.2   19.0   15.7   14.9   14.5  13.6   12.5   12.7   11.0   15.0   14.9   17.2                   238. 
# 10 af-egy 351.   345.   364.   345.   328.  302.   243.   247.   263.   330.   407.   370.                    714. 
# # i 210 more rows
# # i Use `print(n = ...)` to see more rows

# ################################################################################
# ###################### IT'S TIME FOR CSP TIME
# 
# # csp_prod_ts_tbl = ".\\src\\objects\\csp_prod_ts_tbl.rds"
# # wind_cf_ts_path <- file.path(OBJECTS_PATH, wind_cf_ts_name)
# # if (REGENERATE_OBJECTS | !file.exists(wind_cf_ts_path)) {
# preprocessNinjaData_module = ".\\src\\antaresCreateStudy_aux\\preprocessNinjaData.R"
# source(preprocessNinjaData_module)
# csp_prod_ts_tbl <- getTableFromNinja(CSP_DATA_PATH)
# 
# csp_prod_ts_tbl <- csp_prod_ts_tbl %>%
#   rename_with(~ gsub("_storage$", "", .), -datetime) # dam its that easy innit
# 
# # print(csp_cf_ts_tbl)
# 
# # saveRDS(object = csp_cf_ts_tbl,
# #         file = csp_cf_ts_path)
# # # }
# 
# adjustCSPCapacityFactorsTbl <- function(csp_prod_ts_tbl) {
#   csp_cf_ts_tbl <- csp_prod_ts_tbl
#   
#   # csp_generators <- colnames(csp_prod_ts_tbl %>% select(-datetime))
#   
#   csp_2015_capacity_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl_2015.rds") %>%
#     filter(antares_cluster_type == "Solar Thermal" & active_in_2015) %>%
#     mutate(nominal_capacity = nominal_capacity * nb_units) %>%
#     select(generator_name, nominal_capacity)
#   
#   # print(csp_2015_capacity_tbl)
#   
#   plexos_csp_generators <- csp_2015_capacity_tbl %>% pull(generator_name)
#   # print(plexos_csp_generators)
#   # print(plexos_csp_generators)
#   
#   # csp_plexos_capacity_tbl <- csp_2015_capacity_tbl %>%
#   #   filter(generator_name %in% csp_generators)
#   
#   # print(csp_plexos_capacity_tbl)
#   # print(csp_generators)
#   
#   for (csp_gen in plexos_csp_generators) {
#     csp_gen_2015_capacity <- csp_2015_capacity_tbl %>%
#       filter(generator_name == csp_gen) %>%
#       pull(nominal_capacity)
#     
#     # Ici des CSP risquent de disparaître, l'occasion de  mettre un attention CSP not found dans PLEXOS
#     # [1] "isr_csp_ashalimsun13316"
#     # numeric(0)
#     # numeric(0)
#     # Error in `mutate()`:
#     #   i In argument: `isr_csp_ashalimsun13316 = .data[["isr_csp_ashalimsun13316"]] * conversion_ratio`.
#     
#     # print(csp_gen)
#     # print(csp_gen_2015_capacity)
#     
#     conversion_ratio <- 100 / csp_gen_2015_capacity
#     
#     # print(conversion_ratio)
#     
#     # Use `!!sym(csp_gen)` to dynamically reference the column by name
#     csp_cf_ts_tbl <- csp_cf_ts_tbl %>%
#       # mutate({{csp_gen}} := {{csp_gen}} * conversion_ratio)
#       mutate(!!sym(csp_gen) := .data[[csp_gen]] * conversion_ratio)
#   }
#   
#   return(csp_cf_ts_tbl)
# }
# 
# # print(csp_prod_ts_tbl)
# # csp_cf_ts_tbl <- adjustCSPCapacityFactorsTbl(csp_prod_ts_tbl)
# # print(csp_cf_ts_tbl)
# 
# # saveRDS(csp_cf_ts_tbl, ".\\src\\objects\\csp_prod_ts_tbl.rds")

#### ############### ITS TIME FOR CSP TIME A SECOND TIME ############ ##########

# library(stringr)
# solarpv_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/solarpv_cf_ts_tbl.rds")
# 
# # Ptet que le mieux, au lieu de faire des batteries, c'est plutôt passer par le mode clusters.. En vrai...
# # Sans non plus ajouter chaque centrale individuellement mais genre, ça permet de distinguer comme outputs
# # Solar PV et Solar Thermal...
# 
# solarcsp_cf_ts_tbl <- solarpv_cf_ts_tbl %>%
#   rename_with(~ str_replace(., "_sol_", "_csp_"))
# 
# # print(solarcsp_cf_ts_tbl)
# 
# generators_scenarios_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")
# csp_if_properties_tbl <- generators_scenarios_properties_tbl %>% 
#   filter(if_technology_type == "CSP")
# 
# # Extract column names from solarpv_cf_ts_tbl
# columns_in_solarcsp <- colnames(solarcsp_cf_ts_tbl)
# 
# # Filter generator names that match the column names in solarpv_cf_ts_tbl
# matching_generators <- csp_if_properties_tbl %>%
#   filter(generator_name %in% columns_in_solarcsp) %>%
#   select(generator_name)
# 
# # Display the matching generator names
# print(matching_generators, n = 67)
# 
# pv_if_generators <- generators_scenarios_properties_tbl %>% 
#   filter(if_technology_type == "PV") %>%
#   pull(generator_name)
# 
# # Filter and check presence of "_sol_capacity scaler" counterpart
# filtered_generators <- matching_generators %>%
########## En vrai je pourrais faire ceci avec n'importe quel _sol_, pas juste les capacity scaler.
# Peut etre que _sol_CentraleSolair était vraiment un PV (mais en pratique... non)
#   filter(!str_detect(generator_name, "capacity scaler") | 
#            !str_replace(generator_name, "_csp_capacity scaler", "_sol_capacity scaler") %in% pv_if_generators) %>%
#   pull(generator_name) %>% unique()
# 
# # Display the filtered generator names
# print(filtered_generators)
# 
# new_csp_properties_tbl <- generators_scenarios_properties_tbl %>% 
#   filter(generator_name %in% filtered_generators)
# 
# print(new_csp_properties_tbl)
# 
# true_csp_2015_capacity <- sum(
#   new_csp_properties_tbl %>%
#   filter(scenario == "S1") %>% # arbitrary but we gotta pick 1
#   pull(total_capacity_2015)
# )
# 
# print(true_csp_2015_capacity)
# 
# filteredcsp_cf_ts_tbl <- solarcsp_cf_ts_tbl %>%
#   select(datetime, all_of(filtered_generators))
# 
# print(filteredcsp_cf_ts_tbl)
# 
# saveRDS(filteredcsp_cf_ts_tbl, ".\\src\\objects\\trueCSP_cf_ts_tbl.rds")
csp_cf_ts_tbl <- readRDS(".\\src\\objects\\trueCSP_cf_ts_tbl.rds")

# ATTENTION !!! Délicat psk les capacity scaler je crois ont été inclus... Fin
# en gros il faut garder le truc en "sol" et vérifier qu'il est pas dans PLEXOS
# psk sinon ça veut dire qu'on l'a compté dans le PV...


################################################################################
#### ACTUALLY THE GRAVITY OF THERMAL TIME HAS BEEN SEVERELY UNDERESTIMATED #####

# [1] "Gas"        "Hydro"      "Oil"        "PV"         "CSP"        "Bioenergy"  "Coal"       "Nuclear"    "Wind"       "Geothermal"

# Moment de réalisation : est-ce bien honnête de garder les planned outage alors que
# bah ça fait que y a des centrales qui auront pas la "capacité effective" qu'elles
# prétendent avoir et que donc mon homothétie se retrouve problématique ?
# plutôt tej les planned outage, ce qui fait une hypothèse no maintenance mais bon alac,
# et voire même s'autoriser donc à clusteriser des trucs entre noeuds quand on voit
# jsp du charbon à 30 MW mdr.
# Mais après, ces maintenances elles étaient là aussi sur 2015, et donc quand
# j'ai pris mon tibble et j'ai fait "hop somme toutes les capacités, ça donne capa 2015 totale,
# je fais volume 2060 / volume 2015 et je multiplie toutes les centrales par ça
# bah... c'est pas si déconnant de garder le maintenance rate... je sais pas

# ########### DESIGN OF NEW TABLE
# thermal_properties_2015_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/thermal_properties_2015_tbl.rds")
# all_scenarios_generators_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")
# 
# all_scenarios_thermal_tbl <- all_scenarios_generators_tbl %>%
#   filter(if_technology_type %in% c("Gas", "Oil", "Bioenergy", "Coal", "Nuclear")) %>%
#   select(generator_name, if_technology_type, scenario, capacity_ratio)
# 
# thermal_if_properties_tbl <- all_scenarios_thermal_tbl %>%
#   left_join(thermal_properties_2015_tbl, by = "generator_name") %>%
#   select(-co2_emission, -variable_cost, -start_cost)
# 
# thermal_if_properties_tbl <- thermal_if_properties_tbl %>%
#   mutate(
#     brinkerink_fuel_type = case_when(
#     if_technology_type == "Gas" & min_stable_factor == 20 ~ "OCGT",
#     if_technology_type == "Gas" & min_stable_factor == 40 ~ "CCGT",
#     TRUE ~ if_technology_type
#     )
#   ) %>%
#   mutate(
#     standard_capacity = case_when(
#       brinkerink_fuel_type == "Bioenergy" ~ 200,
#       brinkerink_fuel_type == "Coal" ~ 300,
#       brinkerink_fuel_type == "CCGT" ~ 400,
#       brinkerink_fuel_type == "OCGT" ~ 130,
#       brinkerink_fuel_type == "Nuclear" ~ 600,
#       brinkerink_fuel_type == "Oil" ~ 300,
#       TRUE ~ NA
#         )
#     ) %>%
#   rename(capacity_2015 = nominal_capacity) %>%
#   mutate(capacity_2060 = capacity_ratio * capacity_2015) %>%
#   select(-capacity_ratio, -capacity_2015) %>%
#   filter(capacity_2060 != 0)
#   # mutate(
#   #   HRd = 
#   # )
# # so far c good, il faudra faire le HRd heat rate etc après le re-clustering
# 
# thermal_if_aggregated_tbl <- thermal_if_properties_tbl %>%
#   mutate(total_capacity = capacity_2060 * nb_units,
#          nb_units = 1) %>%
#   group_by(node, brinkerink_fuel_type, scenario) %>%
#   summarize(
#     # Sum the total capacity within each group
#     total_capacity = sum(total_capacity, na.rm = TRUE),
#     # Keep other values as is (assuming they are consistent within each group)
#     antares_cluster_type = first(antares_cluster_type),
#     nb_units = first(nb_units),
#     fo_rate = first(fo_rate),
#     fo_duration = first(fo_duration),
#     fuel_cost = first(fuel_cost),
#     co2_production_rate = first(co2_production_rate),
#     min_stable_factor = first(min_stable_factor),
#     standard_capacity = first(standard_capacity),
#     if_technology_type = first(if_technology_type),
#     .groups = "drop"
#   ) %>%
#   # Reorder columns to match original structure if needed
#   select(node, antares_cluster_type, brinkerink_fuel_type, if_technology_type, scenario, total_capacity, nb_units, standard_capacity, min_stable_factor,
#          fo_rate, fo_duration, fuel_cost, co2_production_rate)
#   
# 
# thermal_if_new_tbl <- thermal_if_aggregated_tbl %>%
#   mutate(
#     nb_units = ceiling(total_capacity / standard_capacity),
#     new_capacity_per_unit = total_capacity / nb_units,
#     min_stable_power = (min_stable_factor / 100) * new_capacity_per_unit,
#     generator_name = paste(node, brinkerink_fuel_type, sep = "_")
#   ) %>%
#   rename(po_rate = fo_rate,
#          po_duration = fo_duration) %>%
#   select(generator_name, node, antares_cluster_type, brinkerink_fuel_type, if_technology_type, scenario, total_capacity, nb_units, standard_capacity, 
#          new_capacity_per_unit, min_stable_factor, min_stable_power, po_rate, po_duration, fuel_cost, co2_production_rate)
# 
# 
# # print(thermal_if_new_tbl, n = 500)
# 
# thermal_if_heatrate_tbl <- thermal_if_new_tbl %>%
#   mutate(
#     HRd = case_when(
#       brinkerink_fuel_type == "Bioenergy" ~ 6e-5,
#       brinkerink_fuel_type == "Coal" ~ -2e-7,
#       brinkerink_fuel_type == "CCGT" ~ 2e-6,
#       brinkerink_fuel_type == "OCGT" ~ 8e-5,
#       brinkerink_fuel_type == "Nuclear" ~ 5e-8,
#       brinkerink_fuel_type == "Oil" ~ 8e-5,
#     ),
#     HRe = case_when(
#       brinkerink_fuel_type == "Bioenergy" ~ -0.0392,
#       brinkerink_fuel_type == "Coal" ~ -0.0016,
#       brinkerink_fuel_type == "CCGT" ~ 0.0025,
#       brinkerink_fuel_type == "OCGT" ~ -0.0235,
#       brinkerink_fuel_type == "Nuclear" ~ -0.0004,
#       brinkerink_fuel_type == "Oil" ~ -0.0235,
#     ),
#     HRf = case_when(
#       brinkerink_fuel_type == "Bioenergy" ~ 14.432,
#       brinkerink_fuel_type == "Coal" ~ 10.892,
#       brinkerink_fuel_type == "CCGT" ~ 8.307,
#       brinkerink_fuel_type == "OCGT" ~ 11.516,
#       brinkerink_fuel_type == "Nuclear" ~ 4.0717,
#       brinkerink_fuel_type == "Oil" ~ 11.516,
#     ),
#     heat_rate = HRd * new_capacity_per_unit^2 + HRe * new_capacity_per_unit + HRf
#     # SCa = 
#   )
# 
# # print(thermal_if_heatrate_tbl)
# 
# thermal_if_startcost_tbl <- thermal_if_heatrate_tbl %>%
#   mutate(
#     SCa = case_when(
#       brinkerink_fuel_type == "Bioenergy" ~ 246.51,
#       brinkerink_fuel_type == "Coal" ~ 6.2646,
#       brinkerink_fuel_type == "CCGT" ~ 251.5,
#       brinkerink_fuel_type == "OCGT" ~ 91.525,
#       brinkerink_fuel_type == "Nuclear" ~ 143.55,
#       brinkerink_fuel_type == "Oil" ~ 91.525,
#     ),
#     SCb = case_when(
#       brinkerink_fuel_type == "Bioenergy" ~ 1412.6,
#       brinkerink_fuel_type == "Coal" ~ 1166.7,
#       brinkerink_fuel_type == "CCGT" ~ -9875,
#       brinkerink_fuel_type == "OCGT" ~ -186.44,
#       brinkerink_fuel_type == "Nuclear" ~ 87091,
#       brinkerink_fuel_type == "Oil" ~ -186.44,
#     ),
#     computed_sc = SCa * new_capacity_per_unit + SCb
#   ) %>%
#   mutate(start_cost = ifelse(computed_sc < 0, 0, computed_sc))
#     # Le polynôme est un peu merdeux quand les capacités sont faibles,
#     # et peuvent donner un start cost négatif.
# 
# 
# # print(thermal_if_startcost_tbl)
# 
# thermal_if_operational_tbl <- thermal_if_startcost_tbl %>%
#   rename(capacity_2060 = new_capacity_per_unit) %>%
#   mutate(variable_cost = fuel_cost * heat_rate,
#          co2_emission_t = co2_production_rate * heat_rate / 1000) %>%
#   select(generator_name, node, antares_cluster_type, if_technology_type, scenario, nb_units, capacity_2060, 
#          min_stable_power, po_rate, po_duration, start_cost, variable_cost, co2_emission_t)
# 
# # print(thermal_if_operational_tbl, n = 500)
# 
# saveRDS(thermal_if_operational_tbl, ".\\src\\2060\\thermal_if_operational_tbl.rds")


# print(thermal_if_properties_tbl %>% select(generator_name, brinkerink_fuel_type, if_technology_type, min_stable_factor, standard_capacity), n = 50)

# thermal_properties_raw_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/thermal_properties_raw_tbl.rds") 
# 
# gas_types_tbl <- thermal_properties_raw_tbl %>%
#   filter(property == "Min Stable Factor" & value %in% c(20, 40)) %>%
#   mutate(
#     brinkerink_gas_type = case_when(
#     value == 20 ~ "OCGT",
#     value == 40 ~ "CCGT",
#     TRUE ~ NA # will disappear lmao
#     )
#   )

# print(thermal_properties_raw_tbl)

# thermal_properties_2015

# thermal_tbl_all_scenarios <- all_scenarios_generators_tbl %>%
#   mutate(
#     HRd = case_when(
#       if_technology_type == "Gas" ~ 
#         # ah ptn OCGT CCGT et c vrmt pas le même
#       #     antares_cluster_type == "Solar PV" ~ "PV",
#       #     antares_cluster_type == "Solar Thermal" ~ "CSP",
#       #     antares_cluster_type == "Wind Onshore" ~ "Wind",
#       #     antares_cluster_type == "Wind Offshore" ~ "Wind",
#       #     antares_cluster_type == "Mixed Fuel" ~ "Bioenergy",
#       #     antares_cluster_type == "Hard Coal" ~ "Coal",
#       #     antares_cluster_type == "Other" ~ "Geothermal",
#       #     
#       #     antares_cluster_type == "Gas" ~ "Gas",
#       #     antares_cluster_type == "Hydro" ~ "Hydro",
#       #     antares_cluster_type == "Nuclear" ~ "Nuclear",
#       #     antares_cluster_type == "Oil" ~ "Oil",
#       #     
#       #     TRUE ~ "Other" # will disappear lmao
#       #   )
#   )
# mutate(
#   if_technology_type = case_when(
#     # [1] "Gas"           "Hydro"         "Oil"           "Solar PV"      "Other 4"       "Solar Thermal" "Mixed Fuel"   
#     # [8] "Hard Coal"     "Nuclear"       "Wind Onshore"  "Wind Offshore" "Other 3"       "Other"         "Other 2"
#     antares_cluster_type == "Solar PV" ~ "PV",
#     antares_cluster_type == "Solar Thermal" ~ "CSP",
#     antares_cluster_type == "Wind Onshore" ~ "Wind",
#     antares_cluster_type == "Wind Offshore" ~ "Wind",
#     antares_cluster_type == "Mixed Fuel" ~ "Bioenergy",
#     antares_cluster_type == "Hard Coal" ~ "Coal",
#     antares_cluster_type == "Other" ~ "Geothermal",
#     
#     antares_cluster_type == "Gas" ~ "Gas",
#     antares_cluster_type == "Hydro" ~ "Hydro",
#     antares_cluster_type == "Nuclear" ~ "Nuclear",
#     antares_cluster_type == "Oil" ~ "Oil",
#     
#     TRUE ~ "Other" # will disappear lmao
#   )
# ) %>%


# 
# DEFAULT_FO_DURATION = 1
# DEFAULT_PO_DURATION = 1
# DEFAULT_FO_RATE = 0
# DEFAULT_PO_RATE = 0
# DEFAULT_NPO_MIN = 0
# DEFAULT_NPO_MAX = 0
# 
# get2060ThermalPropertiesTable <- function(thermal_generators_tbl) {
#   thermal_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#     mutate(generator_name = tolower(child_object)) %>%
#     filter(collection == "Generators")
#   thermal_properties_tbl <- thermal_properties_tbl %>%
#     select(generator_name, property, value) %>%
#     filter(property %in% c("Max Capacity", "Start Cost", "Units", "Min Stable Factor", "Heat Rate", 
#                            "Maintenance Rate", "Mean Time to Repair")) 
# 
#   thermal_generators_tbl <- thermal_generators_tbl %>%
#     left_join(thermal_properties_tbl, by = "generator_name")
#   
#   thermal_generators_tbl <- thermal_generators_tbl %>%
#     pivot_wider(names_from = property, values_from = value) %>%
#     mutate(fo_rate = ifelse(is.na(`Maintenance Rate`), DEFAULT_FO_RATE, `Maintenance Rate`/100), # Default value in Antares is 0
#            fo_duration = ifelse(is.na(`Mean Time to Repair`), DEFAULT_FO_DURATION, `Mean Time to Repair`/24) # Default value in Antares is 1
#     )
#   
#   thermal_generators_tbl <- thermal_generators_tbl %>%
#     rename(
#       # nominal_capacity = "Max Capacity", ## already imported now
#       start_cost = "Start Cost",
#       # nb_units = "Units",
#       min_stable_factor = "Min Stable Factor",
#       heat_rate = "Heat Rate"
#     ) %>%
#     mutate(min_stable_power = nominal_capacity * min_stable_factor / 100) %>%
#     select(generator_name, node, plexos_fuel_group, antares_cluster_type, nominal_capacity, start_cost, nb_units, 
#            min_stable_power, heat_rate, fo_rate, fo_duration)
#   
#   # Time to add variable cost baybee
#   emissions_and_prices_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#     filter(collection == "Fuels") %>%
#     # Hah y avait un pb pendant le pivot_wider vu comment y avait comme parent_object "System" ou "CO2"
#     # et du coup bon courage pour mettre ça sur la même ligne
#     # yessai
#     select(child_object, property, value) %>%
#     # print(emissions_and_prices_tbl, n=300)
#     pivot_wider(names_from = property, values_from = value) # ptet en faire un objet R global
#   # select(child_object, `Production Rate`, Price)
#   
#   # print(emissions_and_prices_tbl)
#   
#   emissions_and_prices_tbl <- emissions_and_prices_tbl %>%
#     # replace(is.na(.), 0) %>%
#     #select(child_object, "Production Rate") %>%
#     rename(plexos_fuel_group = child_object,
#            fuel_cost = Price,
#            # so ! new studies show production rate is actually in kg/GJ
#            # and heat rate is in GJ/MWh
#            # therefore PR * HR is in kgCO2/MWh
#            # indeed we need to divide by 1000 still, because in Antares it's in tons.
#            #co2_emission = `Production Rate`/1000
#            production_rate = `Production Rate`
#     ) %>%
#     # again, in TONS
#     # it's in *tons*CO2/MWh in Antares
#     # en fait vrmt le production rate c'est quoi ptn
#     
#     select(plexos_fuel_group, fuel_cost, production_rate)
#   
#   # print(thermal_generators_tbl)
#   # print(emissions_and_prices_tbl)
#   
#   thermal_generators_tbl <- thermal_generators_tbl %>%
#     left_join(emissions_and_prices_tbl, by = "plexos_fuel_group")
#   
#   # print(thermal_generators_tbl)
#   
#   thermal_generators_tbl <- thermal_generators_tbl %>%
#     #left_join(emissions_and_prices_tbl, by = "fuel_group") %>% oops, duplicate
#     mutate(co2_production_rate = ifelse(is.na(production_rate), 0, production_rate),
#            variable_cost = heat_rate * fuel_cost,
#            co2_emission_kg = heat_rate * co2_production_rate,
#            co2_emission = co2_emission_kg / 1000)
#   
#   # thermal_generators_test <- thermal_generators_tbl %>%
#   #   select(generator_name, node, cluster_type, heat_rate, fuel_cost, variable_cost, co2_production_rate, co2_emission_kg, co2_emission)
#   #   
#   # print(thermal_generators_test)
#   
#   thermal_generators_tbl <- thermal_generators_tbl %>%
#     select(generator_name, node, antares_cluster_type, nominal_capacity, nb_units, min_stable_power, 
#            co2_emission, variable_cost, start_cost,
#            fo_rate, fo_duration)
#   
#   # print(thermal_generators_tbl, n = 100)
#   
#   return(thermal_generators_tbl)
# }