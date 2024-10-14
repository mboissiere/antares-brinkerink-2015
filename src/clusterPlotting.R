source(".\\src\\aggregateAndCluster.R")
source(".\\src\\antaresCreateStudy_aux\\importThermal.R")
source(".\\src\\logging.R")

# Load necessary libraries
library(ggplot2)
library(dplyr)

# Assuming you have a data frame 'generator_data' with columns:
# 'country_node', 'nominal_capacity', and 'cluster'

base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds")
generators_tbl <- base_generators_properties_tbl %>%
  filter(node == "sa-chl" & antares_cluster_type == "Oil" & active_in_2015)
generators_tbl <- getThermalPropertiesTable(generators_tbl)
print(generators_tbl)


generators_tbl <- aggregateEquivalentGenerators(generators_tbl)
print(generators_tbl)

k = 20

clusters <- kmeans(generators_tbl$nominal_capacity, centers = k)
generators_tbl$cluster <- as.factor(clusters$cluster)
print(generators_tbl)

generators_tbl <- generators_tbl %>%
  mutate(y_value = 0)

# Calculate the average nominal capacity for each cluster
cluster_averages <- generators_tbl %>%
  group_by(cluster) %>%
  summarize(mean_capacity = mean(nominal_capacity))

# # Filter data for France (node "eu-fra")
# france_data <- generator_data %>%
#   filter(node == "eu-fra")

# Plot the data using ggplot2, adding larger points for cluster averages with same colors
ggplot(generators_tbl, aes(x = nominal_capacity, y = y_value, color = as.factor(cluster))) +
  geom_point() +  # Plot original points
  geom_point(data = cluster_averages, aes(x = mean_capacity, y = 0, fill = as.factor(cluster)), 
             size = 4, shape = 21, color = "black", stroke = 1.25) +  # Larger points for averages
  labs(
    title = paste0(k, "-clustering of oil generators in Chile by max capacity"),
    x = "Max Capacity (MW)",
    y = "",
    color = "Cluster",
    fill = "Cluster"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",             # Remove legend
    panel.grid.major.y = element_blank(),  # Remove major grid lines for y
    panel.grid.minor.y = element_blank(),  # Remove minor grid lines for y
    axis.ticks.y = element_blank(),        # Remove y-axis ticks
    axis.text.y = element_blank()           # Remove y-axis text
  )
  #theme_minimal() +
  #guides(color = guide_legend(ncol = 2), fill = guide_legend(ncol = 2))  # Set legend in 2 columns

