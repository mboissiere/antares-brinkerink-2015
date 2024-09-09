library(dplyr)
library(tidyr)

# all_deane_nodes_lst <- readRDS(".\\src\\objects\\all_deane_nodes_lst.rds")
# full_2015_generators_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds")
# full_2015_batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")

# print(full_2015_generators_tbl)
# source(".\\src\\data\\importThermal.R")
# THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel", "Oil", 
#                   "Other", "Other 2", "Other 3", "Other 4")
# full_2015_generators_tbl <- filterClusters(full_2015_generators_tbl, THERMAL_TYPES)
# full_2015_generators_tbl <- getThermalPropertiesTable(full_2015_generators_tbl)
# print(full_2015_generators_tbl)
# saveRDS(full_2015_generators_tbl, ".\\src\\objects\\thermal_generators_properties_tbl.rds")
# thermal_generators_properties_tbl <- readRDS(".\\src\\objects\\thermal_generators_properties_tbl.rds")
# print(thermal_generators_properties_tbl)

library(data.table)
hourly_zeros <- matrix(0, 8760)
hourly_zeros_datatable <- as.data.table(hourly_zeros)
hourly_ones <- matrix(1, 8760)
hourly_ones_datatable <- as.data.table(hourly_ones)


# 
# source(".\\src\\data\\addNodes.R")
# all_deane_nodes_lst <- getAllNodes()
# print(all_deane_nodes_lst)
# saveRDS(object = all_deane_nodes_lst,
#         file = ".\\src\\objects\\all_deane_nodes_lst.rds")
# 
# europe_nodes_lst <- getNodesFromContinents("Europe")
# print(europe_nodes_lst)
# saveRDS(object = europe_nodes_lst,
#         file = ".\\src\\objects\\europe_nodes_lst.rds")
# 
# africa_nodes_lst <- getNodesFromContinents("Africa")
# print(africa_nodes_lst)
# saveRDS(object = africa_nodes_lst,
#         file = ".\\src\\objects\\africa_nodes_lst.rds")
# 
# asia_nodes_lst <- getNodesFromContinents("Asia")
# print(asia_nodes_lst)
# saveRDS(object = asia_nodes_lst,
#         file = ".\\src\\objects\\asia_nodes_lst.rds")
# 
# north_america_nodes_lst <- getNodesFromContinents("North America")
# print(north_america_nodes_lst)
# saveRDS(object = north_america_nodes_lst,
#         file = ".\\src\\objects\\north_america_nodes_lst.rds")
# 
# south_america_nodes_lst <- getNodesFromContinents("South America")
# print(south_america_nodes_lst)
# saveRDS(object = south_america_nodes_lst,
#         file = ".\\src\\objects\\south_america_nodes_lst.rds")
# 
# oceania_nodes_lst <- getNodesFromContinents("Oceania")
# print(oceania_nodes_lst)
# saveRDS(object = oceania_nodes_lst,
#         file = ".\\src\\objects\\oceania_nodes_lst.rds")





# emissions_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#   filter(parent_class == "Emission") %>%
#   pivot_wider(names_from = property, values_from = value) # ptet en faire un objet R global
# 
# print(emissions_tbl)
# 
# emissions_tbl <- emissions_tbl %>%
#   mutate(`Production Rate` = ifelse(is.na(`Production Rate`), 0, `Production Rate`)) %>%
#   # replace(is.na(.), 0) %>% 
#   # select(child_object, "Production Rate")
#   # ah mais ça sert à rien de modifier ici, c'est dans la fusion qu'il y aura des NA
#   mutate(fuel_group = child_object,
#          co2_emission = `Production Rate`/1000) %>% # it's in *tons*CO2/MWh in Antares
#   select(fuel_group, co2_emission)
# 
# print(emissions_tbl, n = 137)


# print(full_2015_generators_tbl)

# Group: 'Other 1' is not a valid name recognized by Antares, you should be using one of: Gas, Hard coal, Lignite, Mixed fuel, Nuclear, Oil, Other, Other 2, Other 3, Other 4

# preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
# source(preprocessPlexosData_module)
# 
# batteries_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
#   # Initialization of batteries table with only generator names and continent of origin
#   filter(class == "Battery") %>%
#   select(name, category) %>%
#   rename(battery_name = name,
#          continent = category)
# 
# # Adding country/node info to each battery
# batteries_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
#   filter(parent_class == "Battery" & child_class == "Node") %>%
#   rename(battery_name = parent_object,
#          node = child_object) %>%
#   left_join(batteries_tbl, by = "battery_name")
# 
# # No need for mutating the battery names to uppercase, because no Ninja dataset.
# 
# batteries_tbl <- batteries_tbl %>%
#   select(battery_name, continent, node)
# 
# battery_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#   filter(collection == "Batteries") %>% #& scenario == "{Object}Include All Storage") %>%
#   # No bueno, le include all storage est que sur units et du coup ça fait disparaitre le reste
#   # Mais comment sélectionner le bon units du coup...
#   filter(!(property == "Units" & scenario != "{Object}Include All Storage")) %>%
#   # Bien, mais ça suffit pas : il y a une duplication sur "Max Power" là où
#   # il y a à la fois includePHS et include all storage
#   # le plus simple est de virer les include PHS (même si ça veut pas dire qu'on
#   # exclut les PHS, ça vaut bien de le rendre clair ptet)
#   filter(!(property == "Max Power" & scenario == "{Object}Include PHS")) %>%
#   rename(battery_name = child_object)
# 
# batteries_tbl <- batteries_tbl %>%
#   left_join(battery_properties_tbl, by = "battery_name") %>%
#   select(battery_name, continent, node, property, value)
# 
# batteries_tbl <- batteries_tbl %>%
#   pivot_wider(names_from = property, values_from = value) %>%
#   mutate(
#     units = Units,
#     #capacity = 1000 * `Capacity`,
#     capacity = Capacity,
#     max_power = `Max Power`,
#     initial_state = `Initial SoC`,
#     efficiency = `Charge Efficiency`
#   )
# # In supplementary material, capacity is actually written to be in GWh !
# # Though I should try to produce a document to double check.
# 
# full_2015_batteries_tbl <- batteries_tbl
# print(full_2015_batteries_tbl)
# 
# # Note : I might have to manually make categories for THE, CHE, PHS etc etc...
# # Oh wait, there it is actually, since I want to filter by PHS
# 
# # Define a function to extract the middle string from the battery_name
# extract_middle_string <- function(battery_name) {
#   return(substr(battery_name, 5, 7))
# }
# 
# # Add the battery_group column to the tibble
# full_2015_batteries_tbl <- full_2015_batteries_tbl %>%
#   mutate(battery_group = case_when(
#     extract_middle_string(battery_name) == "CHE" ~ "Chemical Battery",
#     extract_middle_string(battery_name) == "THE" ~ "Thermal",
#     extract_middle_string(battery_name) == "PHS" ~ "Pumped Hydro Storage",
#     extract_middle_string(battery_name) == "HYD" ~ "Hydrogen",
#     extract_middle_string(battery_name) == "CAE" ~ "Compressed Air Energy",
#     TRUE ~ NA_character_ # In case there are other types not listed
#   )) %>%
#   select(battery_name, continent, node, battery_group, units, capacity, max_power, initial_state, efficiency)
# 
# # This is the part where we add Antares cluster types and it sucks
# # because it's just gonna be "Other" a bunch
# # Also, we have no way of getting intakes, so all "open-loop" PHS
# # will just be taken as closed-loop
# full_2015_batteries_tbl <- full_2015_batteries_tbl %>%
#   mutate(cluster_type = case_when(
#     battery_group == "Pumped Hydro Storage" ~ "PSP_closed",
#     battery_group == "Chemical Battery" ~ "Battery",
#     battery_group == "Thermal" ~ "Other1",
#     battery_group == "Hydrogen" ~ "Other2",
#     battery_group == "Compressed Air Energy" ~ "Other3",
#     TRUE ~ NA_character_ # In case there are other types not listed
#   )) %>%
#   select(battery_name, continent, node, battery_group, cluster_type, units, capacity, max_power, initial_state, efficiency)
# 
# 
# # print(full_2015_batteries_tbl)
# 
# saveRDS(full_2015_batteries_tbl, file = ".\\src\\objects\\full_2015_batteries_tbl.rds")
# full_2015_batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
# print(full_2015_batteries_tbl)
# full_2015_batteries_tbl <- batteries_tbl
# print(full_2015_batteries_tbl)

#############


# source(".\\src\\data\\preprocessPlexosData.R")
# all_deane_nodes <- readRDS(".\\src\\objects\\all_deane_nodes_lst.rds")
# full_2015_generators_tbl <- getGeneratorsFromNodes(all_deane_nodes)
# full_2015_generators_tbl <- addGeneralFuelInfo(full_2015_generators_tbl)
# full_2015_generators_tbl <- filterFor2015(full_2015_generators_tbl)
# 
# saveRDS(full_2015_generators_tbl, ".\\src\\objects\\full_2015_generators_tbl.rds")
# full_2015_generators_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds")
# print(full_2015_generators_tbl)
  
# 
# geothermal_tbl <- full_2015_generators_tbl %>%
#   filter(fuel_group == "Europe_Geo")
# 
# print(geothermal_tbl)
# full_2015_generators_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds")
# print(full_2015_generators_tbl)
# full_2015_batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
# print(full_2015_batteries_tbl)

####################################

# aight time to get some CO2 emissions per continent and stuff

# wow this is so fucking complicated actually ????

# source(".\\src\\antaresCreateStudy_aux\\preprocessPlexosData.R")
# 
# generator_fgroup_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
#   filter(parent_class == "Generator" & child_class == "Fuel") %>%
#   rename(generator_name = parent_object,
#          fuel_group = child_object) %>%
#   select(generator_name, fuel_group)
# 
# print(generator_fgroup_tbl)
# 
# fgroup_ftype_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
#   filter(class == "Fuel") %>%
#   rename(fuel_group = name,
#          fuel_type = category) %>%
#   select(fuel_group, fuel_type)
# 
# print(fgroup_ftype_tbl)
# 
# node_continent_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
#   filter(class == "Node") %>%
#   rename(node = name,
#          continent = category) %>%
#   select(node, continent)
# 
# print(node_continent_tbl)
# 
# fgroup_prate_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#   filter(parent_class == "Emission" & child_class == "Fuel") %>%
#   select(child_object, property, value) %>%
#   pivot_wider(names_from = "property", values_from = "value") %>%
#   rename(fuel_group = child_object,
#          production_rate = `Production Rate`)
# 
# print(fgroup_prate_tbl)
# 
# generator_node_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
#   filter(parent_class == "Generator" & child_class == "Node") %>%
#   rename(generator_name = parent_object,
#          node = child_object) %>%
#   select(generator_name, node)
# 
# print(generator_node_tbl)
# 
# # generator_fgroup_tbl
# # fgroup_ftype_tbl
# # fgroup_prate_tbl
# # generator_node_tbl
# # node_continent_tbl
# 
# individual_emissions_data_tbl <- generator_node_tbl %>%
#   left_join(generator_fgroup_tbl, by = "generator_name") %>%
#   left_join(fgroup_ftype_tbl, by = "fuel_group") %>%
#   left_join(node_continent_tbl, by = "node") %>%
#   left_join(fgroup_prate_tbl, by = "fuel_group") %>%
#   filter(!is.na(production_rate))
# 
# emissions_data_tbl <- individual_emissions_data_tbl %>%
#   select(fuel_type, continent, production_rate) %>%
#   distinct()
# 
# saveRDS(emissions_data_tbl, ".\\src\\objects\\emissions_by_continent_fuel.rds")
# emissions_data <- readRDS(".\\src\\objects\\emissions_by_continent_fuel.rds")
# 
# print(emissions_data_tbl)

# Tout ça pour 20 lignes mdr mais c'est la seule façon de le faire rigoureusement..

# wind_clusters_ninja_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/wind_clusters_ninja_tbl.rds")
# write.table(wind_clusters_ninja_tbl, 
#             file = ".\\output\\csv\\wind_clusters_ninja_tbl.csv", 
#             quote = FALSE,
#             sep = ";", 
#             dec = ",")


#### Let's try and check which things are in Ninja and not in PLEXOS

wind_clusters_ninja_tbl <- readRDS(".\\src\\objects\\wind_clusters_ninja_tbl.rds") %>%
  select(-DATETIME)
wind_clusters_plexos_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds") %>%
  filter(fuel_type == "Wind")


# wind_ninja_not_in_plexos_tbl <- wind_clusters_plexos_tbl %>%
#   filter(!(generator_name %in% colnames(wind_clusters_ninja_tbl))) %>%
#   select(generator_name)

ninja_wind_lst <- colnames(wind_clusters_ninja_tbl)
# print(ninja_wind_lst)

plexos_wind_lst <- wind_clusters_plexos_tbl$generator_name
# print(plexos_wind_lst)

wind_ninja_not_in_plexos_lst <- setdiff(ninja_wind_lst, plexos_wind_lst)
wind_plexos_not_in_ninja_lst <- setdiff(plexos_wind_lst, ninja_wind_lst)

####

solar_clusters_ninja_tbl <- readRDS(".\\src\\objects\\solar_clusters_ninja_tbl.rds") %>%
  select(-DATETIME)
solar_clusters_plexos_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds") %>%
  filter(fuel_type == "Solar")


ninja_solar_lst <- colnames(solar_clusters_ninja_tbl)
# print(ninja_solar_lst)

plexos_solar_lst <- solar_clusters_plexos_tbl$generator_name
# print(plexos_solar_lst)

solar_ninja_not_in_plexos_lst <- setdiff(ninja_solar_lst, plexos_solar_lst)
solar_plexos_not_in_ninja_lst <- setdiff(plexos_solar_lst, ninja_solar_lst)

####

print("Turbines in Ninja but not in PLEXOS:")
print(wind_ninja_not_in_plexos_lst)

print("Turbines in PLEXOS but not in Ninja:")
print(wind_plexos_not_in_ninja_lst)

print("Panels in Ninja but not in PLEXOS:")
print(solar_ninja_not_in_plexos_lst)

print("Panels in PLEXOS but not in Ninja:")
print(solar_plexos_not_in_ninja_lst)
