library(dplyr)
library(tidyr)

node_regions_timezones_tbl <- readRDS(".\\src\\2060\\node_regions_timezones_tbl.rds")

source(".\\src\\2060\\sector_profiles_util.R")

IMAGE_COLUMNS = c("Canada", "USA", "Mexico", "Rest Central America", "Brazil", 
                "Rest South America", "Northern Africa", "Western Africa", "Eastern Africa",
                "Southern Africa", "Western Europe", "Central Europe", "Turkey", 
                "Ukraine +", "Asia-Stan", "Russia +", "Middle East", "India +", 
                "Korea", "China +", "Southeastern Asia", "Indonesia +", "Japan", 
                "Oceania", "Rest S.Asia", "Rest S.Africa")

NB_KWH_IN_MWH = 1000

# get2015CastilloProfiles <- function(castillo_data_path) {
#   tbl <- read.table(castillo_data_path,
#                     header = TRUE,
#                     sep = ",",
#                     dec = ".",
#                     stringsAsFactors = FALSE,
#                     encoding = "UTF-8",
#                     check.names = FALSE,
#                     fill = TRUE
#   )
#   tbl <- as_tibble(tbl)
#   tbl <- tbl %>%
#     filter(year == 2015)
#     #mutate(across(all_of(IMAGE_COLUMNS), ~ . / NB_KWH_IN_MWH)) #%>%
#     #mutate(World = rowSums(across(KWH_COLUMNS)))
#   return(tbl)
# }

# ## INDUSTRY ##
# industry_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekday_SSP2.txt"
# industry_weekday_tbl <- get2015CastilloProfiles(industry_weekday_datapath)
# 
# print(industry_weekday_tbl)
# study_year = 2015
# generate_sector_hourly_ts()
generateIMAGEprofiles <- function(study_year = 2015,
                                  weekday_tbl,
                                  weekend_tbl
                                  ) {
  image_tbl <- generate_blank_hourly_tbl(study_year)
  for (region in IMAGE_COLUMNS) {
    sector_ts <- generate_sector_hourly_ts(study_year, region, weekday_tbl, weekend_tbl)
    sector_total <- sum(sector_ts)
    
    image_tbl <- image_tbl %>%
      mutate({{ region }} := sector_ts/sector_total)
    print(image_tbl)
  }
  # !!!!!! JUST REALIZED ITS BETWEEN 1 AND 24 WHEN IT SHOULD BE 0 AND 23 IN ANTARES
  # image_tbl <- mutate(hour = hour %% 24)
  return(image_tbl)
}
# En fait non même pas parce que le décalage horaire...
# En fait si mais genre. Profil UTC * conso noeud (proportion qui) 
# +/- décalage horaire
image_profiles <- generateIMAGEprofiles(2015, industry_weekday_tbl, industry_weekend_tbl)
# image_profiles <- readRDS(".\\src\\2060\\industry_2015_image_profiles.rds")
print(image_profiles, n = 50)

saveRDS(image_profiles, ".\\src\\2060\\industry_2015_image_profiles.rds")

image_profiles <- generateIMAGEprofiles(2015, residential_weekday_tbl, residential_weekend_tbl)
# image_profiles <- readRDS(".\\src\\2060\\industry_2015_image_profiles.rds")
print(image_profiles, n = 50)

saveRDS(image_profiles, ".\\src\\2060\\residential_2015_image_profiles.rds")


image_profiles <- generateIMAGEprofiles(2015, transport_weekday_tbl, transport_weekend_tbl)
print(image_profiles, n = 50)

saveRDS(image_profiles, ".\\src\\2060\\transport_2015_image_profiles.rds")

image_profiles <- generateIMAGEprofiles(2015, service_weekday_tbl, service_weekend_tbl)
print(image_profiles, n = 50)

saveRDS(image_profiles, ".\\src\\2060\\service_2015_image_profiles.rds")




# 
# # Function to shift the time series by a given timezone offset (in hours)
# shift_time_series <- function(data, shift_hours) {
#   data %>%
#     mutate(
#       hour = hour + shift_hours,             # Adjust the hour column by the shift
#       timeId = (timeId + shift_hours) %% 24  # Shift timeId while keeping it within 1-24 for hourly cycles
#     ) %>%
#     # Handle the day/month/year change if needed
#     mutate(
#       day = ifelse(hour >= 24, day + 1, day),
#       hour = 1+ (hour %% 24)
#     )
# }
# 
# # Example usage
# shifted_image_profiles <- shift_time_series(image_profiles, 2)
# print(shifted_image_profiles, n = 50)
