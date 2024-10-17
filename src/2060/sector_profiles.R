# End-use/sector: Industry sector total,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# Data: Monthly electricity demand for weekday,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# Unit: kWh,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,,,,,,,,,,,,

## ATTENTION !! kWh !!!

library(dplyr)
library(tidyr)

KWH_COLUMNS = c("Canada", "USA", "Mexico", "Rest Central America", "Brazil", 
                "Rest South America", "Northern Africa", "Western Africa", "Eastern Africa",
                "Southern Africa", "Western Europe", "Central Europe", "Turkey", 
                "Ukraine +", "Asia-Stan", "Russia +", "Middle East", "India +", 
                "Korea", "China +", "Southeastern Asia", "Indonesia +", "Japan", 
                "Oceania", "Rest S.Asia", "Rest S.Africa")

NB_KWH_IN_MWH = 1000

getTableFromCastillo <- function(castillo_data_path) {
  tbl <- read.table(castillo_data_path,
                    header = TRUE,
                    sep = ",",
                    dec = ".",
                    stringsAsFactors = FALSE,
                    encoding = "UTF-8",
                    check.names = FALSE,
                    fill = TRUE
  )
  tbl <- as_tibble(tbl)
  tbl <- tbl %>%
    mutate(across(all_of(KWH_COLUMNS), ~ . / NB_KWH_IN_MWH))
  return(tbl)
}

industry_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekday_SSP2.txt"
industry_weekday_tbl <- getTableFromCastillo(industry_weekday_datapath)
# Wow c'est fou comment ça marche bien vs Excel

print(industry_weekday_tbl)

industry_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekend_SSP2.txt"
industry_weekend_tbl <- getTableFromCastillo(industry_weekend_datapath)
# Wow c'est fou comment ça marche bien vs Excel

print(industry_weekend_tbl)

# faut un preprocessCastilloData qui mette les kWh en MWh, qui transforme les weekday machin en vraie année 2015

source(".\\src\\utils.R")

isWeekday <- function(year, month, day) {
  date <- as.Date(paste0(year, "-", month, "-", day))
  # print(date)
  day_of_week_index <- format(date, "%u")  # %u gives the day of the week as a number (1 for Monday, ..., 7 for Sunday)
  # print(day_of_week_index)
  is_weekday <- (day_of_week_index < 6)
  # Return day of the week
  return(is_weekday)
}

days_per_month <- function(year) {
  # Si je suis un omega-chad je réutilise ici le "is_leap_year"
  feb_days <- 28
  if (is_leap_year(year)) {
    feb_days <- 29
  }
  days_lst <- c(31, feb_days, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  return(days_lst)
}

generate_blank_hourly_tbl <- function(study_year) {
  days_lst <- days_per_month(study_year)
  # print(days_lst)
  # hourly_ts <- tibble(timeID = NA, year = NA, month = NA, day = NA, hour = NA)
  timeId_ts = seq(1, 8760)
  # print(timeId_ts)
  year_ts = rep(study_year, 8760)
  # print(year_ts)
  month_ts = c()
  day_ts = c()
  for (m in 1:12) {
    # print(paste("m =", m))
    nb_days <- days_lst[m]
    month_ts <- c(month_ts, rep(m, nb_days * 24))
    for (d in 1:nb_days) {
      day_ts <- c(day_ts, rep(d, 24))
    }
    # print(nb_days)
    # month_ts <- c(month_ts, rep(rep(m, nb_days), 24))
    # print(month_ts)
    # day_ts <- c(day_ts, seq(1, nb_days))
    # print(day_ts)
  }
  # print(month_ts)
  # print(day_ts)
  # Tant pis pour les leap year eh vazy
  hour_ts <- rep(seq(1,24), 365)
  # print(hour_ts)
  
  hourly_tbl <- tibble(timeId = timeId_ts,
                       year = year_ts,
                       month = month_ts,
                       day = day_ts,
                       hour = hour_ts)
  return(hourly_tbl)
}

hourly_tbl <- generate_blank_hourly_tbl(2015)
# print(hourly_tbl, n = 1500)
# Big ça marche

# preprocessCastilloSector <- function(weekday_data_tbl,
#                                      weekend_data_tbl,
#                                      study_year) {
#   weekda
# }

hourly_tbl_test <- generate_blank_hourly_tbl(2015) %>%
  #mutate(is_weekday = isWeekday(year, month, day))
  # un case_when !
  # mutate(usa_industry = case_when(
  #   isWeekday(year, month, day) ~ # faudrait un truc pour fetch rapidement valeur
  #   # 
  #   # grepl("Sto$", plexos_fuel_group) ~ "Other 2",
  #   # grepl("Wav$", plexos_fuel_group) ~ "Other 3",
  #   # grepl("Oth$", plexos_fuel_group) ~ "Other 4",
  #   TRUE ~ NA_character_  # For unrelated child_object values (other)
  # )) %>%
print(hourly_tbl_test, n = 500)

fetch_value <- function(demand_tbl, given_year, given_month, given_hour, region) {
  request <- demand_tbl %>%
    filter(year == given_year & Month == given_month & Hour == given_hour) %>%
    pull(region)
  
  return(request)
}
fetch_test <- fetch_value(industry_weekday_tbl, 2015, 1, 1, "USA")
print(fetch_test)
fetch_test <- fetch_value(industry_weekend_tbl, 2015, 1, 1, "USA")
print(fetch_test)

industry_tbl_test <- industry_weekday_tbl %>% 
  filter(year == 2015) %>%
  select(year, Month, Hour, USA) # On va regarder USA là pour l'instant allez
print(industry_tbl_test)
