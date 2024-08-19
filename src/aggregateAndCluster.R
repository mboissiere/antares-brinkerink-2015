# Load necessary libraries
library(dplyr)
library(tidyr)
library(purrr) # vérifier si c'est utile ça et pourquoi

source(".\\src\\utils.R")
source("parameters.R")


batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
# print(batteries_tbl)
# print(batteries_tbl, n = 200)


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

#######
# # Redoing aggregation because it didn't have variable cost in current RDS
# thermal_properties <- readRDS(".\\src\\objects\\thermal_generators_properties_tbl.rds")
# print(thermal_properties %>% filter(node == "NA-CAN-ON"), n = 25)
# print(thermal_properties, n = 50)
# 
# aggregated_thermal <- aggregateEquivalentGenerators(thermal_properties)
# 
# saveRDS(aggregated_thermal, ".\\src\\objects\\thermal_aggregated_tbl.rds")
# aggregated_thermal <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
# print(aggregated_thermal %>% filter(node == "NA-CAN-ON"), n = 25)
# print(aggregated_thermal, n = 50)
# # New aggregation results : from 11,692 total thermal to 7,532


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


aggregateEquivalentBatteries <- function(batteries_tbl) {
  # Aggregating and adjusting values
  aggregated_batteries_tbl <- batteries_tbl %>%
    mutate(
      capacity = capacity *  units,
      max_power = max_power * units,
      units = 1
    )
  
  # print(aggregated_batteries_tbl, n = 50)
  
  aggregated_batteries_tbl <- aggregated_batteries_tbl %>%
    group_by(node, cluster_type, continent, battery_group, max_power, efficiency) %>% # efficiency should be redundant with cluster type
    # and so is continent, battery group... technically this function isn't very robust because it's not even sure these columns exist
    # (again, i lose some levels of abstraction by preprocessing data then saving it to objects then reading it...)
    
    # aah !! i summed units for batteries that aren't functionally the same !! this is really bad i can't believe i almost let this slide
    # but what can i do... a mean of capacity perhaps ???
    # this is really weird if there's like 1 huge dam and 1 small dam...
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
    mutate(battery_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
           units = total_units,
           capacity =  total_capacity,
           initial_state = 50, # it's always 50 # dunno if we should keep it as a percentage or not in tibble but eh
    ) %>%
    select(battery_name, continent, node, battery_group, cluster_type, units, capacity, max_power, efficiency, initial_state)
  
  return(aggregated_batteries_tbl)
}

batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
print(batteries_tbl, n = 50)

aggregated_batteries_tbl <- aggregateEquivalentBatteries(batteries_tbl)
saveRDS(aggregated_batteries_tbl, ".\\src\\objects\\batteries_aggregated_tbl.rds")
aggregated_batteries_tbl <- readRDS(".\\src\\objects\\batteries_aggregated_tbl.rds")
print(aggregated_batteries_tbl, n  = 50)

# Aggregation of batteries turns 1108 rows into 891

######################

cluster_and_summarize_generators <- function(df, k, node, cluster_type) {
  # print("df:")
  # print(df)
  # Check if the number of rows is greater than k
  if (nrow(df) > k) {
    # Perform k-means clustering on the aggregated data's nominal_capacity
    clusters <- kmeans(df$nominal_capacity, centers = k)
    df$cluster <- as.factor(clusters$cluster)
  } else {
    # If there are fewer rows than k, each row becomes its own cluster
    df$cluster <- as.factor(1:nrow(df))
  }
  # print("df with clusters")
  # print(df)
  
  # Summarize the clusters
  summary <- df %>%
    group_by(cluster) %>%
    summarise(
      combined_names = paste0(
        unique(getPrefix(generator_name))[1],  # Extract and keep the prefix only once
        paste(
          unique(sapply(generator_name, removePrefix)),  # Remove the prefix and combine unique names
          collapse = "_"
        )
      ),
      nominal_capacity = mean(nominal_capacity), 
      # ça ça dégage non ?
      # ou alors c'est une mesure de sécurité sinon il dit "euh ça existe pas" alors qu'on sait que c'est clusteré nous intérieurement
      # This method can probably be generalized with properties lists
      nb_units = sum(nb_units),
      min_stable_power = mean(min_stable_power),
      co2_emission = mean(co2_emission),
      variable_cost = mean(variable_cost), # Include other relevant columns
      start_cost = mean(start_cost),
      .groups = 'drop'
    )
  # print(summary)
  # prints are super interesting to keep track of clustering.
  # perhaps create a seperate clusteringLog ?
  
  summary <- summary %>%
    mutate(
      generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
      node = node, # the lines seem silly, but they're actually deeply necessary
      # for accessing node and cluster type within the nested df, and aggregate
      cluster_type = cluster_type
    )
  # print(summary)
  
  return(summary %>% select(-node, -cluster_type, -combined_names))  
}

clusteringForGenerators <- function(aggregated_generators_tbl, max_clusters) {
  # Apply clustering and summarization
  thermal_clusters_tbl <- thermal_aggregated_tbl %>%
    group_by(node, cluster_type) %>%
    nest() %>%
    mutate(
      clustered_data = map(data, ~ cluster_and_summarize_generators(.x, k = max_clusters, node, cluster_type))
    ) %>%
    unnest(clustered_data) %>%
    select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, co2_emission, variable_cost, start_cost)
  return(thermal_clusters_tbl)
}

#############

# # Test on generators
# thermal_aggregated_tbl <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
# print("Thermal aggregated table :")
# print(thermal_aggregated_tbl)
# 
# max_clusters = 25
# thermal_clusters_tbl <- clusteringForGenerators(thermal_aggregated_tbl, max_clusters)
# print(paste0(max_clusters,"-clustering for dataset:"))
# print(thermal_clusters_tbl, n = 100)
# # saveRDS(object = thermal_clusters_tbl, file = ".\\src\\objects\\thermal_5clustering_tbl.rds")

# # View the result
# # print(clustering_test, n = 200)
# 
# saveRDS(object = clustering_test, file = ".\\src\\objects\\thermal_20clustering_tbl.rds")
# clustering_test <- readRDS(".\\src\\objects\\thermal_20clustering_tbl.rds")
# print(clustering_test, n = 200)

#######################

cluster_and_summarize_batteries <- function(df, k, node, cluster_type, efficiency) { # continent, battery_group)
  # on met en argument tout ce qu'on regarde pas du coup ? tout ce qui st pareil ?
  # faisons avec le moins de redondance pour l'instant.
  print("df:")
  print(df)
  # Check if the number of rows is greater than k
  if (nrow(df) > k) {
    # Perform k-means clustering on the aggregated data's nominal_capacity
    clusters <- kmeans(df$max_power, centers = k)
    df$cluster <- as.factor(clusters$cluster)
  } else {
    # If there are fewer rows than k, each row becomes its own cluster
    df$cluster <- as.factor(1:nrow(df))
  }
  print("df with clusters")
  print(df)
  
  # Summarize the clusters
  summary <- df %>%
    group_by(cluster) %>%
    summarise(
      combined_names = paste0(
        unique(getPrefix(battery_name))[1],  # Extract and keep the prefix only once
        paste(
          unique(sapply(battery_name, removePrefix)),  # Remove the prefix and combine unique names
          collapse = "_"
        )
      ),
      # max_power = mean(max_power),
      # Testons sans ?
      # pareil sans efficiency
      units = sum(units),
      capacity = sum(capacity),
      initial_state = 50,
      .groups = 'drop'
    )
  print(summary)
  # prints are super interesting to keep track of clustering.
  # perhaps create a seperate clusteringLog ?
  
  summary <- summary %>%
    mutate(
      battery_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
      node = node, # the lines seem silly, but they're actually deeply necessary
      # for accessing node and cluster type within the nested df, and aggregate
      cluster_type = cluster_type,
      efficiency = efficiency
    )
  print(summary)
  
  return(summary %>% select(-node, -cluster_type, -efficiency, -combined_names))  
}

clusteringForBatteries <- function(batteries_aggregated_tbl, max_clusters) {
  # Apply clustering and summarization
  
  # Note : for batteries, you ALWAYS gotta check that the units are 1 first.
  # because in the above method
  # remember : aggregation put units to 1, but then it summed capacities 
  # wait.......
  # i might have double counted if i sum power and capacity but don't sum units.
  # no ! first i sum power and capacity and put units to 1.
  # THEN i aggregate batteries IF THEY ARE FUNCTIONALLY THE SAME
  # let's hope i did a groupby max_power AND capacity and not just max_power, else there is double counting
  #
  #....
  batteries_clusters_tbl <- batteries_aggregated_tbl %>%
    group_by(node, cluster_type, efficiency) %>%
    nest() %>%
    mutate(
      clustered_data = map(data, ~ cluster_and_summarize_generators(.x, k = max_clusters, node, cluster_type, efficiency))
    ) %>%
    unnest(clustered_data) %>%
    select(battery_name, node, cluster_type, units, capacity, max_power, efficiency, initial_state)
  return(batteries_clusters_tbl)
}

# Test on batteries

batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
print("Batteries full table:")
print(batteries_tbl, n = 50)

batteries_aggregated_tbl <- readRDS(".\\src\\objects\\batteries_aggregated_tbl.rds")
print("Batteries aggregated table:")
print(batteries_aggregated_tbl, n = 50)

max_clusters = 10
batteries_clusters_tbl <- clusteringForGenerators(batteries_aggregated_tbl, max_clusters)
print(paste0(max_clusters,"-clustering for dataset:"))
print(batteries_clusters_tbl, n = 50)
# saveRDS(object = thermal_clusters_tbl, file = ".\\src\\objects\\thermal_5clustering_tbl.rds")
