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
    mutate(across(all_of(KWH_COLUMNS), ~ . / NB_KWH_IN_MWH)) %>%
    # mutate(World = rowSums(across(all_of(KWH_COLUMNS))))
  return(tbl)
}

source(".\\src\\utils.R")

isWeekday <- function(year, month, day) {
  date <- as.Date(paste0(year, "-", month, "-", day))
  day_of_week_index <- format(date, "%u")
  is_weekday <- (day_of_week_index < 6)
  return(is_weekday)
}

days_per_month <- function(year) {
  feb_days <- 28
  if (is_leap_year(year)) {
    feb_days <- 29
  }
  days_lst <- c(31, feb_days, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  return(days_lst)
}


generate_blank_hourly_tbl <- function(study_year) {
  days_lst <- days_per_month(study_year)
  timeId_ts = seq(1, 8760)
  year_ts = rep(study_year, 8760)
  month_ts = c()
  day_ts = c()
  for (m in 1:12) {
    nb_days <- days_lst[m]
    month_ts <- c(month_ts, rep(m, nb_days * 24))
    for (d in 1:nb_days) {
      day_ts <- c(day_ts, rep(d, 24))
    }
  }
  hour_ts <- rep(seq(0,23), 365)
  
  hourly_tbl <- tibble(timeId = timeId_ts,
                       year = year_ts,
                       month = month_ts,
                       day = day_ts,
                       hour = hour_ts)
  return(hourly_tbl)
}

fetch_value <- function(demand_tbl, given_year, given_month, given_hour, region) {
  
  request <- demand_tbl %>%
    filter(year == given_year & Month == given_month & Hour == given_hour) %>%
    pull(region)
  
  return(request)
}

study_year = 2015
generate_sector_hourly_ts <- function(study_year,
                                      study_region,
                                      weekday_tbl, 
                                      weekend_tbl) {
  blank_tbl <- generate_blank_hourly_tbl(study_year)
  hourly_ts <- c()
  for (k in 1:nrow(blank_tbl)) {
    month <- blank_tbl[k,]$month
    day <- blank_tbl[k,]$day
    hour <- blank_tbl[k,]$hour
    if (isWeekday(study_year, month, day)) {
      demand_tbl <- weekday_tbl
    } else {
      demand_tbl <- weekend_tbl
    }
    # To have 0-23 instead of 1-24
    demand_tbl <- demand_tbl %>%
      mutate(Hour = Hour %% 24)
    demand <- fetch_value(demand_tbl = demand_tbl,
                          given_year = study_year,
                          given_month = month,
                          given_hour = hour,
                          region = study_region)
    hourly_ts <- c(hourly_ts, demand)
  }
  return(hourly_ts)
}


#######################

## INDUSTRY ##
industry_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekday_SSP2.txt"
industry_weekday_tbl <- getTableFromCastillo(industry_weekday_datapath)

industry_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekend_SSP2.txt"
industry_weekend_tbl <- getTableFromCastillo(industry_weekend_datapath)


## TRANSPORT ##
transport_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Transport_total_weekday.txt"
transport_weekday_tbl <- getTableFromCastillo(transport_weekday_datapath)

transport_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Transport_total_weekend.txt"
transport_weekend_tbl <- getTableFromCastillo(transport_weekend_datapath)


## RESIDENTIAL ##
residential_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Residential_total_weekday_SSP2.txt"
residential_weekday_tbl <- getTableFromCastillo(residential_weekday_datapath)

residential_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Residential_total_weekend_SSP2.txt"
residential_weekend_tbl <- getTableFromCastillo(residential_weekend_datapath)


## SERVICE ##
service_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Service_total_weekday_SSP2.txt"
service_weekday_tbl <- getTableFromCastillo(service_weekday_datapath)

service_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Service_total_weekend_SSP2.txt"
service_weekend_tbl <- getTableFromCastillo(service_weekend_datapath)

# POUR L'INSTANT, PAS DE SECTEUR ETALON
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
