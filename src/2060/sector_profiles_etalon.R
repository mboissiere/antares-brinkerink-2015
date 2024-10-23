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
    mutate(across(all_of(KWH_COLUMNS), ~ . / NB_KWH_IN_MWH)) %>%
    mutate(World = rowSums(across(KWH_COLUMNS)))
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
  hour_ts <- rep(seq(1,24), 365)
  
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

# Simple export just to get better Excels

writeCastilloTable <- function(object, file_name, folder_path = ".\\output\\castillo_input_csvs") {
  write.table(object,
              file = file.path(folder_path, file_name),
              sep = ";",
              dec = ",",
              quote = FALSE,
              row.names = FALSE,
              col.names = TRUE)
}

writeCastilloTable(industry_weekday_tbl, "industry_weekday_tbl.csv")
writeCastilloTable(industry_weekend_tbl, "industry_weekend_tbl.csv")

writeCastilloTable(transport_weekday_tbl, "transport_weekday_tbl.csv")
writeCastilloTable(transport_weekend_tbl, "transport_weekend_tbl.csv")

writeCastilloTable(residential_weekday_tbl, "residential_weekday_tbl.csv")
writeCastilloTable(residential_weekend_tbl, "residential_weekend_tbl.csv")

writeCastilloTable(service_weekday_tbl, "service_weekday_tbl.csv")
writeCastilloTable(service_weekend_tbl, "service_weekend_tbl.csv")



###### LETS GET IT

getSectorProfiles <- function(study_year = 2015,
                              region = "World") {
  hourly_tbl <- generate_blank_hourly_tbl(study_year)
  
  ### INDUSTRY ###
  
  industry_ts <- generate_sector_hourly_ts(study_year,
                                           region,
                                           industry_weekday_tbl,
                                           industry_weekend_tbl)
  total_industry <- sum(industry_ts)
  
  transport_ts <- generate_sector_hourly_ts(study_year,
                                            region,
                                            transport_weekday_tbl,
                                            transport_weekend_tbl)
  total_transport <- sum(transport_ts)
  
  residential_ts <- generate_sector_hourly_ts(study_year,
                                              region,
                                              residential_weekday_tbl,
                                              residential_weekend_tbl)
  total_residential <- sum(residential_ts)
  
  service_ts <- generate_sector_hourly_ts(study_year,
                                          region,
                                          service_weekday_tbl,
                                          service_weekend_tbl)
  total_service <- sum(service_ts)
  
  hourly_tbl <- hourly_tbl %>%
    mutate(industry = industry_ts/total_industry,
           transport = transport_ts/total_transport,
           residential = residential_ts/total_residential,
           service = service_ts/total_service)
  
  return(hourly_tbl)
}

sector_profiles_hourly_tbl <- getSectorProfiles()
print(sector_profiles__hourly_tbl, n = 300)


saveRDS(object = sector_profiles_hourly_tbl,
        file = ".\\src\\2060\\castillo_2015_profiles_tbl.rds")

csv_path = ".\\output\\sector_profiles_csvs"

write.table(sector_profiles_hourly_tbl,
            file = file.path(csv_path, "castillo_2015_hourly_profiles.csv"),
            sep = ";",
            dec = ",",
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE
)

sector_profiles_daily_tbl <- sector_profiles_hourly_tbl %>%
  group_by(year, month, day) %>%
  summarise(across(c(industry, transport, residential, service), sum))


write.table(sector_profiles_daily_tbl,
            file = file.path(csv_path, "castillo_2015_daily_profiles.csv"),
            sep = ";",
            dec = ",",
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE
)

#######################

load_path <- ".\\input\\all_demand_utc_2015_onlyplexos.txt"

load_table <- read.table(
  load_path,
  header = TRUE,
  sep = ";",
  encoding = "UTF-8",
  row.names = 1,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

load_tbl <- as_tibble(load_table) %>%
  rename_with(tolower)

saveRDS(load_tbl, ".\\src\\2060\\plexos_2015_load_tbl.rds")

# Ajout de volumes MATER

# SECTEUR ETALON :
print("Secteur étalon choisi : Résidentiel")
# Ce serait bien de pouvoir programmer et automatiser ça mais bong
volumesMATER2015 = c(
  industry = 756440746 + 964867785 + 206486176 
  + 810017230 + 2097842974 + 958089158 + 231775314
  + 2124112513 + 1092711323
  + 3067154595,
  # Agriculture + Aluminum primary production + Cement and clinker primary production 
  # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
  # + Other materials production + Textile
  # [ + Other industries ]
  transport = 96139319 + 96695382,
  # Passenger transport + Freight
  # residential = 6341838625,
  residential = 0,
  # Residential buildings
  service = 5581947974
  # service = 0
  # Tertiary buildings
)

sectors = c("industry", "transport", "residential", "service")

add2015MATERVolumes <- function() {
  sector_profiles_tbl <- readRDS(".\\src\\2060\\castillo_2015_profiles_tbl.rds")
  sector_curves_tbl <- sector_profiles_tbl %>%
    mutate(industry = industry * volumesMATER2015["industry"],
           transport = transport * volumesMATER2015["transport"],
           residential = residential * volumesMATER2015["residential"],
           service = service * volumesMATER2015["service"]
    )

  deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/plexos_2015_load_tbl.rds")
  nodes <- colnames(deane_2015_load_tbl)
  
  world_load_ts <- deane_2015_load_tbl %>%
    mutate(World = rowSums(across(all_of(nodes)))) %>%
    pull(World)
  
  sector_curves_tbl <- sector_curves_tbl %>%
    mutate(total_deane = world_load_ts) %>%
    mutate(balance = total_deane - industry - transport - residential - service) %>%
    select(timeId, year, month, day, hour, industry, transport, residential, service, balance, total_deane)
  
  return(sector_curves_tbl)
}

sector_hourly_curves_tbl <- add2015MATERVolumes()
print(sector_hourly_curves_tbl, n = 300)

write.table(sector_hourly_curves_tbl,
            file = file.path(csv_path, "castillo_2015_hourly_no_residential.csv"),
            sep = ";",
            dec = ",",
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE
)

sector_daily_curves_tbl <- sector_hourly_curves_tbl %>%
  group_by(year, month, day) %>%
  summarise(across(c(industry, transport, residential, service, balance, total_deane), sum))

write.table(sector_daily_curves_tbl,
            file = file.path(csv_path, "castillo_2015_daily_no_residential.csv"),
            sep = ";",
            dec = ",",
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE)

