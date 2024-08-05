preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)
# source("parameters.R")

thermalPath = file.path("src", "data", "importThermal.R")
source(thermalPath)

source(".\\src\\objects\\r_objects.R")

library(tidyr)

print(full_2015_generators_tbl)

# generators_tbl <- getGeneratorsFromNodes(DEANE_NODES_ALL)
# generators_tbl <- filterFor2015(generators_tbl)
# generators_tbl <- addGeneralFuelInfo(generators_tbl)
# 
# print(generators_tbl)

# # NOTE : THIS MEANS THAT THE THERMAL OBJECT IS NOT PERMANENT, AS FULL, WIND AND SOLAR ARE
# # INDEED SO FAR I AM ONLY FOCUSING ON SOME FUELS (missing geothermic etc)
# THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel", "Oil")
# 
# thermal_generators_tbl <- filterClusters(full_2015_generators_tbl, THERMAL_TYPES)
# thermal_generators_tbl <- getThermalPropertiesTable(thermal_generators_tbl)
# 
# print(thermal_generators_tbl)

# So far we have "phase 1 thermal" with no variable costs. Let's go to work !

heat_rate_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
  filter(collection == "Generators" & property == "Heat Rate") %>%
  pivot_wider(names_from = property, values_from = value) %>%
  mutate(generator_name = toupper(child_object),
         heat_rate = `Heat Rate`
         ) %>%
  select(generator_name, heat_rate)


# print(heat_rate_tbl)

fuel_cost_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
  filter(collection == "Fuels" & property == "Price") %>%
  pivot_wider(names_from = property, values_from = value) %>%
  rename(fuel_group = child_object,
         fuel_cost = Price
         ) %>%
  select(fuel_group, fuel_cost)


# print(fuel_cost_tbl)

french_thermal_tbl <- full_2015_generators_tbl %>%
  filter(node == "EU-FRA" & cluster_type %in% THERMAL_TYPES) %>%
  left_join(heat_rate_tbl, by = "generator_name") %>%
  left_join(fuel_cost_tbl, by = "fuel_group") %>%
  mutate(variable_cost = heat_rate * fuel_cost) %>%
  select(generator_name, fuel_type, variable_cost)

print(french_thermal_tbl)

write.csv(french_thermal_tbl, ".\\output\\output_csvs\\french_thermal.csv", row.names = FALSE)

# emissions_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#   filter(parent_class == "Emission") %>%
#   pivot_wider(names_from = property, values_from = value) # ptet en faire un objet R global
# 
# # print(emissions_tbl)
# 
# emissions_tbl <- emissions_tbl %>%
#   # replace(is.na(.), 0) %>%
#   select(child_object, "Production Rate") %>%
#   mutate(fuel_group = child_object,
#          co2_emission = `Production Rate`/1000) %>% # it's in *tons*CO2/MWh in Antares
#   select(fuel_group, co2_emission)
# 
# # print(emissions_tbl)