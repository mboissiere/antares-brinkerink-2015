DATA_PATH = file.path("input", "dataverse_files")
HYDRO_2015_PATH = file.path(DATA_PATH, "Hydro_Monthly_Profiles (2015).txt")
# Il faudra demander à Deane si c'est 2015 dans le papier ou la moyenne !
# Si c'est la moyenne... pourquoi alors avoir enlevé les centrales nucléaires japonaises ?

getTableFromHydro <- function(hydro_data_path) {
  tbl <- read.table(hydro_data_path,
                    header = TRUE,
                    sep = ",",
                    stringsAsFactors = FALSE,
                    encoding = "UTF-8",
                    check.names = FALSE
  )
  tbl$NAME <- toupper(tbl$NAME)
  tbl <- as_tibble(tbl)
  # names(tbl) <- toupper(names(tbl))
  # 
  # duplicate_columns <- which(duplicated(names(tbl)))
  # tbl <- tbl[ , -duplicate_columns]
  # tbl <- as_tibble(tbl)
  return(tbl)
}

hydro_2015_tbl <- getTableFromHydro(HYDRO_2015_PATH)
print(hydro_2015_tbl)
print(hydro_2015_tbl[1,])
print(hydro_2015_tbl[1,]$M1)
# Aaaah, il y a une nuance entre [1,] et [1] !
# et en prenant [1,] on peut prendre $M1, $M2, open...
# peut-etre faudrait refactorer les writeInputTS comme ça


# Pivot longer to transform the data
hydro_2015_tbl_long <- hydro_2015_tbl %>%
  pivot_longer(cols = -NAME, names_to = "Month", values_to = "Value")

# Pivot wider to transpose
hydro_2015_tbl_transposed <- hydro_2015_tbl_long %>%
  pivot_wider(names_from = NAME, values_from = Value)

source(".\\src\\utils\\timeSeriesConversion.R")
print(hydro_2015_tbl_transposed)
monthly_ts <- hydro_2015_tbl_transposed$`AFG_HYD_CAPACITY SCALER`
print(monthly_ts)
daily_ts <- monthly_to_daily(monthly_ts, 2015) #horizon actually #snakecase when it should be a function oops
print(daily_ts)


#####
# print(hydro_2015_tbl_transposed)

# # Convert to long format
# long_data <- hydro_2015_tbl_transposed %>%
#   pivot_longer(cols = -Month, names_to = "variable", values_to = "value")
# 
# # Repeat each value according to the number of days in the month
# daily_data <- long_data %>%
#   mutate(days = rep(days_in_month, times = n() / length(days_in_month))) %>%
#   uncount(days)
# 
# # Spread back to wide format if needed
# daily_data_wide <- daily_data %>%
#   group_by(variable) %>%
#   mutate(day = row_number()) %>%
#   pivot_wider(names_from = variable, values_from = value) %>%
#   select(-Month)
# 
# # Print the daily timeseries tibble
# print(daily_data_wide)

# Function to repeat values based on days in month
repeat_values <- function(values, days) {
  rep(values, times = days)
}

# Apply the function to each column except 'Month'
daily_data <- hydro_2015_tbl_transposed %>%
  select(-Month) %>%
  map_df(~repeat_values(.x, days_in_month))

# Create a date sequence for the daily data
date_sequence <- seq.Date(from = as.Date("2015-01-01"), by = "day", length.out = sum(days_in_month))

# Combine the date sequence with the daily data
daily_data <- tibble(Date = date_sequence, daily_data)

# Print the resulting daily timeseries tibble
print(daily_data)

## Dans l'idée on nettoie tout ça et on met dans timeSeriesConversion

# mais bon
# envie d'avoir un résultat là
#########################





# 
# pivot_longer(cols = starts_with("M"), names_to = "Month", values_to = "Value")
# Number of days in each month (non-leap year)

# days_in_month <- days_per_month(2015)
# print(days_in_month)

# # Generate the date sequence for the entire year
# dates <- seq.Date(from = as.Date("2015-01-01"), to = as.Date("2015-12-31"), by = "day")
# #print(dates)
# 
# # Create a vector of the month names corresponding to the dates
# month_labels <- rep(1:12, times = days_in_month)
# 
# # Function to repeat values according to days in month
# repeat_values <- function(values, days_in_month) {
#   unlist(mapply(function(value, days) rep(value, days), values, days_in_month, SIMPLIFY = FALSE))
# }
# 
# # Apply the function to each generator's values
# hydro_2015_tbl_daily <- hydro_2015_tbl_transposed %>%
#   mutate(across(-Month, ~repeat_values(.x, days_in_month))) %>%
#   mutate(Date = dates) %>%
#   select(Date, everything(), -Month)
# 
# print(hydro_2015_tbl_daily)


# > hydro_2015_tbl <- getTableFromHydro(HYDRO_2015_PATH)
# Error in `as_tibble()`:
#   ! Column name `USA_Win_MarshallWind325524` must not be duplicated.
# Use `.name_repair` to specify repair.
# Caused by error in `repaired_names()`:
#   ! Names must be unique.
# x These names are duplicated:
#   * "USA_Win_MarshallWind325524" at locations 4559 and 4560.
# Run `rlang::last_trace()` to see where the error occurred.
# > print(hydro_2015_tbl)
# Error in print(hydro_2015_tbl) : objet 'hydro_2015_tbl' introuvable
# 
# Ahlala faut tout faire ici !
# Mdr par contre j'ai importé le vent pas l'hydro oups



# ########## IMPORTS ##########
# 
# library(dplyr) # To be commented if the main script has that
# 
# ########## PARAMETERS ##########
#
# 
# 
# NINJA_PATH = file.path("input", "dataverse_files")
# 
# WIND_DATA_PATH = file.path(NINJA_PATH, "Renewables.ninja.wind.output.Full.adjusted.txt")
# PV_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Solar.farms.output.full.adjusted.txt")
# CSP_DATA_PATH = file.path(NINJA_PATH, "renewables.ninja.Csp.output.full.adjusted.txt")
# 
# getTableFromNinja <- function(ninja_data_path) {
#   tbl <- read.table(ninja_data_path,
#                     header = TRUE,
#                     sep = ",",
#                     stringsAsFactors = FALSE,
#                     encoding = "UTF-8",
#                     check.names = FALSE
#   )
#   names(tbl) <- toupper(names(tbl))
#   
#   duplicate_columns <- which(duplicated(names(tbl)))
#   tbl <- tbl[ , -duplicate_columns]
#   tbl <- as_tibble(tbl)
#   return(tbl)
# }
# 
# 
# 
# aggregateGeneratorTimeSeries <- function(generators_tbl, timeseries_data_path) {
#   
#   generators_tbl <- generators_tbl %>%
#     select(generator_name, node, nominal_capacity, units)
#   
#   nodes_studied <- generatoars_tbl$node
#   
#   timeseries_tbl <- getTableFromNinja(timeseries_data_path)
#   
#   product_tbl <- timeseries_tbl %>%
#     gather(key = "generator_name", value = "capacity_factor", -DATETIME) 
#   
#   
#   product_tbl <- product_tbl %>% 
#     left_join(generators_tbl, by = "generator_name") %>%
#     filter(node %in% nodes_studied)
#   
#   # 
#   product_tbl <- product_tbl %>%
#     mutate(power_output = units * nominal_capacity * capacity_factor / 100)
#   
#   product_tbl <- product_tbl %>%
#     select(DATETIME, node, power_output)
# 
#   
#   aggregated_tbl <- product_tbl %>%
#     group_by(DATETIME, node) %>%
#     summarize(node_power_output = sum(power_output, na.rm = FALSE), .groups = 'drop')
#   aggregated_tbl <- aggregated_tbl %>%
#     pivot_wider(names_from = node, values_from = node_power_output)
#   
#   return(aggregated_tbl)
# }
