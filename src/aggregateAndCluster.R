# Load necessary libraries
library(dplyr)
library(tidyr)
library(purrr) # vérifier si c'est utile ça et pourquoi

source(".\\src\\utils.R")
source("parameters.R")


# batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
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
    group_by(node, cluster_type, continent, battery_group, max_power, efficiency, capacity) %>% 
    # efficiency should be redundant with cluster type
    # and so is continent, battery group... technically this function isn't very robust because it's not even sure these columns exist
    # (again, i lose some levels of abstraction by preprocessing data then saving it to objects then reading it...)
    
    # aah !! i summed units for batteries that aren't functionally the same !! this is really bad i can't believe i almost let this slide
    # but what can i do... a mean of capacity perhaps ???
    # this is really weird if there's like 1 huge dam and 1 small dam...
    
    # going to keep this logic of only aggregating FUNCTIONALLY SIMILAR BATTERIES
    # in a way that is ONLY A PREPROCESSING OF K-MEANS CLUSTERING so it doesnt mess up later
    # this MEANS : GROUPING BY MAX POWER AND CAPACITY.
  summarize(
    total_units = sum(units), # lmao it's units here and nb_units there i s2g when will The Great Standardization come
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
           # capacity =  total_capacity,
           initial_state = 50, # it's always 50 # dunno if we should keep it as a percentage or not in tibble but eh
    ) %>%
    select(battery_name, continent, node, battery_group, cluster_type, units, capacity, max_power, efficiency, initial_state)
  
  return(aggregated_batteries_tbl)
}

# batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
# print(batteries_tbl, n = 50)
# 
# aggregated_batteries_tbl <- aggregateEquivalentBatteries(batteries_tbl)
# saveRDS(aggregated_batteries_tbl, ".\\src\\objects\\batteries_aggregated_tbl.rds")
# aggregated_batteries_tbl <- readRDS(".\\src\\objects\\batteries_aggregated_tbl.rds")
# print(aggregated_batteries_tbl, n  = 50)
# print(aggregated_batteries_tbl %>% select(-battery_group, -initial_state, -continent), n  = 50)

# Aggregation of batteries turns 1108 rows into 891 (THE OLD ONE THAT WAS BAD)
# Aggregation of batteries turns 1108 rows into 902 (the new one that seems less bad)

# # let's check that it worked well :
# print(batteries_tbl %>% filter(node == "AF-ZAF"), n = 50)
# print(aggregated_batteries_tbl %>% filter(node == "AF-ZAF"), n = 50)
# 
# # # A tibble: 8 x 10
# # battery_name                continent node   battery_group cluster_type units capacity max_power initial_state efficiency
# # <chr>                       <chr>     <chr>  <chr>         <chr>        <dbl>    <dbl>     <dbl>         <dbl>      <dbl>
# #   1 ZAF_CHE_RustenburgVRLAP1244 Africa    AF-ZAF Chemical Bat~ Battery          1     0.02      0.01            50         80
# # 2 ZAF_PHS_DrakensbergPump1245 Africa    AF-ZAF Pumped Hydro~ PSP_closed       5 18902.      200               50         75
# # 3 ZAF_PHS_PalmietPumpedSt1246 Africa    AF-ZAF Pumped Hydro~ PSP_closed       2  7561.      200               50         75
# # 4 ZAF_PHS_SteenbrasDamPum1247 Africa    AF-ZAF Pumped Hydro~ PSP_closed       1  3402.      180               50         75
# # 5 ZAF_THE_BokpoortConcent1248 Africa    AF-ZAF Thermal       Other1           1   440        55               50         50
# # 6 ZAF_THE_KaxuSolarOne1249    Africa    AF-ZAF Thermal       Other1           1   800       100               50         50
# # 7 ZAF_THE_KhiSolarOnePowe1250 Africa    AF-ZAF Thermal       Other1           1   400        50               50         50
# # 8 ZAF_THE_XinaSolarOnePow1251 Africa    AF-ZAF Thermal       Other1           1   800       100               50         50
# # > print(aggregated_batteries_tbl %>% filter(node == "AF-ZAF"), n = 50)
# # # A tibble: 7 x 10
# # battery_name                 continent node  battery_group cluster_type units capacity max_power efficiency initial_state
# # <chr>                        <chr>     <chr> <chr>         <chr>        <dbl>    <dbl>     <dbl>      <dbl>         <dbl>
# #   1 ZAF_CHE_RustenburgVRLAP1244  Africa    AF-Z~ Chemical Bat~ Battery          1     0.02      0.01         80            50
# # 2 ZAF_THE_KhiSolarOnePowe1250  Africa    AF-Z~ Thermal       Other1           1   400        50            50            50
# # 3 ZAF_THE_BokpoortConcent1248  Africa    AF-Z~ Thermal       Other1           1   440        55            50            50
# # 4 ZAF_THE_KaxuSolarOne1249_Xi~ Africa    AF-Z~ Thermal       Other1           2   800       100            50            50
# # 5 ZAF_PHS_SteenbrasDamPum1247  Africa    AF-Z~ Pumped Hydro~ PSP_closed       1  3402.      180            75            50
# # 6 ZAF_PHS_PalmietPumpedSt1246  Africa    AF-Z~ Pumped Hydro~ PSP_closed       1 15122.      400            75            50
# # 7 ZAF_PHS_DrakensbergPump1245  Africa    AF-Z~ Pumped Hydro~ PSP_closed       1 94510.     1000            75            50
# # 
# # Indeed, KaxuSolarOne and XinaSolarOne are truly similar.
# 
# 46 CHN_CHE_TheZhangbeiProj170                                        AS-C~ Battery          1  8   e+0     2             75
# 47 CHN_CHE_ZhangbeiNationa180                                        AS-C~ Battery          1  2.4 e+1     2             75
# 
# And those have the same max_power, but not the same capacity, so they are seperated.


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

clusteringForGenerators <- function(thermal_aggregated_tbl, 
                                    max_clusters
                                    # nodes # useful when you only want a subset of nodes, which is common
                                    # # in createStudy and testing...
                                    # # wait, the problem was simply a discrepancy between argument name and variable used in program lmao
                                    ) {
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

# Test on generators
thermal_aggregated_tbl <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
print("Thermal aggregated table :")
print(thermal_aggregated_tbl)

max_clusters = 15
thermal_clusters_tbl <- clusteringForGenerators(thermal_aggregated_tbl, max_clusters)
print(paste0(max_clusters,"-clustering for dataset:"))
print(thermal_clusters_tbl, n = 100)
saveRDS(object = thermal_clusters_tbl, file = paste0(".\\src\\objects\\thermal_",max_clusters,"-clustering_tbl.rds"))

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
  print(paste("df:", node))
  print(df, n = 25)
  if (nrow(df) > k) {
    clusters <- kmeans(df[, c("max_power", "capacity")], centers = k) # 2-dimensional clustering here !
    df$cluster <- as.factor(clusters$cluster)
  } else {
    df$cluster <- as.factor(1:nrow(df))
  }
  print(paste("df with clusters:", node))
  print(df, n = 25)
  
  summary <- df %>%
    group_by(cluster) %>%
    summarise(
      combined_names = paste0(
        unique(getPrefix(battery_name))[1],
        paste(
          unique(sapply(battery_name, removePrefix)),
          collapse = "_"
        )
      ),
      max_power = mean(max_power), 
      capacity = mean(capacity), 
      nb_units = sum(units),
      initial_state = 50,
      .groups = 'drop'
    )
  print(summary)
  
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
      clustered_data = map(data, ~ cluster_and_summarize_batteries(.x, k = max_clusters, node, cluster_type, efficiency))
    ) %>%
    unnest(clustered_data) %>%
    select(battery_name, node, cluster_type, nb_units, capacity, max_power, efficiency, initial_state)
  return(batteries_clusters_tbl)
}

# # Test on batteries
# 
# batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
# 
# batteries_aggregated_tbl <- readRDS(".\\src\\objects\\batteries_aggregated_tbl.rds")
# 
# max_clusters = 5
# batteries_clusters_tbl <- clusteringForBatteries(batteries_aggregated_tbl, max_clusters)
# 
# print("Batteries full table:")
# print(batteries_tbl, n = 50)
# 
# print("Batteries aggregated table:")
# print(batteries_aggregated_tbl, n = 50)
# 
# print(paste0(max_clusters,"-clustering for dataset:"))
# print(batteries_clusters_tbl, n = 50)
# 
# ###
# # Determining the best method of clustering for batteries is complicated for now. We can do this later.

