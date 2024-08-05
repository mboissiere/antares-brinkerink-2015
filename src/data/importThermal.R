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
    filter(property %in% c("Max Capacity", "Start Cost", "Units", "Min Stable Factor"))
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
      min_stable_factor = "Min Stable Factor"
    ) %>%
    mutate(min_stable_power = nominal_capacity * min_stable_factor / 100) %>%
  #   <error/dplyr:::mutate_error>
  #   Error in `mutate()`:
  #   i In argument: `min_stable_power = nominal_capacity * min_stable_factor/100`.
  # Caused by error in `nominal_capacity * min_stable_factor`:
  #   ! argument non numérique pour un opérateur binaire
    ########## Etonnamment, une valeur qui pop pas pour le jeu de test CHE-DEU-FRA
    # mais qui pop pour le NA-CAN-QC, AF-MAR...
    select(generator_name, node, fuel_group, cluster_type, nominal_capacity, start_cost, nb_units, min_stable_power)
  
  # Time to add CO2 emissions (basically why we kept fuel_type now)
  # Attention c'est NA pour le nuc !
  emissions_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(parent_class == "Emission") %>%
    pivot_wider(names_from = property, values_from = value) # ptet en faire un objet R global

  # print(emissions_tbl)

  emissions_tbl <- emissions_tbl %>%
    # replace(is.na(.), 0) %>%
    select(child_object, "Production Rate") %>%
    mutate(fuel_group = child_object,
           co2_emission = `Production Rate`/1000) %>% # it's in *tons*CO2/MWh in Antares
    select(fuel_group, co2_emission)

  # print(emissions_tbl)
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    left_join(emissions_tbl, by = "fuel_group") %>%
    mutate(co2_emission = ifelse(is.na(co2_emission), 0, co2_emission)) %>%
    select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, start_cost, co2_emission)
  
  # print(generators_tbl)
  # print(thermal_properties_tbl)
  # left_join earlier ? there will be less pivoting if there's only the places we like
    
  return(thermal_generators_tbl)
}


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
# # J'espère que ça a filtré quand même...
# # full_2015_generators_tbl <- filterFor2015(full_2015_generators_tbl)
# # Faudrait que je fasse de ce path une variable globale
# thermal_types <- c("Hard Coal", "Gas", "Nuclear")
# thermal_clusters_tbl <- filterClusters(full_2015_generators_tbl, thermal_types)
# # print(thermal_clusters_tbl)
# 
# thermal_clusters_tbl <- getThermalPropertiesTable(thermal_clusters_tbl)
# print(thermal_clusters_tbl)




addThermalToAntares <- function(thermal_generators_tbl) {
  
  for (row in 1:nrow(thermal_generators_tbl)) {
    generator_name = thermal_generators_tbl$generator_name[row] # NB : vu que j'extrais puis fait l'index,
    # mieux vaut extraire arrays une fois au début et puis indicer après non ?
    # je crois que c'est négligeable as fuck mais jsp
    node = thermal_generators_tbl$node[row]
    cluster_type = thermal_generators_tbl$cluster_type[row]
    nominal_capacity = thermal_generators_tbl$nominal_capacity[row]
    start_cost = thermal_generators_tbl$start_cost[row]
    nb_units = thermal_generators_tbl$nb_units[row]
    min_stable_power = thermal_generators_tbl$min_stable_power[row]
    # J'ai quasiment tout des thermiques, mais ce serait bien que j'implémente les
    # Maintenance Rate et Mean Time To Repair, qui sont dans les données Deane également....
    co2_emission = thermal_generators_tbl$co2_emission[row]
    #test = paste("CO2 emission for", generator_name, "plant:", co2_emission)
    #print(test)
    list_pollutants = list("co2"= co2_emission) # "nh3"= 0.25, "nox"= 0.45, "pm2_5"= 0.25, "pm5"= 0.25, "pm10"= 0.25, "nmvoc"= 0.25, "so2"= 0.25, "op1"= 0.25, "op2"= 0.25, "op3"= 0.25, "op4"= 0.25, "op5"= NULL)
    tryCatch({
      createCluster(
        area = node,
        cluster_name = generator_name,
        group = cluster_type,
        unitcount = as.integer(nb_units),
        nominalcapacity = nominal_capacity,
        min_stable_power = min_stable_power, # Point d'attention : ça s'écrit avec des tirets dans le .ini
        # mais en fait c'est ... euh
        startup_cost = start_cost,
        list_pollutants = list_pollutants,
        #...,
        #list_pollutants = NULL,
        #time_series = NULL,
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