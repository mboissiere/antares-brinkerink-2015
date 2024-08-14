# Load necessary libraries
library(dplyr)
library(tidyr)
library(purrr)

thermal_generators_properties_tbl <- readRDS(".\\src\\objects\\thermal_generators_properties_tbl.rds")
print(thermal_generators_properties_tbl)
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
cluster_and_summarize <- function(df, k, node, cluster_type) {
  print("df:")
  print(df)
  # Aggregate rows with identical properties
  aggregated_df <- df %>%
    group_by(nominal_capacity, min_stable_power, co2_emission, variable_cost, start_cost) %>%
    summarize(total_nb_units = sum(nb_units), .groups = 'drop')
  
  print("aggregated df:")
  print(aggregated_df)
  # Check if the number of aggregated rows is greater than k
  if (nrow(aggregated_df) > k) {
    # Perform k-means clustering on the aggregated data's nominal_capacity
    clusters <- kmeans(aggregated_df$nominal_capacity, centers = k)
    aggregated_df$cluster <- as.factor(clusters$cluster)
  } else {
    # If there are fewer rows than k, each row becomes its own cluster
    aggregated_df$cluster <- as.factor(1:nrow(aggregated_df))
  }
  print("aggregated df with clusters:")
  print(aggregated_df)
  
  # Join the cluster information back to the original dataframe
  df_clustered <- df %>%
    left_join(aggregated_df %>% select(nominal_capacity, min_stable_power, co2_emission, variable_cost, start_cost, total_nb_units, cluster), 
              by = c("nominal_capacity", "min_stable_power", "co2_emission", "variable_cost", "start_cost")) %>%
    mutate(cluster = aggregated_df$cluster[match(df$nominal_capacity, aggregated_df$nominal_capacity)])
  
  print(df_clustered)
  print("clustered df:")
  df <- df_clustered
  
  # Summarize the clusters
  summary <- df %>%
    group_by(cluster) %>%
    summarise(
      generator_name = paste(unique(substring(gsub("^[^_]+_[^_]+_", "", generator_name), 1, 5)), collapse = "_"),
      nominal_capacity = mean(nominal_capacity),
      nb_units = sum(nb_units),
      min_stable_power = mean(min_stable_power),
      co2_emission = mean(co2_emission),
      variable_cost = mean(variable_cost),   # Include other relevant columns
      start_cost = mean(start_cost),
      .groups = 'drop'
    )
  print(summary)
  
  # Prepend the country and fuel type to the generated name
  summary <- summary %>%
    mutate(
      generator_name = paste0(node, "_", gsub(" ", "-", cluster_type), "_", generator_name),
      node = node,
      cluster_type = cluster_type
    )
  print(summary)
  
  #return(summary)
  return(summary %>% select(-node, -cluster_type))  # Exclude node and cluster_type
  # Will need to remove node and cluster_type, 
  # although it was useful back when aggregating and such,
  # the fact that it is duplicated will cause an error while unnesting later
}

# Apply clustering and summarization
clustering_test <- thermal_generators_properties_tbl %>%
  filter(cluster_type == "Mixed Fuel") %>%# for testing purposes, will speed things up
  group_by(node, cluster_type) %>%
  nest() %>%
  mutate(
    clustered_data = map(data, ~ cluster_and_summarize(.x, k = 10, node, cluster_type))
    # the number k can be changed and generalized !
  ) %>%
  # unnest_wider(clustered_data) %>%
  unnest(clustered_data) %>%
  select(-data)  # Remove `data` after unnesting

# View the result
print(clustering_test)

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

