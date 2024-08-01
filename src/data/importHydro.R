preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source(".\\src\\objects\\r_objects.R")

library(tidyr)

# print(full_2015_generators_tbl)

generators_tbl <- full_2015_generators_tbl %>%
  filter(fuel_type == "Hydro")

# print(generators_tbl)

# # Avant de faire un tableau pour l'import dans Antares, répondre à la demande
# # de Nicolas, qui est de produire un tableau (objet R ? CSV depuis objet R ?)
# # avec la somme des productions par technologie (et la méthodologie)
# 
# getHydroPropertiesTable <- function(generators_tbl) {
#   hydro_generators_tbl <- generators_tbl %>%
#     filter(fuel_type == "Hydro")
# 
#   properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#     filter(property %in% c("Max Capacity", "Units")) %>%
#     rename(generator_name = child_object) %>%
#     mutate(generator_name = toupper(generator_name)) %>%
#     select(generator_name, property, value)
# 
#   wind_properties_tbl <- wind_generators_tbl %>%
#     left_join(properties_tbl, by = "generator_name") %>%
#     pivot_wider(names_from = property, values_from = value)
# 
# 
#   wind_properties_tbl <- wind_properties_tbl %>%
#     rename(
#       nominal_capacity = "Max Capacity",
#       units = Units
#     ) %>%
#     select(generator_name, node, cluster_type, nominal_capacity, units)
# 
#   return(wind_properties_tbl)
# }
# 
# # Nota bene : vu comment marchent les Generators Hydro pour lesquels il y a
# # une timeseries mensuelle, je pense qu'on peut juste faire bourrinnement pour chaque centrale
# # décharge = max capacity x units x facteur de charge, sans séparer par centrale (pilotabilité des 5 units etc)
# # juste, du fait qu'on le met dans le run of river sur Antares (et même qu'on va tout accumuler en fait ??)
# # alors que les STEP on les modélise comme des Battery donc c'est Stockages dans Antares
# # donc faudra sûrement faire genre un (for k in nb_units) {créer une battery qui s'appelle battery_k}


getTotalHydroGeneratorsCapacityPerCountry <- function() {
  hydro_generators_tbl <- full_2015_generators_tbl %>%
    filter(fuel_type == "Hydro") %>%
    select(generator_name, node)
  
  print(hydro_generators_tbl)
  
  hydro_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    #filter(collection == "Batteries")
    filter(collection == "Generators") %>%
    mutate(generator_name = toupper(child_object)) %>%
    #rename(generator_name = child_object) %>%
    select(generator_name, property, value)
  # Et encore une fois, je me fais avoir par la capitalisation ! Bon Dieu !
  
  print(hydro_properties_tbl)
  
  hydro_generators_tbl <- hydro_generators_tbl %>%
    left_join(hydro_properties_tbl, by = "generator_name") %>%
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(nominal_capacity = `Max Capacity` * Units) %>%
    select(generator_name, node, nominal_capacity, `Max Capacity`, Units)
  
  print(hydro_generators_tbl, n = 100) # To check if multiplication was done ok
  
  hydro_generators_tbl <- hydro_generators_tbl %>%
    select(generator_name, node, nominal_capacity)
  
  # A ce stade du code, on a le nominal capacity. C'est déjà bien.
  # Dans ce qui suit on va perdre de l'info puisqu'on va agréger par pays.
  
  # Summarize total nominal capacity by node
  hydro_generators_tbl <- hydro_generators_tbl %>%
    group_by(node) %>%
    summarize(total_nominal_capacity = sum(nominal_capacity))
    
  return(hydro_generators_tbl)
  
  
}

getTotalHydroBatteriesCapacityPerCountry <- function() {
  hydro_batteries_tbl <- full_2015_batteries_tbl %>%
    filter(battery_group == "Pumped Hydro Storage") %>%
    mutate(nominal_capacity = max_power * units) %>%
    select(battery_name, node, nominal_capacity, max_power, units)
  
  print(hydro_batteries_tbl)
  
  hydro_batteries_tbl <- hydro_batteries_tbl %>%
    select(battery_name, node, nominal_capacity)
  
  print(hydro_batteries_tbl)
  
  hydro_batteries_tbl <- hydro_batteries_tbl %>%
    group_by(node) %>%
    summarize(total_nominal_capacity = sum(nominal_capacity))
  # # Summarize total nominal capacity by node
  # hydro_generators_tbl <- hydro_generators_tbl %>%
  #   group_by(node) %>%
  #   summarize(total_nominal_capacity = sum(nominal_capacity))
  
  return(hydro_batteries_tbl)
  
  
}




# hydro_generators_tbl <- getTotalHydroGeneratorsCapacityPerCountry()
# print(hydro_generators_tbl)
# write.csv(hydro_generators_tbl, ".\\output\\hydro_csv\\generator_objects.csv", row.names = FALSE)


hydro_batteries_tbl <- getTotalHydroBatteriesCapacityPerCountry()
print(hydro_batteries_tbl)
write.csv(hydro_batteries_tbl, ".\\output\\hydro_csv\\battery_objects.csv", row.names = FALSE)






