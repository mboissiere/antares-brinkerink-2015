# Load necessary libraries
library(dplyr)
library(tidyr)
library(purrr) # vérifier si c'est utile ça et pourquoi

source(".\\src\\utils.R")
source("parameters.R")

# Quand j'y pense... Un shoulder method doit être long au début, mais une fois
# que le nb optimal de cluster est trouvé... on peut le stocker dans un rds !


# batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")
# print(batteries_tbl)
# print(batteries_tbl, n = 200)


aggregateEquivalentGenerators <- function(generators_tbl) {
  # print("generators_tbl :")
  # print(generators_tbl)
  aggregated_generators_tbl <- generators_tbl %>%
    # group_by(node, cluster_type, nominal_capacity, min_stable_power, co2_emission) %>%
    group_by(node, antares_cluster_type, nominal_capacity, min_stable_power) %>%
    # waitwaitwait. aggregateEquivalent is for generators who are FUNCTIONALLY THE SAME.
    # or is it, uh... well we aggregate on nominal capacity and we want bugs to not be there
    # and we aggregate everything nominal capacity or that depends on it. but. uh.
    # bit confusing innit. 
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
    avg_fo_rate = mean(fo_rate),
    avg_fo_duration = mean(fo_duration),
    .groups = 'drop'
  ) 
  # print("aggregated_generators_tbl :")
  # print(aggregated_generators_tbl)
  
  aggregated_generators_tbl <- aggregated_generators_tbl %>%
    mutate(generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
           nb_units = total_units,
           start_cost = avg_start_cost,
           variable_cost = avg_variable_cost,
           co2_emission = avg_co2_emission,
           # co2_emission dépend vrmt seulement du fuel group pour le coup, un select avant devrait suffir
           fo_rate = avg_fo_rate,
           fo_duration = avg_fo_duration
    ) %>%
    select(generator_name, node, antares_cluster_type, nominal_capacity, nb_units, min_stable_power, 
           co2_emission, variable_cost, start_cost, fo_rate, fo_duration)
  # print("aggregated_generators_tbl :")
  # print(aggregated_generators_tbl)
  
  # msg = paste("[CLUSTERING] - Aggregated the functionally similar generators", 
  #             combined_names, 
  #             "into one generator :", 
  #             generator_name)
  # C'est vraiment, vraiment pas aussi simple que ça vu qu'on fait du vectoriel....
  # Il est pas impossible que cette feature on dise tant pis pour le aggregated.
  # Et sur le clustered à la rigueur pk pas.
  
  msg = "[CLUSTERING] - Aggregated functionally identical generators (same nominal capacity) together!"
  logFull(msg)
  # Faire un log "aggregated functionally similar" ET "clustered into"
  
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
    group_by(node, antares_cluster_type, continent, battery_group, max_power, efficiency, capacity) %>% 
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
  
  combined_names_lst <- summary %>% pull(combined_names)
  # print(combined_names_lst)
  generator_name_lst <- summary %>% pull(generator_name)
  # print(generator_name_lst)
  n_clusters <- length(combined_names_lst) # Not always k, can be less than
  # print(n_clusters)
  
  for (j in 1:n_clusters) {
    combined_names_j <- combined_names_lst[j]
    # C'est un bon premier truc. Ce serait un peu mieux en fait si on avait pas pris
    # combined names et donc on a pas le deu_bio_machin_truc_bidule, mais qu'on avait vraiment
    # la liste des trucs originaux : deu_bio_machin, deu_bio_truc...
    # Bon, mais c'est déjà un bon premier truc qui fait à peu près ce que je veux, on verra plus tard si j'ai
    # le temps d'améliorer
    generator_name_j <- generator_name_lst[j]
    if (combined_names_j != generator_name_j) {
      msg = paste("[CLUSTERING] - Clustered the similar generators",
                  combined_names_j,
                  "into one generator :",
                  generator_name_j)
      logFull(msg)
    }
  }
  
  aggregated_batteries_tbl <- aggregated_batteries_tbl %>%
    mutate(battery_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
           units = total_units,
           # capacity =  total_capacity,
           initial_state = 50, # it's always 50 # dunno if we should keep it as a percentage or not in tibble but eh
    ) %>%
    select(battery_name, continent, node, battery_group, antares_cluster_type, units, capacity, max_power, efficiency, initial_state)
  
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

cluster_and_summarize_generators <- function(df, k, node, antares_cluster_type) { # je pourrais ici, si je veux,
  # filtrer tout ce sur quoi je fais pas du clustering (donc co2_emission...)
  # pour le remettre plus tard
  # attention pas min_stable_power car min_stable_power peut changer avec la capacity.
  # min_stable_factor en revanche si on l'avait encore, oui.
  
  # print("df:")
  # print(df)
  # Check if the number of rows is greater than k
  initial_number <- nrow(df)
  if (initial_number > k) {
    # Perform k-means clustering on the aggregated data's nominal_capacity
    clusters <- kmeans(df$nominal_capacity, centers = k)
    df$cluster <- as.factor(clusters$cluster)
  } else {
    # If there are fewer rows than k, each row becomes its own cluster
    df$cluster <- as.factor(1:initial_number)
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
      fo_rate = mean(fo_rate),
      fo_duration = mean(fo_duration),
      .groups = 'drop'
    )
  # print("summary:")
  # print(summary)
  # prints are super interesting to keep track of clustering.
  # perhaps create a seperate clusteringLog ?
  
  summary <- summary %>%
    mutate(
      generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
      node = node, # the lines seem silly, but they're actually deeply necessary
      # for accessing node and cluster type within the nested df, and aggregate
      antares_cluster_type = antares_cluster_type
    )
  # ERROR [2024-08-21 00:42:08] [WARN] - Failed to add DEU_OIL_BRUNSBTTEL11000_WILMERSDORF11818_CAPACITY  generator to EU-DEU node, skipping...
  # à chaque fois il faut faire gaffe à l'espace à la fin, c'est putain de sûr
  # notons que ça veut dire que ptet le clustering a plusieurs choix et que mon algo est non-déterministe...
  # genre regarder si j'ai eu ça en oil la dernière fois.
  # print("summary:")
  # print(summary)
  
  combined_names_lst <- summary %>% pull(combined_names)
  # print(combined_names_lst)
  generator_name_lst <- summary %>% pull(generator_name)
  # print(generator_name_lst)
  n_clusters <- length(combined_names_lst) # Not always k, can be less than
  # print(n_clusters)
  
  for (j in 1:n_clusters) {
    combined_names_j <- combined_names_lst[j]
    # C'est un bon premier truc. Ce serait un peu mieux en fait si on avait pas pris
    # combined names et donc on a pas le deu_bio_machin_truc_bidule, mais qu'on avait vraiment
    # la liste des trucs originaux : deu_bio_machin, deu_bio_truc...
    # Bon, mais c'est déjà un bon premier truc qui fait à peu près ce que je veux, on verra plus tard si j'ai
    # le temps d'améliorer
    generator_name_j <- generator_name_lst[j]
    if (combined_names_j != generator_name_j) {
      msg = paste("[CLUSTERING] - Clustered the similar generators",
                  combined_names_j,
                  "into one generator :",
                  generator_name_j)
      logFull(msg)
    }
  }
  
  # if (initial_number > k) {
    
  # }
  
  return(summary %>% select(-node, -antares_cluster_type, -combined_names))  
}

# Possible truc que je pourrais faire pour la transparence du clustering tout ça :
# seulement crop le nom au moment de le mettre sur generator_name (comme je fais)
# mais qd meme sauver le combined names qqpart genre dans un log type
# created XXX_YYY_ZZZ cluster !
# que ça reste dans la mémoire même si y en a dix mille (ce qui ne sera pas le cas
# de l'étude antares, où l'on pourrait même raccourcir les noms si on voulait)
# et ce serait ptet mm plus transparent que de rogner direct des noms

clusteringForGenerators <- function(thermal_aggregated_tbl, 
                                    max_clusters
                                    # nodes # useful when you only want a subset of nodes, which is common
                                    # # in createStudy and testing...
                                    # # wait, the problem was simply a discrepancy between argument name and variable used in program lmao
                                    ) {
  # Apply clustering and summarization
  # print(thermal_aggregated_tbl)
  thermal_clusters_tbl <- thermal_aggregated_tbl %>%
    group_by(node, antares_cluster_type) %>%
    nest() %>%
    mutate(
      clustered_data = map(data, ~ cluster_and_summarize_generators(.x, k = max_clusters, node, antares_cluster_type))
    ) %>%
    unnest(clustered_data) %>%
    select(generator_name, node, antares_cluster_type, nominal_capacity, nb_units, min_stable_power, 
           co2_emission, variable_cost, start_cost, fo_rate, fo_duration)
  # print(thermal_clusters_tbl)
  return(thermal_clusters_tbl)
}

#############
# 
# # Test on generators
# thermal_aggregated_tbl <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
# print("Thermal aggregated table :")
# print(thermal_aggregated_tbl)
# 
# max_clusters = 15
# thermal_clusters_tbl <- clusteringForGenerators(thermal_aggregated_tbl, max_clusters)
# print(paste0(max_clusters,"-clustering for dataset:"))
# print(thermal_clusters_tbl, n = 100)
# saveRDS(object = thermal_clusters_tbl, file = paste0(".\\src\\objects\\thermal_",max_clusters,"-clustering_tbl.rds"))

# # View the result
# # print(clustering_test, n = 200)
# 
# saveRDS(object = clustering_test, file = ".\\src\\objects\\thermal_20clustering_tbl.rds")
# clustering_test <- readRDS(".\\src\\objects\\thermal_20clustering_tbl.rds")
# print(clustering_test, n = 200)

#######################

# mdr c'est un truc de fou j'ai des 26 batteries CHE qqfois alors que je précise pas plus de 10
# Well i'll be damned : c'est pas une bêtise du programme, il y a des CHE avec des efficacités différentes : 75, 80 et 90
# et vu qu'on fait des clusters sur le cluster_type mais aussi sur l'efficiency, eh bah checks out en fait.
# bon, côté nomenclature - le fait que sur Antares y ait 26 batteries, c'est quand même pas ouf.
# (.....faire d'efficiency une variable et non un truc de tri ? la question se pose.)

cluster_and_summarize_batteries <- function(df, k, node, antares_cluster_type, efficiency) { # continent, battery_group)
  # on met en argument tout ce qu'on regarde pas du coup ? tout ce qui st pareil ?
  # faisons avec le moins de redondance pour l'instant.
  # print(paste("df:", node))
  # print(df, n = 25)
  if (nrow(df) > k) {
    clusters <- kmeans(df[, c("max_power", "capacity")], centers = k) # 2-dimensional clustering here !
    df$cluster <- as.factor(clusters$cluster)
  } else {
    df$cluster <- as.factor(1:nrow(df))
  }
  # print(paste("df with clusters:", node))
  # print(df, n = 25)
  
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
      units = sum(units), # attention qqfois units, qqfois nb_units...
      initial_state = 50,
      .groups = 'drop'
    )
  # print(summary)
  
  summary <- summary %>%
    mutate(
      battery_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
      node = node, # the lines seem silly, but they're actually deeply necessary
      # for accessing node and cluster type within the nested df, and aggregate
      antares_cluster_type = antares_cluster_type,
      efficiency = efficiency
    )
  # print(summary)
  
  combined_names_lst <- summary %>% pull(combined_names)
  # print(combined_names_lst)
  battery_name_lst <- summary %>% pull(battery_name)
  # print(generator_name_lst)
  n_clusters <- length(combined_names_lst) # Not always k, can be less than
  # print(n_clusters)
  
  for (j in 1:n_clusters) {
    combined_names_j <- combined_names_lst[j]
    # C'est un bon premier truc. Ce serait un peu mieux en fait si on avait pas pris
    # combined names et donc on a pas le deu_bio_machin_truc_bidule, mais qu'on avait vraiment
    # la liste des trucs originaux : deu_bio_machin, deu_bio_truc...
    # Bon, mais c'est déjà un bon premier truc qui fait à peu près ce que je veux, on verra plus tard si j'ai
    # le temps d'améliorer
    battery_name_j <- battery_name_lst[j]
    if (combined_names_j != battery_name_j) {
      msg = paste("[BATTERIES] - Clustered the similar batteries",
                  # Différence entre ici BATTERIES et là-bas [CLUSTERING] mais en vrai
                  # le tag CLUSTERING présent dans deux process différents serait chelou
                  combined_names_j,
                  "into one battery :",
                  battery_name_j)
      logFull(msg)
    }
  }
  
  
  return(summary %>% select(-node, -antares_cluster_type, -efficiency, -combined_names))  
}

clusteringForBatteries <- function(batteries_aggregated_tbl, max_clusters) {
  # Note : slight incoherence because aggregation of batteries before clustering seems necessary here in argument
  # But, user can select to disable it..
  
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
    group_by(node, antares_cluster_type, efficiency) %>%
    nest() %>%
    mutate(
      clustered_data = map(data, ~ cluster_and_summarize_batteries(.x, k = max_clusters, node, antares_cluster_type, efficiency))
    ) %>%
    unnest(clustered_data) %>%
    select(battery_name, node, antares_cluster_type, units, capacity, max_power, efficiency, initial_state)
  # print(batteries_clusters_tbl)
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

