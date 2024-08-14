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

# Function to perform clustering and aggregation
cluster_and_summarize <- function(df, k, node, cluster_type) {
  # Check if the number of rows is greater than k
  print(df)
  print(nrow(df) > k)
  if (nrow(df) > k) {
    # Perform k-means clustering on nominal_capacity
    clusters <- kmeans(df$nominal_capacity, centers = k)
    df$cluster <- as.factor(clusters$cluster)
  } else {
    # If there are fewer rows than k, each row becomes its own cluster
    df$cluster <- as.factor(1:nrow(df))
  }
  print(df)
  
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
  
  return(summary)
}

# Apply clustering and summarization
clustering_test <- thermal_generators_properties_tbl %>%
  group_by(node, cluster_type) %>%
  nest() %>%
  mutate(
    clustered_data = map(data, ~ cluster_and_summarize(.x, k = 5, node, cluster_type))
  ) %>%
  unnest(clustered_data) %>%
  select(-data)  # Remove `data` after unnesting

# View the result
print(clustering_test)

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

