library(antaresProcessing)
library(dplyr)
library(tidyr)
source("parameters.R")
MWH_COLUMNS = c("BALANCE", "ROW BAL.", "PSP", "MISC. NDG", "LOAD", "H. ROR", "WIND", "SOLAR",
                "NUCLEAR", "LIGNITE", "COAL", "GAS", "OIL", "MIX. FUEL",
                "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                "H. STOR", "H. PUMP", "H. INFL",
                "PSP_open_level", "PSP_closed_level", "Pondage_level", "Battery_level",
                "Other1_level", "Other2_level", "Other3_level", "Other4_level", "Other5_level",
                "UNSP. ENRG", "SPIL. ENRG", "AVL DTG", "DTG MRG", "MAX MRG",

                "PSP_open_injection", "PSP_closed_injection", "Pondage_injection", "Battery_injection",
                "Other1_injection", "Other2_injection", "Other3_injection", "Other4_injection", "Other5_injection",
                "PSP_open_withdrawal", "PSP_closed_withdrawal", "Pondage_withdrawal", "Battery_withdrawal",
                "Other1_withdrawal", "Other2_withdrawal", "Other3_withdrawal", "Other4_withdrawal", "Other5_withdrawal")

# study_name = IMPORT_STUDY_NAME
# study_name = "EU_clutest__2024_09_10_21_29_47"
study_name = "v2_20clu__2024_09_04_22_33_36"
# study_name = "EU_full_agg__2024_09_12_15_06_18"
study_path = file.path("input", "antares_presets", study_name,
                        fsep = .Platform$file.sep)
simulation_name = IMPORT_SIMULATION_NAME
# simulation_name = "20240910-2240eco-renewabletest"
# simulation_name = "20240912-1508eco-accrate_test"
setSimulationPath(study_path, simulation_name)

districts <- getDistricts()
print(districts)


# library(dplyr)
# library(tidyr)

# antares_data <- readAntares(districts = "europe",
#                             timeStep = "annual"
#                             )
#
# library(dplyr)
#
# ## Aggregated
# print(antares_data$`SOLAR`)
# print(antares_data$`WIND`)

## Clusters
# print(antares_data$`SOLAR PV`)
# antares_data <- antares_data %>%
#   mutate(WIND = `WIND ONSHORE` + `WIND OFFSHORE`)
# print(antares_data$`WIND`)

###############

# antares_data <- readAntares(areas = "af-cpv",
#                             timeStep = "hourly",
#                             select = MWH_COLUMNS
#                             )
# 
# antares_tbl <- as_tibble(antares_data)

# antares_data <- readAntares(areas = "af-esh",
#                             timeStep = "hourly",
#                             select = MWH_COLUMNS
# )
# 
# antares_tbl <- as_tibble(antares_data)
# 
# # Remove columns where all values are 0
# antares_tbl_clean <- antares_tbl %>%
#   select_if(~ !all(. == 0))
# 
# # View the cleaned tibble
# print(antares_tbl_clean)

##################################

# 
# wind_2015_aggregated_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/wind_2015_aggregated_tbl.rds")
# solarpv_2015_aggregated_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/solarpv_2015_aggregated_tbl.rds")
# deane_europe_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_europe_nodes_lst.rds")
# 
# # Assuming your tibble is named 'df'
# europe_wind <- wind_2015_aggregated_tbl %>%
#   select(-datetime) %>%
#   select(any_of(deane_europe_nodes_lst))
# 
# print(europe_wind)
# 
# europe_wind_sum <- europe_wind %>%
#   summarise(across(everything(), sum)) %>%
#   sum()
# 
# # Print the total sum
# print(europe_wind_sum)
# 
# ################
# 
# # Assuming your tibble is named 'df'
# europe_solarpv <- solarpv_2015_aggregated_tbl %>%
#   select(-datetime) %>%
#   select(any_of(deane_europe_nodes_lst))
# 
# print(europe_solarpv)
# 
# europe_solarpv_sum <- europe_solarpv %>%
#   summarise(across(everything(), sum)) %>%
#   sum()
# 
# # Print the total sum
# print(europe_solarpv_sum)


###################
# GET INSTALLED CAPACITY FOR COMPARISON WITH IF
# (actually could be in Objects...)

# solarpv_2015_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/solarpv_2015_properties_tbl.rds") %>%
  # filter(active_in_2015)

# print(solarpv_2015_properties_tbl)


# solarpv_2015_capacity <- solarpv_2015_properties_tbl %>%
#   mutate(total_capacity = nominal_capacity * nb_units) %>%
#   summarise(pv_total_capacity = sum(total_capacity))
# 
# print(solarpv_2015_capacity)
# 
# wind_2015_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/wind_2015_properties_tbl.rds") %>%
#   filter(active_in_2015)
# 
# wind_2015_capacity <- wind_2015_properties_tbl %>%
#   mutate(total_capacity = nominal_capacity * nb_units) %>%
#   summarise(wind_total_capacity = sum(total_capacity))
# 
# print(wind_2015_capacity)

# base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds") %>%
#   filter(active_in_2015)

# fuel_types <- base_generators_properties_tbl %>%
#   pull(antares_cluster_type) %>%
#   # pull(plexos_fuel_type) %>%
#   unique()
# 
# print(fuel_types)

# print(base_generators_properties_tbl)
# 
# world_grouped_capacity <- base_generators_properties_tbl %>%
#   group_by(antares_cluster_type) %>%
#   summarise(total_capacity = sum(nominal_capacity * nb_units, na.rm = TRUE))
# 
# print(world_grouped_capacity)
# 
# continent_grouped_capacity <- base_generators_properties_tbl %>%
#   group_by(continent, antares_cluster_type) %>%
#   summarise(total_capacity = sum(nominal_capacity * nb_units, na.rm = TRUE))
# 
# print(continent_grouped_capacity, n = 75)
# 
# # print(continent_grouped_capacity %>% filter(antares_cluster_type %in% c("Wind Offshore", "Wind Onshore")))
# print(continent_grouped_capacity %>% filter(antares_cluster_type == "Other"))


# #################
# Et maintenant la conso !!!!!!

# data_path <- ".\\input\\dataverse_files"
# load_path <- file.path(data_path, "All Demand UTC 2015.txt")
# load_table <- read.table(
#   load_path,
#   header = TRUE,
#   sep = ",",
#   encoding = "UTF-8",
#   row.names = 1,
#   stringsAsFactors = FALSE,
#   check.names = FALSE
# )
# # N'empeche que c'est sympa d'avoir fait un Excel avec RR_testing et tout mais
# # si jamais je décide d'ici la fin du stage de faire un autre run, tout change...
# # ce serait bien de faire un truc qui me pond les graphes que je cherche etc
# # directement dans le code. qui pond les Excels aussi d'ailleurs.
# 
# load_tbl <- as_tibble(load_table) %>%
#   rename_with(tolower)
# 
# print(load_tbl)
# 
# load_nodes <- colnames(load_tbl)
# 
# deane_all_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
# 
# diff_nodes <- setdiff(load_nodes, deane_all_nodes_lst)
# print(diff_nodes)

# load_tbl_sum <- load_tbl %>%
#   summarise(across(everything(), sum)) %>%
#   sum()
# 
# print(load_tbl_sum)

##################
# Pour Jean-Yves, retrouver la techno et le noeud :

# antares_data <- readAntares(areas = "all",
#                             districts = "all", 
#                             timeStep = "annual",
#                             select = MWH_COLUMNS
# )
# 
# print(antares_data)

source(".\\src\\antaresReadResults_aux\\RR_config.R")
source(".\\src\\antaresReadResults_aux\\getAntaresData.R")

national_data <- getNationalAntaresData("annual")
national_data <- as_tibble(national_data)
# print(national_data)

# saveRDS(antares_data, "~/GitHub/antares-brinkerink-2015/src/objects/technos_noeuds_annuel.rds")

spillage_tbl <- national_data %>%
  select(area, "SPIL. ENRG")

# print(spillage_tbl)

continental_data <- getContinentalAntaresData("annual")
continental_data <- as_tibble(continental_data)
# print(continental_data)

# saveRDS(antares_data, "~/GitHub/antares-brinkerink-2015/src/objects/technos_noeuds_annuel.rds")

summary_tbl <- continental_data %>%
  mutate(PROD = WIND + SOLAR + NUCLEAR + COAL + GAS + OIL + `MIX. FUEL` + 
           `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4` +
           `H. STOR`,
         PROD_WITH_BATT = PROD 
         + `PSP_closed_withdrawal` - `PSP_closed_injection`
         + `Battery_withdrawal` - `Battery_injection`
         + `Other1_withdrawal` - `Other1_injection`
         + `Other2_withdrawal` - `Other2_injection`
         + `Other3_withdrawal` - `Other3_injection`,
         VERIF_TRANSFER = LOAD + `SPIL. ENRG` - PROD_WITH_BATT - `UNSP. ENRG`) %>%
  select(area, LOAD, PROD, PROD_WITH_BATT, `UNSP. ENRG`, `SPIL. ENRG`, VERIF_TRANSFER)

print(summary_tbl)

# ## Deuxieme graphe pertinent : Prod v Prod par moyen à la maille monde
# 
# global_data <- getGlobalAntaresData("annual")
# global_data <- as_tibble(global_data) 
# # Moyens de Deane seulement
# global_data <- global_data %>%
#   rename(BIOENERGY = `MIX. FUEL`,
#          GEOTHERMAL = `MISC. DTG`,
#          HYDRO = `H. STOR`) %>%
#   select(BIOENERGY, COAL, GAS, GEOTHERMAL, HYDRO, NUCLEAR, OIL, SOLAR, WIND)
# 
# # print(global_data)
# 
# 
# #### Juste comme intro de mon rapport : mix en Europe
# base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds")
# europe_electric_mix <- base_generators_properties_tbl %>%
#   filter(continent == "europe") %>%
#   group_by(node, plexos_fuel_type) %>%
#   summarise(total_capacity = sum(nominal_capacity * nb_units, na.rm = TRUE)) %>%
#   select(node, total_capacity, plexos_fuel_type) %>%
#   pivot_wider(names_from = plexos_fuel_type, values_from = total_capacity, values_fill = 0) %>%
#   rename(Geothermal = Other) %>%
#   select(node, Solar, Wind, Hydro, Geothermal)
# 
# print(europe_electric_mix, n = 50)


#######################

# TEST : GRAPHES HORAIRES AVEC YMAX

##########


continental_data <- getContinentalAntaresData("hourly")
continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)

print(continental_data)
print(continents)

europe_max <- as_tibble(continental_data) %>%
  filter(area == "europe") %>%
  mutate(PRODUCTION = NUCLEAR + WIND + SOLAR + `H. STOR` + GAS + COAL + OIL 
         + `MIX. FUEL` + `MISC. DTG` + `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`) %>%
  select(LOAD, PRODUCTION)

print(europe_max)
  
max_load <- max(your_tibble$LOAD, na.rm = TRUE)
max_total_production <- max(your_tibble$TOTAL_PRODUCTION, na.rm = TRUE)

yMax <- 1.1 * max(max_load, max_total_production)

print(europe_max)



