library(dplyr)
library(tidyr)
library(lubridate)

image_profiles <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/industry_2015_image_profiles.rds")

# Function to shift the time series and adjust timeId based on a given timezone offset
shift_time_series <- function(data, shift_hours) {
  data %>%
    mutate(
      # Create datetime from the original columns
      datetime = make_datetime(year, month, day, hour),
      # Shift the datetime by the specified hours
      datetime_shifted = datetime - hours(shift_hours),
      # Extract the adjusted year, month, day, and hour
      # Year actually shouldn't change
      #year = year(datetime_shifted),
      month = month(datetime_shifted),
      day = day(datetime_shifted),
      hour = hour(datetime_shifted),
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
volumesMATER2015 = c(
  industry = 756440746 + 964867785 + 206486176 
  + 810017230 + 2097842974 + 958089158 + 231775314
  + 3067154595 + 2124112513 + 1092711323,
  # Agriculture + Aluminum primary production + Cement and clinker primary production 
  # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
  # + Other industries + Other materials production + Textile
  transport = 96139319 + 96695382,
  # Passenger transport + Freight
  residential = 6341838625,
  # Residential buildings
  service = 5581947974
  # Tertiary buildings
)

fra_ts <- getNodeTimeseries("eu-fra", industry_2015_image_profiles, volumesMATER2015["industry"])
# print(fra_ts)
