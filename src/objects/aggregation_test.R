# Load necessary libraries
library(dplyr)
library(tidyr)
library(purrr)

source(".\\src\\utils.R")
source("parameters.R")

thermal_aggregated_tbl <- readRDS(".\\src\\objects\\thermal_aggregated_tbl.rds")
print(thermal_aggregated_tbl)
# NOTA BENE : vérifier avec la formule qu'on a pour les marginaux,
# que la valeur moyenne du cout marginal est bien le coût marginal de la moyenne des centrales
# (genre, c'est sûrement une somme et du coup sommer/moyenner les centrales est ok)
# mais il faut tout de même le justifier...

# Ce serait bien aussi de vérifier que le clustering se fait bien genre
# de print/log/observer les capacités nominales résultantes et voir que c'est ok
# tests unitaires que les unités de la somme est bien la somme des unités, etc...

# NB : explorer peut-être différence entre k-means et k-medoids, et justifier
# choix de méthodes (ou assumer : k-medoids est mieux mais paltime)

# Function to perform clustering and aggregation
# Edit : no need for aggregation, it's now a feature of importThermal
cluster_and_summarize <- function(df, k, node, cluster_type) {
  print("df:")
  print(df)
  # Check if the number of rows is greater than k
  if (nrow(df) > k) {
    # Perform k-means clustering on the aggregated data's nominal_capacity
    clusters <- kmeans(df$nominal_capacity, centers = k)
    df$cluster <- as.factor(clusters$cluster)
  } else {
    # If there are fewer rows than k, each row becomes its own cluster
    df$cluster <- as.factor(1:nrow(df))
  }
  print("df with clusters")
  print(df)
  
  # # Join the cluster information back to the original dataframe
  # df_clustered <- df %>%
  #   left_join(aggregated_df %>% select(nominal_capacity, min_stable_power, co2_emission, variable_cost, start_cost, total_nb_units, cluster), 
  #             by = c("nominal_capacity", "min_stable_power", "co2_emission", "variable_cost", "start_cost")) %>%
  #   mutate(cluster = aggregated_df$cluster[match(df$nominal_capacity, aggregated_df$nominal_capacity)])
  # 
  # print(df_clustered)
  # print("clustered df:")
  # df <- df_clustered
  
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
      # generator_name = paste(unique(substring(gsub("^[^_]+_[^_]+_", "", generator_name), 1, 5)), collapse = "_"),
      # generator_name = {
      #   prefix <- unique(getPrefix(generator_name))[1]
      #   combined_names <- paste(unique(substring(removePrefix(generator_name), 1, 5)), collapse = "_")
      #   truncateStringVec(paste0(prefix, combined_names), 88)
      # },
      nominal_capacity = mean(nominal_capacity),
      nb_units = sum(nb_units),
      min_stable_power = mean(min_stable_power),
      co2_emission = mean(co2_emission),
      variable_cost = mean(variable_cost), # Include other relevant columns
      start_cost = mean(start_cost),
      .groups = 'drop'
    )
  print(summary)
  
  #There is no reason that commenting these lines should pose a problem...
  # Prepend the country and fuel type to the generated name
  summary <- summary %>%
    mutate(
      generator_name = truncateStringVec(combined_names, CLUSTER_NAME_LIMIT),
      # generator_name = paste0(node, "_", gsub(" ", "-", cluster_type), "_", generator_name),
      # # combined_names = paste0(
      # #   unique(getPrefix(generator_name))[1],  # Extract and keep the prefix only once
      # #   paste(
      # #     unique(sapply(generator_name, removePrefix)),  # Remove the prefix and combine unique names
      # #     collapse = "_"
      # #   )
      # # )
      node = node, # the lines seem silly, but they're actually deeply necessary
      # for accessing node and cluster type within the nested df, and aggregate
      cluster_type = cluster_type
    )
  print(summary)
  
  #return(summary)
  return(summary %>% select(-node, -cluster_type, -combined_names))  # Exclude node and cluster_type
  # Will need to remove node and cluster_type, 
  # although it was useful back when aggregating and such,
  # the fact that it is duplicated will cause an error while unnesting later
}

# Apply clustering and summarization
clustering_test <- thermal_aggregated_tbl %>%
  # filter(cluster_type == "Hard Coal") %>%# for testing purposes, will speed things up
  group_by(node, cluster_type) %>%
  nest() %>%
  mutate(
    clustered_data = map(data, ~ cluster_and_summarize(.x, k = 20, node, cluster_type))
    # the number k can be changed and generalized !
  ) %>%
  # unnest_wider(clustered_data) %>%
  unnest(clustered_data) %>%
  select(generator_name, node, cluster_type, nominal_capacity, nb_units, min_stable_power, co2_emission, variable_cost, start_cost)
  # select(-data)  # Remove `data` after unnesting

# View the result
# print(clustering_test, n = 200)
saveRDS(object = clustering_test, file = ".\\src\\objects\\thermal_20clustering_tbl.rds")
clustering_test <- readRDS(".\\src\\objects\\thermal_20clustering_tbl.rds")
print(clustering_test, n = 200)

# Un test du 10-clustering (on est généreux !) sur le Hard Coal fait passer 
# de 1636 lignes à 971.

# Essayons sur chaque type de thermique maintenant !

# Warning message:
#   There was 1 warning in `mutate()`.
# i In argument: `clustered_data = map(data, ~cluster_and_summarize(.x, k = 10, node, cluster_type))`.
# i In group 201: `node = "AS-IND-EA"` and `cluster_type = "Hard Coal"`.
# Caused by warning:
#   ! did not converge in 10 iterations 

# Bon pour l'avoir print, c'est bel et bien un warning et ça a bien convergé
# pour passer de 10 à 17 du coup

# Un test du 10-clustering sur tous les thermiques a fait passer le tableau
# de 7697 lignes à 4053.
# Un test du 5-clustering sur tous les thermiques a fait passer le tableau
# de 7697 lignes à 2675.
# Pour donner une idée, il y a 3006 thermiques en Asie, et le run tourne bien.


# Autre possible point de patch trouvé en faisant le 20-clustering :
# le variable cost, lui aussi, peut être amené à changer un peu avec même nominal capacity
# mais units différents. Un exemple :

# # A tibble: 21 x 7
# generator_name    nominal_capacity nb_units min_stable_power co2_emission variable_cost start_cost
# <chr>                        <dbl>    <dbl>            <dbl>        <dbl>         <dbl>      <dbl>
#   1 CAN_BIO_EASTLFG3~                1        3              0.3            0          21.6      1684.
# 2 CAN_BIO_ROBERTO_~                2        1              0.6            0          21.5      2004 
# 3 CAN_BIO_BENSFORT~                2        6              0.6            0          21.6      1811.
# 4 CAN_BIO_WESTLORN~                3        2              0.9            0          21.5      2140.
# 5 CAN_BIO_LAFLECHE~                4        1              1.2            0          21.5      2448 
# 6 CAN_BIO_BEAREROA~                5        2              1.5            0          21.3      2608 
# 7 CAN_BIO_WATERLOO~                5        1              1.5            0          21.5      2547 
# 8 CAN_BIO_BRITANNI~                6        3              1.8            0          21.3      2883.
# 9 CAN_BIO_CHAPLEAU~                7        1              2.1            0          21.3      3187 
# 10 CAN_BIO_WHITERIV~                8        1              2.4            0          21.2      3261 
# # i 11 more rows
# # i Use `print(n = ...)` to see more rows
# Error in `mutate()`:
#   i In argument: `clustered_data = map(data, ~cluster_and_summarize(.x, k = 20, node,
#                                                                     cluster_type))`.
# i In group 528: `node = "NA-CAN-ON"` and `cluster_type = "Mixed Fuel"`.
# Caused by error in `map()`:
#   i In index: 1.
# Caused by error in `kmeans()`:
#   ! more cluster centers than distinct data points.


########

# It works !!
# The smart thing to do would be to generalize this method in the script right now.
# The lazy thing to do is to create an r_object and just run a simulation right now.
# Hm..

# Nevermind it doesn't work anymore..

# deja aggregate without clustering ça serait pas mal nn ? mdrrr
# faudrait faire un AGGREGATE_THERMAL et AGGREGATE_AND_CLUSTER_THERMAL
# tout comme un AGGREGATE_BATTERIES tout simple ça reviendrait juste
# à changer la règle / la boucle for

##########

# I have a question concerning clustering algorithms. 
# Is it possible to generate automatically the amount of clusters, 
# depending on the dataset and what would "make sense" intuitively ? 
# For example, if I have values 10, 11, 10, 100, 110, 
# it's pretty clear that 2 clusters is a good answer. 
# But that might change from dataset to dataset.

## Réponse : oui mais c'est encore plus long. Il faut run plusieurs fois des k-means
# pour le quantifier. Pas très intéressant comme exercice ici par rapport
# à juste dire "limiter à 10 max" par exemple.

# 
# Yes, automatically determining the optimal number of clusters in a dataset is a common challenge in clustering tasks. Several methods can help determine a reasonable number of clusters, each with its strengths and limitations. Here are some of the most commonly used methods:
#   
#   1. Elbow Method
# The Elbow Method involves running k-means clustering with a range of cluster numbers 
# 𝑘
# k and plotting the sum of squared distances (within-cluster sum of squares) against 
# 𝑘
# k. The idea is to find the "elbow" point where adding more clusters yields only a small decrease in the sum of squared distances. The optimal number of clusters is often at this point.

# Apply the clustering and summarization within each country and fuel type
# clustering_test <- thermal_generators_properties_tbl %>%
#   group_by(node, cluster_type) %>%
#   nest() 
# 
# print(clustering_test)
# 
# 
# clustering_test <- clustering_test %>%
#   # mutate(
#   #   clustered_data = map2(data, node, cluster_type, 
#   #                         ~ cluster_and_summarize(.x, k = 5, node = .y, cluster_type = ..3))
#   # ) %>%
#   mutate(clustered_data = map(data, cluster_and_summarize, k = 2, node, cluster_type)) %>%
#   unnest(clustered_data) %>%
#   select(-data)

# # View the result
# print(clustering_test)



# df <- thermal_generators_properties_tbl
# # Apply the clustering and summarization within each country and fuel type
# clustering_test <- df %>%
#   group_by(node, cluster_type) %>%
#   nest()
# 
# print(clustering_test)
# 
# clustering_test <- clustering_test %>%
#   mutate(clustered_data = map(data, cluster_and_summarize, k = 2, node, cluster_type)) %>%  # 'data' is the name of the nested tibble column
#   unnest(clustered_data) %>%
#   select(-data)  # Remove the original nested column
# # View the result
# print(clustering_test)

