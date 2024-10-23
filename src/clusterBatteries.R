source(".\\src\\aggregateAndCluster.R")
source(".\\src\\antaresCreateStudy_aux\\importThermal.R")
source(".\\src\\logging.R")

# Load necessary libraries
library(ggplot2)
library(dplyr)

# Assuming you have a data frame 'generator_data' with columns:
# 'country_node', 'nominal_capacity', and 'cluster'

batteries_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/full_2015_batteries_tbl.rds")
batteries_tbl <- batteries_tbl %>%
  filter(node == "eu-esp" & antares_cluster_type == "PSP_closed")
print(batteries_tbl)


batteries_tbl <- aggregateEquivalentBatteries(batteries_tbl)
print(batteries_tbl)

k = 1

clusters <- kmeans(batteries_tbl[, c("max_power", "capacity")], centers = k) # 2-dimensional clustering here !
batteries_tbl$cluster <- as.factor(clusters$cluster)
print(batteries_tbl)

batteries_tbl <- batteries_tbl %>%
  mutate(y_value = 0)

# Calculate cluster averages for plotting
cluster_averages <- batteries_tbl %>%
  group_by(cluster) %>%
  summarise(
    mean_power = mean(max_power, na.rm = TRUE),
    mean_capacity = mean(capacity, na.rm = TRUE)
  )

# Create the plot with 2D representation
ggplot(batteries_tbl, aes(x = max_power, y = capacity, color = cluster)) +
  geom_point() +  # Plot original points
  geom_point(data = cluster_averages, aes(x = mean_power, y = mean_capacity, fill = cluster), 
             size = 5, shape = 21, color = "black", stroke = 1.5) +  # Larger points for averages
  labs(
    title = paste0(k, "-clustering of pumped hydro batteries in Spain by max power and capacity"),
    x = "Max Power",
    y = "Capacity"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none"             # Remove legend
    #panel.grid.major.y = element_blank(),  # Remove major grid lines for y
    #panel.grid.minor.y = element_blank(),  # Remove minor grid lines for y
    #axis.ticks.y = element_blank(),        # Remove y-axis ticks
    #axis.text.y = element_blank()           # Remove y-axis text
  )