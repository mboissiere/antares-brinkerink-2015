# functions_path = file.path("src", "data", "dataFunctions.R")
# source(functions_path)

# objectsPath = file.path("src", "data", "dataObjects.R")
# source(objectsPath)


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
    pivot_wider(names_from = property, values_from = value) %>%
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
    select(generator_name, node, cluster_type, nominal_capacity, start_cost, nb_units, min_stable_power)
  
  # print(generators_tbl)
  # print(thermal_properties_tbl)
  # left_join earlier ? there will be less pivoting if there's only the places we like
    
  return(thermal_generators_tbl)
}

# # nodes <- c("EU-CHE", "EU-DEU", "EU-FRA")
# nodes <- c("EU-FRA", "AF-MAR", "AS-JPN-CE", "NA-CAN-QC", "OC-NZL", "SA-CHL")
# generators_tbl <- getGeneratorsFromNodes(nodes)
# generators_tbl <- filterFor2015(generators_tbl)
# generators_tbl <- addGeneralFuelInfo(generators_tbl)
# 
# # print(generators_tbl)
# 
# thermal_types = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")
# thermal_generators_tbl <- filterClusters(generators_tbl, thermal_types)
# thermal_generators_tbl <- getThermalPropertiesTable(thermal_generators_tbl)
# print(thermal_generators_tbl)

# Ah mais ces histoires d'opérateur binaire pour min_stable factor c'est ptet... Hm

# minStableLevelPercentages = c("Biomass" = 30,
#                               "Coal" = 30,
#                               "CCGT" = 40,
#                               "OCGT" = 20, # A-ha, so that's what it was with different gas values !
#                               # But wait, this means I should just..... extract the property directly lmao
#                               "Nuclear" = 60,
#                               "Oil" = 50
#                               )
#print(minStableLevelPercentages)

# coalParameters = c("unitcount" = as)
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
# 



# > print(generators_tbl)
# # A tibble: 2,683 x 6
# generator_name             continent     node      f1902uel_group        cluster_type fuel_type    
# <chr>                      <chr>         <chr>     <chr>             <chr>        <chr>        
#   1 CAN_BIO_BARNSAWMILL3582    North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 2 CAN_BIO_BROMPTONBIOMAS3568 North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 3 CAN_BIO_CHAPAIS3623        North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 4 CAN_BIO_DOLBEAU3712        North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 5 CAN_BIO_DOMTARWINDSO3713   North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 6 CAN_BIO_GATINEAUBOWAT3791  North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 7 CAN_BIO_HAUTEYAMASKAR3859  North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 8 CAN_BIO_LACHENAIELANDF3960 North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 9 CAN_BIO_LACHUTELFG3961     North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste
# 10 CAN_BIO_SAINTFLICIEN4305   North America NA-CAN-QC North America_Bio Mixed Fuel   Bio and Waste

