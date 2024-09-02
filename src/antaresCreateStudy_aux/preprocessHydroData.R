DATA_PATH = file.path("input", "dataverse_files")
HYDRO_2015_PATH = file.path(DATA_PATH, "Hydro_Monthly_Profiles (2015).txt")
# Il faudra demander à Deane si c'est 2015 dans le papier ou la moyenne !
# Si c'est la moyenne... pourquoi alors avoir enlevé les centrales nucléaires japonaises ?

getCFTableFromHydro <- function(hydro_data_path) {
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
# this is a table of CAPACITY FACTORS


hydro_2015_tbl <- getCFTableFromHydro(HYDRO_2015_PATH)
print(hydro_2015_tbl)
# print(colnames(hydro_2015_tbl))

hydro_nominal_tbl <- readRDS(".\\src\\objects\\hydro_nominal_capacities_2015.rds")
print(hydro_nominal_tbl)

getProductionTableFromHydro <- function(hydro_CF_tbl, hydro_nominal_tbl) {
  combined_tbl <- hydro_CF_tbl %>%
    left_join(hydro_nominal_tbl, by = c("NAME" = "generator_name"))
  
  # Multiply the monthly values by the nominal capacity
  result_tbl <- combined_tbl %>%
    mutate(across(starts_with("M"), ~ . / 100 * nominal_capacity))
  return(result_tbl)
}

hydro_production_tbl <- getProductionTableFromHydro(hydro_2015_tbl, hydro_nominal_tbl)
print(hydro_production_tbl)

getCountryTableFromHydro <- function(hydro_production_tbl) {
  hydro_country_tbl <- hydro_production_tbl %>%
    group_by(node) %>%
    summarise(
      across(starts_with("M"), sum), # .names = "total_{col}"),
      total_nominal_capacity = sum(nominal_capacity)
    )
  
  return(hydro_country_tbl)
}

hydro_country_tbl <- getCountryTableFromHydro(hydro_production_tbl)


print(hydro_country_tbl)


# > print(hydro_country_tbl)
# # A tibble: 220 x 14
# node       M1     M2     M3     M4     M5     M6     M7      M8     M9    M10    M11     M12 total_nominal_capacity
# <chr>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>                  <dbl>
#   1 AF-AGO  667.   674.   651.   629.   606.   515.   453.   441.    480.   567.   656.   675.                     920.
# 2 AF-BDI   33.0   34.0   34.9   34.6   33.6   35.7   35.5   35.4    35.5   32.7   33.7   33.2                     49 
# 3 AF-BFA   10.0   10.1   11.2   10.8   12.3   10.8   10.6    9.42   10.8   11.4   11.3    9.83                    30 
# 4 AF-CAF   15.2   14.4   13.2   12.7   12.0   11.5   11.4   11.9    11.8   12.7   12.8   14.5                     19 
# 5 AF-CIV   69.5   75.6  119.   150.   186.   217.   174.   181.    227.   214.   153.    89.5                    599 
# 6 AF-CMR  467.   473.   522.   537.   559.   551.   529.   514.    533.   532.   542.   478.                     721.
# 7 AF-COD 1797.  1798.  1306.  1464.  1314.   853.   567.   483.    553.  1150.  1799.  1825.                    2805 
# 8 AF-COG  150.   151.   151.   120.    96.9   73.0   69.4   68.5    71.6   85.3  130.   151.                     219 
# 9 AF-DZA   19.9   21.9   18.1   17.2   16.8   15.7   14.5   14.7    12.7   17.4   17.2   19.9                    275 
# 10 AF-EGY 1495.  1478.  1503.  1700.  1664.  1629.  1251.  1247.   1329.  1658.  1844.  1608.                    2850 
# # i 210 more rows
# # i Use `print(n = ...)` to see more rows
# et là faudrait faire genre
# for node
# prendre la nominal capacity et la foutre dans antares
# prendre la ligne M1 M12 et la pivoter, étendre en timeseries journalières, et write input TS

# row = 10
# print(hydro_country_tbl[row,])

# On va faire une pause pour l'instant :
saveRDS(hydro_country_tbl,".\\src\\objects\\hydro_monthly_production_countries_2015_tbl.rds")







# #######################################
# # A noter que, si j'éais chaud, j'ajouterais des tests dans mon code. Genre là je mettrais :
# # ah oui c'est bon on a bien multiplié ? on a bien le production_tbl qui est égal à ce qu'on veut ?
# # avant d'aggregate ? et aggregate ça donne bien la somme des trucs ?
# # chose que je fais là à la mano avec des prints, mais voilà quoi..
# 
# 
# 
# # print(hydro_2015_tbl[1,])
# # print(hydro_2015_tbl[1,]$M1)
# # Aaaah, il y a une nuance entre [1,] et [1] !
# # et en prenant [1,] on peut prendre $M1, $M2, open...
# # peut-etre faudrait refactorer les writeInputTS comme ça
# 
# 
# # Pivot longer to transform the data
# hydro_2015_tbl_long <- hydro_2015_tbl %>%
#   pivot_longer(cols = -NAME, names_to = "Month", values_to = "Value")
# 
# # Pivot wider to transpose
# hydro_2015_tbl_transposed <- hydro_2015_tbl_long %>%
#   pivot_wider(names_from = NAME, values_from = Value)
# 
# source(".\\src\\utils\\timeSeriesConversion.R")
# print(hydro_2015_tbl_transposed)
# # monthly_ts <- hydro_2015_tbl_transposed$`AFG_HYD_CAPACITY SCALER`
# # print(monthly_ts)
# # daily_ts <- monthly_to_daily(monthly_ts, 2015) #horizon actually #snakecase when it should be a function oops
# # print(daily_ts)
# 
# 
# #####
# # print(hydro_2015_tbl_transposed)
# 
# # # Convert to long format
# # long_data <- hydro_2015_tbl_transposed %>%
# #   pivot_longer(cols = -Month, names_to = "variable", values_to = "value")
# # 
# # # Repeat each value according to the number of days in the month
# # daily_data <- long_data %>%
# #   mutate(days = rep(days_in_month, times = n() / length(days_in_month))) %>%
# #   uncount(days)
# # 
# # # Spread back to wide format if needed
# # daily_data_wide <- daily_data %>%
# #   group_by(variable) %>%
# #   mutate(day = row_number()) %>%
# #   pivot_wider(names_from = variable, values_from = value) %>%
# #   select(-Month)
# # 
# # # Print the daily timeseries tibble
# # print(daily_data_wide)
# 
# # Function to repeat values based on days in month
# repeat_values <- function(values, days) {
#   rep(values, times = days)
# }
# 
# # Apply the function to each column except 'Month'
# daily_data <- hydro_2015_tbl_transposed %>%
#   select(-Month) %>%
#   map_df(~repeat_values(.x, days_in_month))
# 
# # Create a date sequence for the daily data
# date_sequence <- seq.Date(from = as.Date("2015-01-01"), by = "day", length.out = sum(days_in_month))
# 
# # Combine the date sequence with the daily data
# daily_data <- tibble(Date = date_sequence, daily_data)
# 
# # Print the resulting daily timeseries tibble
# print(daily_data)
# 
# # saveRDS(daily_data, file = ".\\src\\objects\\hydro_daily_capacity_factors_2015.rds")
# 
# 
# ## En fait jsuis un énorme bouffon psk après faut aggregate par pays toujours
# 
# 
# 
# ## Dans l'idée on nettoie tout ça et on met dans timeSeriesConversion
# 
# # mais bon
# # envie d'avoir un résultat là
# # et attention tout ça ce sont des : facteurs de charge !
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 






















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
