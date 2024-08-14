# functions_path = file.path("src", "data", "dataFunctions.R")
# source(functions_path)

# objectsPath = file.path("src", "data", "dataObjects.R")
# source(objectsPath)



# TODO : add CO2 emission factors by importing the "Emissions" category in Properties
# https://www.rte-france.com/en/eco2mix/co2-emissions#:~:text=standard%20plant%20efficiency.-,The%20contribution%20of%20each%20energy%20source%20to%20C02%20emissions%20is,MWh%20for%20gas%2Dturbine%20plants
# ^ ordre de grandeur / valeur utilisée par RTE pour le tCO2eq/MWh


# Mdr faut que j'arrête de changer d'avis sur mon implémentation toutes les 30 secondes

preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)
library(tidyr)

# Rappel : dans main on a un generators_tbl déjà, avec :
# generators_tbl <- getGeneratorsFromNodes(nodes)
# generators_tbl <- filterFor2015(generators_tbl)
# generators_tbl <- addGeneralFuelInfo(generators_tbl)

# It's probably good to implement a cluster_types that asks which ones to add
# Or, do a addOil, addMixedFuel etc? Not necessarily easier...

# NB : la fonction va probablement avoir se scinder pour avoir genre
# addCoal, addGas etc puisque celles-ci auront des propriétés différentes !!
# pour tout ce qui est la contrainte de rampe etc
# mais en même temps, pour avoir le tableau avec tout, c'est pratique.... hm...
# une fonction addCoalCluster ? mais qui garde getThermalGenerators ?
# ou tant pis on rechange à chaque fois quitte à juste faire la même fonction avec filter
# ou alors alors, une fonction mère donc cette fonction en est une implémentation filter(variable) ?
# thermal_types = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")
# thermal_types = c("Hard Coal")

filterClusters <- function(generators_tbl, thermal_types) {
  thermal_generators_tbl <- generators_tbl %>%
    filter(cluster_type %in% thermal_types)
  
  return(thermal_generators_tbl)
}

# thermal_generators_tbl <- filterClusters(generators_tbl, thermal_types)
# print(thermal_generators_tbl)

# # nodes <- c("EU-CHE", "EU-DEU", "EU-FRA")
# nodes <- c("EU-FRA", "AF-MAR", "AS-JPN-CE", "NA-CAN-QC", "OC-NZL", "SA-CHL")
# # nodes <- c("AS-JPN-CE")
# # Ok donc c'est là
# generators_tbl <- getGeneratorsFromNodes(nodes)
# generators_tbl <- filterFor2015(generators_tbl)
# generators_tbl <- addGeneralFuelInfo(generators_tbl)

# print(generators_tbl)
# 
# thermal_types = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")
# # thermal_types = c("Nuclear")
# thermal_generators_tbl <- filterClusters(generators_tbl, thermal_types)
# 
# print(thermal_generators_tbl)

getThermalPropertiesTable <- function(thermal_generators_tbl) {
  thermal_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    #mutate(child_object = toupper(child_object)) %>% # aie aie aie la structure de mon code
    # mais qui en fait est nécessaire vu comment j'ai bidouillé apply2015Filter
    # (il faudrait peut-être mettre les generators en majuscule dès l'étape getTableFromPLEXOS...)
    # en fait non
    # # A l'inverse : i In argument: `!generator_name %in% generator_names_to_remove`.
    # Caused by error in `generator_name %in% generator_names_to_remove`:
    # ! objet 'generator_name' introuvable
    # Il faudra sérieusement que j'ai une structure claire à mon code........
    rename(generator_name = child_object) %>%
    mutate(generator_name = toupper(generator_name)) %>%
    filter(collection == "Generators") # faudrait vérifier que je fasse bien ce test sur d'autres trucs
    # penser en fait à faire le 2015 filter dès qu'il faut, je le fais pas au niveau des propriétés
  # or c'est justement là que ça cloche
  
  # Enft le problème est que j'ai conçu le truc pour rendre l'enlevage de centrales problématiques
  # dès la partie generators globale, mais du coup elle ne compte qu'à partir du left join.
  # donc, il faut left join avant de pivot_wider sinon ça fait des vecteurs.
  # VAMOS c'était bien ça (misère...)
  
  # print(thermal_properties_tbl)
  
  # thermal_properties_tbl <- apply2015ConstructionFilter(thermal_properties_tbl)
  # thermal_properties_tbl <- apply2015NuclearFilter(thermal_properties_tbl)
  
  thermal_properties_tbl <- thermal_properties_tbl %>%
    select(generator_name, property, value) %>%
    # Ah, it's the capital letters that's causing all the problems.. Was good practice for Ninja
    # but now it's bad practice because we're pulling from the same dataset
    # Oh well
    filter(property %in% c("Max Capacity", "Start Cost", "Units", "Min Stable Factor", "Heat Rate"))
    # NB : there will be more but we'll take it easy
    # notably, nb units needs to be adressed because it returns vectors given scenarios
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    left_join(thermal_properties_tbl, by = "generator_name")

  thermal_generators_tbl <- thermal_generators_tbl %>%
    pivot_wider(names_from = property, values_from = value)
  
  # print(thermal_generators_tbl)
  # # Y a de l'hydro là-dedans, c'est louche. J'ai fait le left_join pourtant.
  # NN mais j'étais juste un abruti et j'ai mis le truc non filtré
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    rename(
      nominal_capacity = "Max Capacity",
      start_cost = "Start Cost",
      nb_units = "Units",
      min_stable_factor = "Min Stable Factor",
      heat_rate = "Heat Rate"
    ) %>%
    mutate(min_stable_power = nominal_capacity * min_stable_factor / 100) %>%
  #   <error/dplyr:::mutate_error>
  #   Error in `mutate()`:
  #   i In argument: `min_stable_power = nominal_capacity * min_stable_factor/100`.
  # Caused by error in `nominal_capacity * min_stable_factor`:
  #   ! argument non numérique pour un opérateur binaire
    ########## Etonnamment, une valeur qui pop pas pour le jeu de test CHE-DEU-FRA
    # mais qui pop pour le NA-CAN-QC, AF-MAR...
    select(generator_name, node, fuel_group, cluster_type, nominal_capacity, start_cost, nb_units, min_stable_power, heat_rate)
  
  # Time to add CO2 emissions (basically why we kept fuel_type now)
  # Attention c'est NA pour le nuc !
  
  # Time to add variable cost baybee
  emissions_and_prices_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Fuels") %>%
  # Hah y avait un pb pendant le pivot_wider vu comment y avait comme parent_object "System" ou "CO2"
  # et du coup bon courage pour mettre ça sur la même ligne
  # yessai
    select(child_object, property, value) %>%
  # print(emissions_and_prices_tbl, n=300)
    pivot_wider(names_from = property, values_from = value) # ptet en faire un objet R global
    # select(child_object, `Production Rate`, Price)
    
  # print(emissions_and_prices_tbl)

  emissions_and_prices_tbl <- emissions_and_prices_tbl %>%
    # replace(is.na(.), 0) %>%
    #select(child_object, "Production Rate") %>%
    mutate(fuel_group = child_object,
           fuel_cost = Price,
           co2_emission = `Production Rate`/1000) %>% # it's in *tons*CO2/MWh in Antares
    # en fait vrmt le production rate c'est quoi ptn
    select(fuel_group, fuel_cost, co2_emission)

  # print(thermal_generators_tbl)
  # print(emissions_and_prices_tbl)
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    left_join(emissions_and_prices_tbl, by = "fuel_group") %>%
    mutate(co2_emission = ifelse(is.na(co2_emission), 0, co2_emission),
           variable_cost = heat_rate * fuel_cost) %>%
    select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, co2_emission, variable_cost, start_cost)
  
  return(thermal_generators_tbl)
}

# test_thermal_properties <- readRDS(".\\src\\objects\\thermal_generators_properties_tbl.rds")
# # print(test_thermal_properties, n = 20)
# print(test_thermal_properties, n = 50)
# 
# # Define function to get the prefix of a generator name
# getPrefix <- function(generator_name) {
#   prefix <- substring(generator_name, 1, 8)
#   return(prefix)
# }
# 
# # Define function to remove the prefix from a generator name
# removePrefix <- function(generator_name) {
#   gen_no_prefix <- substring(generator_name, 9)
#   return(gen_no_prefix)
# }
# #
# # getGeneratorNameWithoutPrefix <- function(generator_name) {
# #   gen_no_prefix <- substring(generator_name, 9)
# #   return(gen_no_prefix)
# # }
# # test <- getGeneratorNameWithoutPrefix("AGO_GAS_CAPACITY SCALER")
# # print(test)
# 
# # And lets test the character limit in Antares
# # This is a 10-character string :
# # ABCDEABCDE
# # 50 OK
# # AAAAABBBBBCCCCCDDDDDEEEEEAAAAABBBBBCCCCCDDDDDEEEEE
# # 60 OK
# # 80 OK
# # 85 OK
# # 88 !! # 88 is maximum and 89 bugs
# 
# # Define function to truncate string to a maximum length
# truncateString <- function(name, max_length = 88) {
#   if (nchar(name) > max_length) {
#     return(substring(name, 1, max_length))
#   }
#   return(name)
# }
# 
# # INFO [2024-08-14 14:10:45] [THERMAL] - Adding DEU_BIO_BIOMASSGENERAT10962 generator to EU-DEU node...
# # ERROR [2024-08-14 14:10:46] [WARN] - Failed to add DEU_WAS_AHKWNEUNKIRCHE10873_BIOMASSGENERAT10950_HEIZKRAFTWERKK11270_KLRANLAGE11381_WASTEINCINERAT11791 generator to EU-DEU node, skipping...
# # # et pourtant !!
# 
# # Vectorize the truncateString function to handle vectors
# truncateStringVec <- Vectorize(truncateString)
# 
# aggregateEquivalentGenerators <- function(generators_tbl) {
#   aggregated_generators_tbl <- generators_tbl %>%
#     group_by(node, cluster_type, nominal_capacity, min_stable_power, co2_emission, variable_cost, start_cost) %>%
#     summarize(
#       total_units = sum(nb_units),
#       combined_names = paste0(
#         unique(getPrefix(generator_name))[1],  # Extract and keep the prefix only once
#         paste(
#           sapply(generator_name, removePrefix),  # Remove the prefix from each name
#           collapse = "_"
#         )
#       ),
#       .groups = 'drop'
#     ) %>%
#     mutate(generator_name = truncateStringVec(combined_names, 88),
#            nb_units = total_units) %>%  # Rename and truncate the combined names
#     select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, co2_emission, variable_cost, start_cost)
#     # select(-combined_names, -total_units)  # Remove the temporary columns
# }
# 
# 
# test_thermal_properties <- aggregateEquivalentGenerators(test_thermal_properties)
# print(test_thermal_properties, n = 100)
# # print(test_thermal_properties$generator_name[87])
# 
# saveRDS(test_thermal_properties, ".\\src\\objects\\thermal_aggregated_tbl.rds")
# test_thermal_properties <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
# print(test_thermal_properties)

# Error in `mutate()`:
#   i In argument: `min_stable_power = nominal_capacity * min_stable_factor/100`.
# Caused by error in `nominal_capacity * min_stable_factor`:
#   ! argument non numérique pour un opérateur binaire
# Run `rlang::last_trace()` to see where the error occurred.

## Possible que ce soit une histoire de : pas toutes les centrales ont des min stable factor
# et donc sur certaines lignes après le pivot wider il y a du NA
# (Sauf que... non. C'est pas maintenance rate, ni mean time to repair)
# Normalement y en a partout


# full_2015_generators_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds")
# # # J'espère que ça a filtré quand même...
# # # full_2015_generators_tbl <- filterFor2015(full_2015_generators_tbl)
# # # Faudrait que je fasse de ce path une variable globale
# thermal_types <- c("Hard Coal", "Gas", "Nuclear")
# thermal_clusters_tbl <- filterClusters(full_2015_generators_tbl, thermal_types)
# thermal_clusters_tbl <- getThermalPropertiesTable(thermal_clusters_tbl)
# print(thermal_clusters_tbl)

# print(thermal_clusters_tbl)




addThermalToAntares <- function(thermal_generators_tbl) {
  
  for (row in 1:nrow(thermal_generators_tbl)) {
    generator_name = thermal_generators_tbl$generator_name[row] # NB : vu que j'extrais puis fait l'index,
    # mieux vaut extraire arrays une fois au début et puis indicer après non ?
    # je crois que c'est négligeable as fuck mais jsp
    node = thermal_generators_tbl$node[row]
    cluster_type = thermal_generators_tbl$cluster_type[row]
    nominal_capacity = thermal_generators_tbl$nominal_capacity[row]
    nb_units = thermal_generators_tbl$nb_units[row]
    min_stable_power = thermal_generators_tbl$min_stable_power[row]
    # J'ai quasiment tout des thermiques, mais ce serait bien que j'implémente les
    # Maintenance Rate et Mean Time To Repair, qui sont dans les données Deane également....
    co2_emission = thermal_generators_tbl$co2_emission[row]
    #test = paste("CO2 emission for", generator_name, "plant:", co2_emission)
    #print(test)
    list_pollutants = list("co2"= co2_emission) # "nh3"= 0.25, "nox"= 0.45, "pm2_5"= 0.25, "pm5"= 0.25, "pm10"= 0.25, "nmvoc"= 0.25, "so2"= 0.25, "op1"= 0.25, "op2"= 0.25, "op3"= 0.25, "op4"= 0.25, "op5"= NULL)
    
    variable_cost = thermal_generators_tbl$variable_cost[row]
    start_cost = thermal_generators_tbl$start_cost[row]
    tryCatch({
      createCluster(
        area = node,
        cluster_name = generator_name,
        group = cluster_type,
        unitcount = as.integer(nb_units),
        nominalcapacity = nominal_capacity,
        min_stable_power = min_stable_power, # Point d'attention : ça s'écrit avec des tirets dans le .ini
        # mais en fait c'est ... euh
        list_pollutants = list_pollutants,
        #...,
        #list_pollutants = NULL,
        #time_series = NULL,
        marginal_cost = variable_cost,
        startup_cost = start_cost,
        market_bid_cost = variable_cost,
        #prepro_data = NULL,
        #prepro_modulation = NULL,
        add_prefix = FALSE,
        overwrite = TRUE
        #opts = antaresRead::simOptions()
      )
      
      # Error in source(importThermal_module) : 
      #   src/data/importThermal.R:140:26: '=' inattendu(e)
      # 139:         nominalcapacity = nominal_capacity,
      # 140:         min-stable-power =
      #   ^
      ##### ???? what
      msg = paste("[THERMAL] - Adding", generator_name, "generator to", node,"node...")
      logFull(msg)
      # Oh, ce serait bien d'avoir le vrai nom ici, en pas capitalisé..... mais ça impliquerait de...
      # remove la capitalisation sur le thermique (ce qui serait logique) et de l'avoir que pour
      # les renouvelables qui seront comparés à Ninja
      # finalement faire une fonction genre .capitalise qu'on active ou non
      # au lieu de l'avoir dans l'implémentation direct........ argh oh well
      }, error = function(e) {
        msg = paste("[WARN] - Failed to add", generator_name, "generator to", node,"node, skipping...")
        logError(msg)
      })
  }
}

# According to rdrr.io documentation, parameters are in similar format to the .ini
# Will become very important for nuclear especially. Right now, will be ignored.
# Will add min stable power as Deane does though.

# [testThermique]
# group = Hard Coal
# name = testThermique
# enabled = True
# unitcount = 1
# nominalcapacity = 0.0
# gen-ts = use global
# min-stable-power = 0.0
# min-up-time = 1
# min-down-time = 1
# must-run = False
# spinning = 0.0
# volatility.forced = 0.0
# volatility.planned = 0.0
# law.forced = uniform
# law.planned = uniform
# marginal-cost = 0.0
# spread-cost = 0.0
# fixed-cost = 0.0
# startup-cost = 0.0
# market-bid-cost = 0.0
# co2 = 0.0
# nh3 = 0.0
# so2 = 0.0
# nox = 0.0
# pm2_5 = 0.0
# pm5 = 0.0
# pm10 = 0.0
# nmvoc = 0.0
# op1 = 0.0
# op2 = 0.0
# op3 = 0.0
# op4 = 0.0
# op5 = 0.0