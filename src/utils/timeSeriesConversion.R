# # Load necessary library
# library(tidyverse)
source(".\\src\\utils.R")

# Number of days in each month

days_per_month <- function(year) {
  # Si je suis un omega-chad je réutilise ici le "is_leap_year"
  feb_days <- 28
  if (is_leap_year(year)) {
    feb_days <- 29
  }
  days_lst <- c(31, feb_days, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
}


days_in_month <- days_per_month(2015)
# print(days_in_month)

monthly_to_daily <- function(monthly_timeseries, year) { # should do a : year = horizon by default parameter (importing it here)
  days_in_month <- days_per_month(year)
  daily_timeseries <- rep(monthly_timeseries * 24, times = days_in_month) # and also apparently multiply by 24
  return(daily_timeseries)
}
# daily_timeseries <- rep(monthly_values, times = days_in_month)

# for (days in days_in_month) {
#   
# }

# # Generate the date sequence for the entire year
# dates <- seq.Date(from = as.Date("2015-01-01"), to = as.Date("2015-12-31"), by = "day")
# #print(dates)

# Ptn c'est compliqué psk je suis pas sûr de comprendre comment les hydro values vont s'importer


# Jvais faire du monthly pas daily


# # Function to convert monthly to hourly timeseries
# monthly_to_hourly <- function(monthly_values, days_in_month) {
#   unlist(mapply(function(value, days) rep(value, days * 24), monthly_values, days_in_month))
# }
# 
# # Apply the function to each row
# hourly_timeseries <- capacity_factors %>%
#   rowwise() %>%
#   mutate(hourly = list(monthly_to_hourly(c_across(M1:M12), days_in_month))) %>%
#   select(NAME, hourly) %>%
#   unnest(hourly)
# 
# # Display the result
# print(hourly_timeseries)
