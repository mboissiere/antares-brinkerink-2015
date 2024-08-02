preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source(".\\src\\objects\\r_objects.R")

library(tidyr)

# print(full_2015_generators_tbl)

generators_tbl <- full_2015_generators_tbl %>%
  filter(fuel_type == "Hydro")

getHydroGeneratorsProperties <- function() {
  hydro_generators_tbl <- full_2015_generators_tbl %>%
    filter(fuel_type == "Hydro") %>%
    select(generator_name, node)
  
  hydro_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Generators") %>%
    mutate(generator_name = toupper(child_object)) %>%
    select(generator_name, property, value)
  
  hydro_generators_tbl <- hydro_generators_tbl %>%
    left_join(hydro_properties_tbl, by = "generator_name") %>%
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(nominal_capacity = `Max Capacity` * Units) %>%
    select(generator_name, node, nominal_capacity, `Max Capacity`, Units)
  
  hydro_generators_tbl <- hydro_generators_tbl %>%
    select(generator_name, node, nominal_capacity)
  
  return(hydro_generators_tbl)
}

hydro_generators_tbl <- getHydroGeneratorsProperties()
print(hydro_generators_tbl)

# Ah mais en vrai on va effectivement sommer par pays. 
# Et puis lire les monthly de Ninja en en faisant de l'horaire.
# Il faudrait d'ailleurs demander aux auteurs de Deane : dans les simus qui
# ont donné leurs graphiques, ont-ils utilisé 2015 ou 15 year average pour l'hydro.



# # Nota bene : vu comment marchent les Generators Hydro pour lesquels il y a
# # une timeseries mensuelle, je pense qu'on peut juste faire bourrinnement pour chaque centrale
# # décharge = max capacity x units x facteur de charge, sans séparer par centrale (pilotabilité des 5 units etc)
# # juste, du fait qu'on le met dans le run of river sur Antares (et même qu'on va tout accumuler en fait ??)
# # alors que les STEP on les modélise comme des Battery donc c'est Stockages dans Antares
# # donc faudra sûrement faire genre un (for k in nb_units) {créer une battery qui s'appelle battery_k}

# Bon, c'est pas clair ce que Nicolas veut que je fasse vu qu'il y a un onglet Hydro pour
# chaque noeud, donc pour chaque pays, alors que là j'ai des chroniques de FdC mensuelles
# par centrale.....

# Possible piste de mini-désobéissance : faire une modélisation Generator -> RoR
# et Battery -> Stockage, même si c'est moche, au moins j'aurai des graphes à montrer
# à Deane en envoyant un mail salé.



