# Load necessary libraries
library(dplyr)
library(tidyr)
library(purrr) # vérifier si c'est utile ça et pourquoi

source(".\\src\\utils.R")
source("parameters.R")

thermal_aggregated_tbl <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
print(thermal_aggregated_tbl)

batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
print(batteries_tbl)
print(batteries_tbl, n = 200)


aggregateEquivalentGenerators <- function(generators_tbl) {
  aggregated_generators_tbl <- generators_tbl %>%
    group_by(node, cluster_type, nominal_capacity, min_stable_power) %>%
  summarize(
    total_units = sum(nb_units),
    combined_names = paste0(
      unique(getPrefix(generator_name))[1],  # Extract and keep the prefix only once
      paste(
        unique(sapply(generator_name, removePrefix)),  # Remove the prefix and combine unique names
        collapse = "_"
      )
    ),
    avg_start_cost = mean(start_cost),
    avg_variable_cost = mean(variable_cost),
    avg_co2_emission = mean(co2_emission), 
    .groups = 'drop'
  ) 
  aggregated_generators_tbl <- aggregated_generators_tbl %>%
    mutate(generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
           nb_units = total_units,
           start_cost = avg_start_cost,
           variable_cost = avg_variable_cost,
           co2_emission = avg_co2_emission
    ) %>%
    select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, co2_emission, variable_cost, start_cost)
  
  return(aggregated_generators_tbl)
}


# Equivalent batteries are a different kind of beast...
# Is the goal of aggregate to fuse two objects which are functionally the same (eg exact same properties)
# or to make it easier to clusterize later on by removing all duplicates of the property we clusterize on (eg same nominal capapacity)
# it's quite complicated here, because batteries can have same max_power but very different capacity, and vice versa.....

# perhaps we should be freed of Deane's aggregation by multiplying capacity and max_power with units, obtaining effective numbers,
# and forcing nb_units back to 1 for everything. then, each battery truly represents the battery. that's kinda what the true aggregation is
# honestly.
# this helps because if there are max_power duplicates, we can sum capacities (and not have to watch out for units*capacity everytime)

# (i might want to keep track of what's the maximum level of disaggregation though...
# but that's already the case, with no aggregation and importing straight from Deane...)

# i reckon "cluster", "aggregate" and "import units seperately" are actually THREE different operations
# and might deserve three variables in config (or three modes : clustered, aggregated, disaggregated)
# (ah but what about the combinations ! you can have clustered disaggregated, aggregated not dissaggregated/seperate.. only thing you can't have is clustered not aggregated)
# yeah this is confusing as hell uhhhh

# a better name for this function would be aggregateBatteriesOnNominalCapacity
# and the same goes for equivalent generators
# (could we not in fact, disagregate / obtain generators with the true value, and then reaggregate using shoulder methods etc ?)
# ooh, I might like the average silhouette method https://www.datanovia.com/en/lessons/determining-the-optimal-number-of-clusters-3-must-know-methods/


batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
print(batteries_tbl)
print(batteries_tbl, n = 50)

aggregateEquivalentBatteries <- function(batteries_tbl) {
  # Aggregating and adjusting values
  aggregated_batteries_tbl <- batteries_tbl %>%
    mutate(
      capacity = capacity *  units,
      max_power = max_power * units,
      units = 1
    )
  
  print(aggregated_batteries_tbl, n = 50)
  
  aggregated_batteries_tbl <- aggregated_batteries_tbl %>%
    group_by(node, cluster_type, continent, battery_group, max_power, efficiency) %>% # efficiency should be redundant with cluster type
    # and so is continent, battery group... technically this function isn't very robust because it's not even sure these columns exist
    # (again, i lose some levels of abstraction by preprocessing data then saving it to objects then reading it...)
  summarize(
    total_units = sum(units), # lmao it's units here and nb_units there i s2g when will The Great Standardization come
    total_capacity = sum(capacity),
    combined_names = paste0(
      unique(getPrefix(battery_name))[1],  
      paste(
        unique(sapply(battery_name, removePrefix)),
        collapse = "_"
      )
    ),
    .groups = 'drop'
  ) 
  aggregated_batteries_tbl <- aggregated_batteries_tbl %>%
    mutate(generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
           units = total_units,
           capacity =  total_capacity,
           initial_state = 50, # it's always 50 # dunno if we should keep it as a percentage or not in tibble but eh
    ) %>%
    select(generator_name, continent, node, battery_group, cluster_type, units, capacity, max_power, efficiency, initial_state)
  
  return(aggregated_batteries_tbl)
}

aggregated_batteries_tbl <- aggregateEquivalentBatteries(batteries_tbl)
saveRDS(aggregated_batteries_tbl, ".\\src\\objects\\batteries_aggregated_tbl.rds")
aggregated_batteries_tbl <- readRDS(".\\src\\objects\\batteries_aggregated_tbl.rds")
print(aggregated_batteries_tbl, n  = 50)