# Faut que j'arrête de changer d'avis sur mon implémentation toutes les 30 secondes

preprocessPlexosData_module = file.path("src", "antaresCreateStudy_aux", "preprocessPlexosData.R")
source(preprocessPlexosData_module)
library(tidyr)

# Rappel : dans main on a un generators_tbl déjà, avec :
# generators_tbl <- getGeneratorsFromNodes(nodes)
# generators_tbl <- filterFor2015(generators_tbl)
# generators_tbl <- addGeneralFuelInfo(generators_tbl)

# thermal_types = c("Hard Coal")

filterClusters <- function(generators_tbl, thermal_types) {
  thermal_generators_tbl <- generators_tbl %>%
    filter(antares_cluster_type %in% thermal_types)

  return(thermal_generators_tbl)
}

# thermal_types = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")
# # thermal_types = c("Nuclear")
# thermal_generators_tbl <- filterClusters(generators_tbl, thermal_types)


library(data.table)
# Approche 1 :
# et mettre ça dans les data table
DEFAULT_FO_DURATION = 1
DEFAULT_PO_DURATION = 1
DEFAULT_FO_RATE = 0
DEFAULT_PO_RATE = 0
DEFAULT_NPO_MIN = 0
DEFAULT_NPO_MAX = 0

# Approche 2 :
daily_zeros <- matrix(0, 365)
daily_zeros_datatable <- as.data.table(daily_zeros)
daily_ones <- matrix(1, 365)
daily_ones_datatable <- as.data.table(daily_ones)
# Au choix..

hourly_zeros <- matrix(0, 8760)
hourly_zeros_datatable <- as.data.table(hourly_zeros)
hourly_ones <- matrix(1, 8760)
hourly_ones_datatable <- as.data.table(hourly_ones)


getThermalPropertiesTable <- function(thermal_generators_tbl) {
  thermal_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    
    mutate(generator_name = tolower(child_object)) %>%
    filter(collection == "Generators") 
  

  thermal_properties_tbl <- thermal_properties_tbl %>%
    select(generator_name, property, value) %>%
    
    
    filter(property %in% c("Max Capacity", "Start Cost", "Units", "Min Stable Factor", "Heat Rate", 
                           "Maintenance Rate", "Mean Time to Repair")) 
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    filter(active_in_2015) %>% #eh oui, il est là le check maintenant
    # (il faudra vraiment que ce soit qqch de clair dans les paramètres n'empeche)
    left_join(thermal_properties_tbl, by = "generator_name")
  
  # print(thermal_generators_tbl, n = 100)

  thermal_generators_tbl <- thermal_generators_tbl %>%
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(fo_rate = ifelse(is.na(`Maintenance Rate`), DEFAULT_FO_RATE, `Maintenance Rate`/100), # Default value in Antares is 0
           fo_duration = ifelse(is.na(`Mean Time to Repair`), DEFAULT_FO_DURATION, `Mean Time to Repair`/24) # Default value in Antares is 1
           )


  thermal_generators_tbl <- thermal_generators_tbl %>%
    rename(
      # nominal_capacity = "Max Capacity", ## already imported now
      start_cost = "Start Cost",
      # nb_units = "Units",
      min_stable_factor = "Min Stable Factor",
      heat_rate = "Heat Rate"
    ) %>%
    mutate(min_stable_power = nominal_capacity * min_stable_factor / 100) %>%
    select(generator_name, node, plexos_fuel_group, antares_cluster_type, nominal_capacity, start_cost, nb_units, 
           # min stable factor ?
           min_stable_power, heat_rate, fo_rate, fo_duration)

  # Time to add variable cost baybee
  emissions_and_prices_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Fuels") %>%
  # Hah y avait un pb pendant le pivot_wider vu comment y avait comme parent_object "System" ou "CO2"
  # et du coup bon courage pour mettre ça sur la même ligne
    select(child_object, property, value) %>%
  # print(emissions_and_prices_tbl, n=300)
    pivot_wider(names_from = property, values_from = value) # ptet en faire un objet R global
    # select(child_object, `Production Rate`, Price)

  # print(emissions_and_prices_tbl)

  emissions_and_prices_tbl <- emissions_and_prices_tbl %>%
    # replace(is.na(.), 0) %>%
    #select(child_object, "Production Rate") %>%
    rename(plexos_fuel_group = child_object,
           fuel_cost = Price,
           # so ! production rate is actually in kg/GJ
           # and heat rate is in GJ/MWh
           # therefore PR * HR is in kgCO2/MWh
           # indeed we need to divide by 1000 still, because in Antares it's in tons.
           #co2_emission = `Production Rate`/1000
           production_rate = `Production Rate`
    ) %>%
           # again, in TONS
 # it's in *tons*CO2/MWh in Antares

    select(plexos_fuel_group, fuel_cost, production_rate)

  # print(thermal_generators_tbl)
  # print(emissions_and_prices_tbl)

  thermal_generators_tbl <- thermal_generators_tbl %>%
    left_join(emissions_and_prices_tbl, by = "plexos_fuel_group")

  # print(thermal_generators_tbl)
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    #left_join(emissions_and_prices_tbl, by = "fuel_group") %>% oops, duplicate
    mutate(co2_production_rate = ifelse(is.na(production_rate), 0, production_rate),
           variable_cost = heat_rate * fuel_cost,
           co2_emission_kg = heat_rate * co2_production_rate,
           co2_emission = co2_emission_kg / 1000)
  
  # thermal_generators_test <- thermal_generators_tbl %>%
  #   select(generator_name, node, cluster_type, heat_rate, fuel_cost, variable_cost, co2_production_rate, co2_emission_kg, co2_emission)
  #   
  # print(thermal_generators_test)
  
  thermal_generators_tbl <- thermal_generators_tbl %>%
    select(generator_name, node, antares_cluster_type, nominal_capacity, nb_units, min_stable_power, 
           co2_emission, variable_cost, start_cost,
           fo_rate, fo_duration)
  
  # print(thermal_generators_tbl, n = 100)

  return(thermal_generators_tbl)
}

###################################

# This is going to be a bit tricky, because I'm realizing that CO2 emissions are dependant on heat rate
# eg different per generator, but also I will aggregate them.
# is the mean CO2 emission of two generators, the emission of the mean CO2 emissions ?
# Values shouldn't be TOO different, but still..


# # Les fonctions qui gèrent les strings sont maintenant dans utils !!
# source(".\\src\\utils.R")
#
# aggregateEquivalentGenerators <- function(generators_tbl) {
#   # generators_tbl <- test_thermal_properties # for temporary testing
#   aggregated_generators_tbl <- generators_tbl %>%
#     # filter(node == "AF-ZAF") %>% # for temporary testing
#     # A nest approach could be tempted but.. this really should work..
#     group_by(node, cluster_type, nominal_capacity, min_stable_power) %>% #, co2_emission, variable_cost, start_cost) %>%
#     # START COST CHANGES !! START COST ISNT DEPENDENT ON NOMINAL CAPACITY !! I GET LIKE 2952 FOR ZAF_COA_MATIMBAPOWERS
#     # AND 2954 FOR LETHABOPOWERS
#     # (...wait, it's not ? wow, the difference must be SO slight)
#     # but the moral of the story is : we're gonna clusterize on nominal capacity later on, so let's just aggregate via nominal capacity
#     # and i guess for the rest... averages ?
#
#     # ok yea, Sc is a polynomial of C, which iself is MWst/U so it depends on units
#     # and U is MWt/MWst (MW true / MW standard)
#     # so, it can vary.
#
#     # en fait, le vrai truc rigoureux de fou je pense, ce serait un mode qui aggregate ce qui est vraiment exactement les mêmes sur chaque paramètre
#   # puis, faire du clustering non pas sur nominal_capacity mais sur les objets de dimension n qui regroupent toutes les propriétés
#   # je soupçonne néanmoins que ça soit bcp plus lent.
#     summarize(
#       total_units = sum(nb_units),
#       combined_names = paste0(
#         unique(getPrefix(generator_name))[1],  # Extract and keep the prefix only once
#         paste(
#           unique(sapply(generator_name, removePrefix)),  # Remove the prefix and combine unique names
#           collapse = "_"
#         )
#       ),
#       avg_start_cost = mean(start_cost), # THIS IS A CHOICE.
#       # It might not be omega accurate (but we may be able to find the real formula
#       # if we use the polynomial from the paper)
#       # but you wanna know why it's not a priority ? coz AntaresFast doesn't use start cost lmao
#       avg_variable_cost = mean(variable_cost), # it was detected that variable cost can also change, while running a 20-cluster attempt
#       # and if that changes, I reckon other things might...
#       avg_co2_emission = mean(co2_emission),
#       # If I wanted to be very precise, I would probably also keep the min stable FACTOR in memory and divide from the nominal capacity again
#       .groups = 'drop'
#     )
#   # print(aggregated_generators_tbl)
#   #%>%
#   aggregated_generators_tbl <- aggregated_generators_tbl %>%
#     mutate(generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),  # Truncate the combined names
#            nb_units = total_units,
#            start_cost = avg_start_cost,
#            variable_cost = avg_variable_cost,
#            co2_emission = avg_co2_emission
#            ) %>%
#     select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, co2_emission, variable_cost, start_cost)
#
#   return(aggregated_generators_tbl)
# }
#
# test_thermal_properties <- readRDS(".\\src\\objects\\thermal_generators_properties_tbl.rds")
# # print(test_thermal_properties, n = 20)
# print(test_thermal_properties, n = 50)
#
# test_thermal_properties <- aggregateEquivalentGenerators(test_thermal_properties)
# # print(test_thermal_properties %>% filter(node == "AF-ZAF"), n = 25)
# # print(test_thermal_properties, n = 100)
# # print(test_thermal_properties$generator_name[87])
#
# saveRDS(test_thermal_properties, ".\\src\\objects\\thermal_aggregated_tbl.rds")
# test_thermal_properties <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
# print(test_thermal_properties)


addThermalToAntares <- function(thermal_generators_tbl) {

  for (row in 1:nrow(thermal_generators_tbl)) {
    generator_name = thermal_generators_tbl$generator_name[row] # NB : vu que j'extrais puis fait l'index,
    # mieux vaut extraire arrays une fois au début et puis indicer après non ?
    # je crois que c'est négligeable mais jsp
    node = thermal_generators_tbl$node[row]
    cluster_type = thermal_generators_tbl$antares_cluster_type[row]
    nominal_capacity = thermal_generators_tbl$nominal_capacity[row]
    nb_units = thermal_generators_tbl$nb_units[row]
    min_stable_power = thermal_generators_tbl$min_stable_power[row]
    
    co2_emission = thermal_generators_tbl$co2_emission[row]
    
    list_pollutants = list("co2"= co2_emission) # "nh3"= 0.25, "nox"= 0.45, "pm2_5"= 0.25, "pm5"= 0.25, "pm10"= 0.25, "nmvoc"= 0.25, "so2"= 0.25, "op1"= 0.25, "op2"= 0.25, "op3"= 0.25, "op4"= 0.25, "op5"= NULL)
    
    fo_rate = thermal_generators_tbl$fo_rate[row]
    
    fo_rate_matrix <- matrix(fo_rate, 365)
    fo_rate_datatable <- as.data.table(fo_rate_matrix)
    
    fo_duration = thermal_generators_tbl$fo_duration[row]
    fo_duration_matrix <- matrix(fo_duration, 365)
    fo_duration_datatable <- as.data.table(fo_duration_matrix)
    
    prepro_df <- data.frame(
      fo_duration = fo_duration_datatable,
      po_duration = daily_ones_datatable,
      fo_rate = fo_rate_datatable,
      po_rate = daily_zeros_datatable,
      npo_min = daily_zeros_datatable,
      npo_max = daily_zeros_datatable
    )
    
    default_modulation <- data.frame(
      mrg_cost_mod = hourly_ones_datatable,
      market_bid_mod = hourly_ones_datatable,
      capacity_mod = hourly_ones_datatable,
      min_gen_mod = hourly_zeros_datatable
    )
    
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
        
        list_pollutants = list_pollutants,
        prepro_data = prepro_df,
        prepro_modulation = default_modulation,
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

      msg = paste("[THERMAL] - Adding", generator_name, "generator to", node,"node...")
      logFull(msg)
      
      }, error = function(e) {
        msg = paste("[WARN] - Failed to add", generator_name, "generator to", node,"node, skipping...")
        logError(msg)
      })
  }
}

antares_solver_path <- ".\\antares\\AntaresWeb\\antares_solver\\antares-8.8-solver.exe"



activateThermalTS <- function() { # this would be better in LaunchSimulation i think
  # (would at least compensate lack of functions)
  # ah but wait no ! i risk wanting to put a CreateStudy on the VM without having done that.
  updateGeneralSettings(generate = "thermal",
                        refreshtimeseries = "thermal")
  updateInputSettings(import = c("thermal"))
  
  runTsGenerator(
    path_solver = antares_solver_path,
    show_output_on_console = TRUE # probably temporary
  )
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

# ######## QUICK TESTING
# base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds")
# thermal_generators_tbl <- filterClusters(base_generators_properties_tbl, THERMAL_TYPES)
# thermal_properties_tbl <- getThermalPropertiesTable(thermal_generators_tbl)
# 
# gas_properties_tbl <- thermal_properties_tbl %>%
#   filter(antares_cluster_type == "Gas") %>%
#   mutate(
#     brinkerink_type = case_when(
#     min_stable_power >= 0.3*nominal_capacity ~ "CCGT",
#     min_stable_power < 0.3*nominal_capacity ~ "OCGT",
#     TRUE ~ "Other"
#   )) %>%
#   select(generator_name, nominal_capacity, nb_units, min_stable_power, brinkerink_type)
# 
# print(gas_properties_tbl)
# 
# sum_tbl <- gas_properties_tbl %>% 
#   mutate(total_capacity = nominal_capacity * nb_units) %>%
#   group_by(brinkerink_type) %>%
#   summarise(total_capacity = sum(total_capacity),
#             nb_units = sum(nb_units),
#             nominal_capacity = sum(nominal_capacity)
#   )
# 
# print(sum_tbl)