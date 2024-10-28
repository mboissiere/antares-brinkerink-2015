library(dplyr)
library(tidyr)
library(lubridate)

source(".\\src\\2060\\sector_profiles_util.R")

image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/industry_2015_image_profiles.rds")

##### ANTARES DOESNT HAVE SUB HOUR... WE CANNOT HANDLE NON-INTEGER TIME SHIFTS !!!
### Unless we interpolate but like cmon I don't have time for this.
# # Function to shift the time series with fractional hours and keep the year fixed
# shift_time_series <- function(data, shift_hours) {
#   data %>%
#     mutate(
#       # Create datetime from the original columns
#       datetime = make_datetime(year, month, day, hour),
#       # Shift the datetime by the specified hours (using seconds for fractional hours)
#       datetime_shifted = datetime - dseconds(shift_hours * 3600),  # Convert hours to seconds
#       # Extract the adjusted month, day, and hour while keeping the original year
#       month = month(datetime_shifted),
#       day = day(datetime_shifted),
#       hour = hour(datetime_shifted),
#       # Keep the original year
#       year = year,
#       # Adjust timeId by the hour shift and ensure it wraps between 1 and 8760
#       timeId = ((timeId - shift_hours - 1) %% 8760) + 1
#     ) %>%
#     # Drop temporary columns used for calculation
#     select(-datetime, -datetime_shifted) # %>%
#     # Sort the table by timeId in ascending order
#     # arrange(timeId)
# }
# print(image_profiles, n = 24)
# # Example usage
# shifted_image_profiles_simple <- shift_time_series(image_profiles, 6)
# shifted_image_profiles <- shift_time_series(image_profiles, 2.5)  # Shift from UTC+2.5 to UTC
# shifted_image_profiles_neg <- shift_time_series(image_profiles, -4.25)  # Shift from UTC-4.25 to UTC
# print(shifted_image_profiles_simple, n = 24)
# print(shifted_image_profiles, n = 24)
# print(shifted_image_profiles_neg, n = 24)
# 
# 
# Function to shift the time series with integer hours (rounded) and keep the year fixed
shift_time_series <- function(data, shift_hours) {
  # Round shift_hours to the nearest integer
  shift_hours <- round(shift_hours)
  
  data %>%
    mutate(
      # Create datetime from the original columns
      datetime = make_datetime(year, month, day, hour),
      # Shift the datetime by the specified integer hours
      datetime_shifted = datetime - hours(shift_hours),
      # Extract the adjusted month, day, and hour while keeping the original year
      month = month(datetime_shifted),
      day = day(datetime_shifted),
      hour = hour(datetime_shifted),
      # Keep the original year
      year = year,
      # Adjust timeId by the hour shift and ensure it wraps between 1 and 8760
      timeId = ((timeId - shift_hours - 1) %% 8760) + 1
    ) %>%
    # Drop temporary columns used for calculation
    select(-datetime, -datetime_shifted) %>%
    # Sort the table by timeId in ascending order
    arrange(timeId)
}



# # Example usage
# shifted_image_profiles <- shift_time_series(image_profiles, 2)  # Shift from UTC+2 to UTC
# shifted_image_profiles_neg <- shift_time_series(image_profiles, -4)  # Shift from UTC-4 to UTC
# print(image_profiles, n = 48)
# print(shifted_image_profiles, n = 48)
# print(shifted_image_profiles_neg, n = 48)

# node_regions_timezones_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/node_regions_timezones_tbl.rds")

getNodeTimeseries <- function(study_node, sector_profiles_tbl, mater_volume) {
  node_info_row <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/node_regions_timezones_tbl.rds") %>%
    filter(node == study_node)
  # print(node_info_row)
  region_name <- node_info_row %>% pull(region_name)
  # print(region_name)
  utc_delta <- node_info_row %>% pull(utc_delta)
  # print(utc_delta)
  node_proportion_to_world <- node_info_row %>% pull(node_proportion_to_world)
  # print(node_proportion_to_world)
  sector_profile_tbl <- sector_profiles_tbl %>%
    select(timeId, year, month, day, hour, {{ region_name }})
  # print(sector_profile_tbl)
  
  adjusted_sector_profile <- shift_time_series(sector_profile_tbl, utc_delta)
  # print(adjusted_sector_profile)
  regional_ts <- adjusted_sector_profile %>% pull({{ region_name }})
  # print(regional_ts)
  final_curve <- regional_ts * mater_volume * node_proportion_to_world
  # adjusted_sector_volume <- adjusted_sector_profile %>%
  #   mutate(load = {{ region_name }} * mater_volume * node_proportion_to_world)
  # print(adjusted_sector_volume)
  # regional_ts <- adjusted_sector_volume %>% pull(load)
  # print(regional_ts)
  return(final_curve)
}

industry_2015_image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/industry_2015_image_profiles.rds")
# volumesMATER2015 = c(
#   industry = 756440746 + 964867785 + 206486176 
#   + 810017230 + 2097842974 + 958089158 + 231775314
#   + 3067154595 + 2124112513 + 1092711323,
#   # Agriculture + Aluminum primary production + Cement and clinker primary production 
#   # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
#   # + Other industries + Other materials production + Textile
#   transport = 96139319 + 96695382,
#   # Passenger transport + Freight
#   residential = 6341838625,
#   # Residential buildings
#   service = 5581947974
#   # Tertiary buildings
# )

# fra_ts <- getNodeTimeseries("eu-fra", industry_2015_image_profiles, volumesMATER2015["industry"])
# print(fra_ts)

getNodesSectorVolumes <- function(sector_profiles_tbl, mater_volume, study_year = 2015) {
  deane_all_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
  base_tbl <- generate_blank_hourly_tbl(study_year)
  
  for (node in deane_all_nodes_lst) {
    node_ts <- getNodeTimeseries(node, sector_profiles_tbl, mater_volume)
    base_tbl <- base_tbl %>%
      mutate({{node}} := node_ts) # Important, le := !!
    print(base_tbl)
  }
  final_tbl <- base_tbl %>%
    mutate(World = rowSums(across(all_of(deane_all_nodes_lst))))
  return(final_tbl)
}

csv_path <- ".\\src\\2060\\csvs"

nodes_plus_world <- c(deane_all_nodes_lst, "World")

# industry_2015_image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/industry_2015_image_profiles.rds")
# 
# industry_hourly_volumes_tbl <- getNodesSectorVolumes(industry_2015_image_profiles, volumesMATER2015["industry"])
# print(industry_hourly_volumes_tbl)
# 
# saveRDS(industry_hourly_volumes_tbl, ".\\src\\2060\\industry_2015_volumes_tbl.rds")
# 
# write.table(industry_hourly_volumes_tbl,
#             file = file.path(csv_path, "hourly_industry_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE)
# 
# industry_daily_volumes_tbl <- industry_hourly_volumes_tbl %>%
#   group_by(year, month, day) %>%
#   summarise(across(all_of(nodes_plus_world), sum))
# 
# write.table(industry_daily_volumes_tbl,
#             file = file.path(csv_path, "daily_industry_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE
# )
# 
# # Somme trouvée sur World en faisant ça : 12309497814
# # > volumesMATER2015["industry"]
# # industry 
# # 12309497814 
# # LETSGOOO
# 
# 
# ## RESIDENTIAL
# 
# residential_2015_image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/residential_2015_image_profiles.rds")
# 
# residential_hourly_volumes_tbl <- getNodesSectorVolumes(residential_2015_image_profiles, volumesMATER2015["residential"])
# print(residential_hourly_volumes_tbl)
# 
# saveRDS(residential_hourly_volumes_tbl, ".\\src\\2060\\residential_2015_volumes_tbl.rds")
# 
# write.table(residential_hourly_volumes_tbl,
#             file = file.path(csv_path, "hourly_residential_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE)
# 
# residential_daily_volumes_tbl <- residential_hourly_volumes_tbl %>%
#   group_by(year, month, day) %>%
#   summarise(across(all_of(nodes_plus_world), sum))
# 
# write.table(residential_daily_volumes_tbl,
#             file = file.path(csv_path, "daily_residential_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE
# )
# 
# # Somme trouvée sur World en faisant ça : 6341838624.99999
# # > volumesMATER2015["residential"] 
# # 6341838625 
# 
# ##### TRANSPORT
# 
# transport_2015_image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/transport_2015_image_profiles.rds")
# 
# transport_hourly_volumes_tbl <- getNodesSectorVolumes(transport_2015_image_profiles, volumesMATER2015["transport"])
# print(transport_hourly_volumes_tbl)
# 
# saveRDS(transport_hourly_volumes_tbl, ".\\src\\2060\\transport_2015_volumes_tbl.rds")
# 
# write.table(transport_hourly_volumes_tbl,
#             file = file.path(csv_path, "hourly_transport_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE)
# 
# transport_daily_volumes_tbl <- transport_hourly_volumes_tbl %>%
#   group_by(year, month, day) %>%
#   summarise(across(all_of(nodes_plus_world), sum))
# 
# write.table(transport_daily_volumes_tbl,
#             file = file.path(csv_path, "daily_transport_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE
# )
# 
# # Somme trouvée sur World en faisant ça : 192834701
# # > volumesMATER2015["transport"]
# # transport 
# # 192834701 
# 
# 
# ##### SERVICE
# 
# service_2015_image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/service_2015_image_profiles.rds")
# 
# service_hourly_volumes_tbl <- getNodesSectorVolumes(service_2015_image_profiles, volumesMATER2015["service"])
# print(service_hourly_volumes_tbl)
# 
# saveRDS(service_hourly_volumes_tbl, ".\\src\\2060\\service_2015_volumes_tbl.rds")
# 
# write.table(service_hourly_volumes_tbl,
#             file = file.path(csv_path, "hourly_service_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE)
# 
# service_daily_volumes_tbl <- service_hourly_volumes_tbl %>%
#   group_by(year, month, day) %>%
#   summarise(across(all_of(nodes_plus_world), sum))
# 
# write.table(service_daily_volumes_tbl,
#             file = file.path(csv_path, "daily_service_UTC_2015.csv"),
#             sep = ";",
#             dec = ",",
#             quote = FALSE,
#             row.names = FALSE,
#             col.names = TRUE
# )

# Somme trouvée sur World en faisant ça : 5581947974
# > volumesMATER2015["service"]
# service 
# 5581947974 

### TOTAL
# 24426119114
# deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/deane_2015_load_tbl.rds")
# 
# deane_2015_load <- deane_2015_load_tbl %>%
#   mutate(World = rowSums(across(all_of(colnames(deane_2015_load_tbl))))) %>%
#   pull(World)
# 
# print(sum(deane_2015_load))

##### Et maintenant la même en 2060.
## Attention, on prend toujours le profil 2015. Juste, on prend les volumes MATER de 2060.

