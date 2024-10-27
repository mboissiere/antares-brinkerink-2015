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

# hourly_tbl <- generate_blank_hourly_tbl(2015)
# print(hourly_tbl, n = 1500)
# Big ça marche

# preprocessCastilloSector <- function(weekday_data_tbl,
#                                      weekend_data_tbl,
#                                      study_year) {
#   weekda
# }

# hourly_tbl_test <- generate_blank_hourly_tbl(2015) %>%
#   mutate(is_weekday = isWeekday(year, month, day))
  # un case_when !
  # mutate(usa_industry = case_when(
  #   isWeekday(year, month, day) ~ # faudrait un truc pour fetch rapidement valeur
  #   # 
  #   # grepl("Sto$", plexos_fuel_group) ~ "Other 2",
  #   # grepl("Wav$", plexos_fuel_group) ~ "Other 3",
  #   # grepl("Oth$", plexos_fuel_group) ~ "Other 4",
  #   TRUE ~ NA_character_  # For unrelated child_object values (other)
  # )) %>%
# print(hourly_tbl_test, n = 500)

fetch_value <- function(demand_tbl, given_year, given_month, given_hour, region) {
  
  #Hypothesis : value should be divided by nb of days in month, first
  # days_lst <- days_per_month(study_year)
  # nb_days <- days_lst[given_month]
  # Correction de Nicolas : on s'en fiche, à la fin on prendra des profils de toute façon.
  
  request <- demand_tbl %>%
    filter(year == given_year & Month == given_month & Hour == given_hour) %>%
    pull(region)
  
  # request <- request / nb_days
  
  return(request)
}
# fetch_test <- fetch_value(industry_weekday_tbl, 2015, 1, 1, "World")
# print(fetch_test)
# fetch_test <- fetch_value(industry_weekend_tbl, 2015, 1, 1, "World")
# print(fetch_test)

# industry_tbl_test <- industry_weekday_tbl %>% 
#   filter(year == 2015) %>%
#   select(year, Month, Hour, USA) # On va regarder USA là pour l'instant allez
# print(industry_tbl_test)

# getWorldTableFromCastillo <- function(castillo_data_path,
#                                       study_year) {
#   world_tbl <- getTableFromCastillo(castillo_data_path) %>%
#     filter(year == study_year) %>%
#     mutate(World = rowSums(across(KWH_COLUMNS))) %>%
#     select(year, Month, Hour, World)
#   return(world_tbl)
# }
# world_tbl <- getWorldTableFromCastillo(industry_weekday_datapath, 2015)
# print(world_tbl)

# preprocessCastilloSector <- function(weekday_data_tbl,
#                                      weekend_data_tbl,
#                                      study_year,
#                                      region) {
# }


study_year = 2015
generate_sector_hourly_ts <- function(study_year,
                                      study_region,
                                      weekday_tbl, 
                                      weekend_tbl) {
  blank_tbl <- generate_blank_hourly_tbl(study_year)
  hourly_ts <- c()
  for (k in 1:nrow(blank_tbl)) {
    # bad lent mais je vois pas comment faire autrement vu que les
    # opérations vectorielles vont m'embêter sur les dimensions
    # print(blank_tbl[k,])
    month <- blank_tbl[k,]$month
    day <- blank_tbl[k,]$day
    hour <- blank_tbl[k,]$hour
    if (isWeekday(study_year, month, day)) {
      demand_tbl <- weekday_tbl
      # print("is weekday")
      # MDR C'ETAIT MOI QUI AVAIT TORT PAS MON CODE
    } else {
      demand_tbl <- weekend_tbl
    }
    demand <- fetch_value(demand_tbl = demand_tbl,
                          given_year = study_year,
                          given_month = month,
                          given_hour = hour,
                          region = study_region)
    # print(demand)
    hourly_ts <- c(hourly_ts, demand)
  }

  # hourly_tbl <- tibble(sector_name = hourly_ts)
  # je crois aussi que le "sector_name" ça marche pas ça va littéralement juste
  # écrire sector_name

  # autre approche : mettre cette boucle direct dans le programme final
  # et changer le demand_tbl : à chaque fois dire hop je rajoute industry, etc..
  # mais en vrai dur psk mutate() voudrait qu'on ait déjà le truc tout construit...
  return(hourly_ts)
}
# industry_hourly_ts <- generate_sector_hourly_ts(2015,
#                                                 "World",
#                                                 industry_weekday_tbl,
#                                                 industry_weekend_tbl
#                                                 )
# print(industry_hourly_ts)

#######################

## INDUSTRY ##
industry_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekday_SSP2.txt"
industry_weekday_tbl <- getTableFromCastillo(industry_weekday_datapath)
# Wow c'est fou comment ça marche bien vs Excel

# print(industry_weekday_tbl %>% filter(year == 2015) %>% select(year, Month, Hour, World), n = 300)

industry_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Industry_total_weekend_SSP2.txt"
industry_weekend_tbl <- getTableFromCastillo(industry_weekend_datapath)
# Wow c'est fou comment ça marche bien vs Excel

# print(industry_weekend_tbl %>% filter(year == 2015) %>% select(year, Month, Hour, World), n = 300)


## TRANSPORT ##
transport_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Transport_total_weekday.txt"
transport_weekday_tbl <- getTableFromCastillo(transport_weekday_datapath)
# Wow c'est fou comment ça marche bien vs Excel

# print(transport_weekday_tbl %>% filter(year == 2015) %>% select(year, Month, Hour, World), n = 300)

transport_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Transport_total_weekend.txt"
transport_weekend_tbl <- getTableFromCastillo(transport_weekend_datapath)

# print(transport_weekend_tbl %>% filter(year == 2015) %>% select(year, Month, Hour, World), n = 300)


## RESIDENTIAL ##
residential_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Residential_total_weekday_SSP2.txt"
residential_weekday_tbl <- getTableFromCastillo(residential_weekday_datapath)

# print(residential_weekday_tbl %>% filter(year == 2015) %>% select(year, Month, Hour, World), n = 300)

residential_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Residential_total_weekend_SSP2.txt"
residential_weekend_tbl <- getTableFromCastillo(residential_weekend_datapath)


## SERVICE ##
service_weekday_datapath <- ".\\input\\pmd2dchk44-1\\Service_total_weekday_SSP2.txt"
service_weekday_tbl <- getTableFromCastillo(service_weekday_datapath)


service_weekend_datapath <- ".\\input\\pmd2dchk44-1\\Service_total_weekend_SSP2.txt"
service_weekend_tbl <- getTableFromCastillo(service_weekend_datapath)

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

  # hourly_tbl <- hourly_tbl %>%
  #   mutate(industry = ifelse(isWeekday(year, month, day),
  #                            fetch_value(industry_weekday_tbl, year, month, hour, region),
  #                            fetch_value(industry_weekend_tbl, year, month, hour, region))
  #   )
  # mutate(industry = case_when(
  #     isWeekday(year, month, day) ~ fetch_value(industry_weekday_tbl, year, month, hour, region),
  #     !isWeekday(year, month, day) ~ fetch_value(industry_weekend_tbl, year, month, hour, region),
  #     TRUE ~ NA_character_  # For unrelated child_object values (other)
  #   ))
  # NOOOO
  
  return(hourly_tbl)
}

sector_profiles_hourly_tbl <- getSectorProfiles()
print(sector_profiles_hourly_tbl, n = 300)

# fetch_value(industry_weekday_tbl, 2015, 1, 1, "World")

# hourly_tbl <- generate_blank_hourly_tbl(2015)
# for (k in 1:nrow(hourly_tbl)) {
#   print(hourly_tbl[k,])
#   month <- hourly_tbl[k,]$month
#   day <- hourly_tbl[k,]$day
#   hour <- hourly_tbl[k,]$hour
#   if (isWeekday(2015, month, day)) {
#     print(fetch_value(industry_weekday_tbl, 2015, month, hour, "World"))
#   } else {
#     print(fetch_value(industry_weekend_tbl, 2015, month, hour, "World"))
#   }
#   
#   
# }

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

# print(sector_profiles_hourly_tbl, n = 300)

sector_profiles_daily_tbl <- sector_profiles_hourly_tbl %>%
  group_by(year, month, day) %>%
  summarise(across(c(industry, transport, residential, service), sum))

# print(sector_profiles_daily_tbl)

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

sectors = c("industry", "transport", "residential", "service")

add2015MATERVolumes <- function() {
  sector_profiles_tbl <- readRDS(".\\src\\2060\\castillo_2015_profiles_tbl.rds")
  # print(sector_profiles_tbl)
  sector_curves_tbl <- sector_profiles_tbl %>%
    mutate(industry = industry * volumesMATER2015["industry"],
           transport = transport * volumesMATER2015["transport"],
           residential = residential * volumesMATER2015["residential"],
           service = service * volumesMATER2015["service"]
           )
  # sector_curves_tbl <- sector_profiles_tbl %>%
  #   mutate(across(all_of(sectors), ~ . * volumesMATER2015[[.]]))
  # for (sector in sectors) {
  #   print(sector)
  #   volume <- volumesMATER2015[[sector]]
  #   print(volume)
  #   sector_curves_tbl %>%
  #     mutate(sector = sector * volume) #ah ptn "sector" en tant que variable _a marche pas
  #   # ça va littéralement appeler sector juste
  # }
  deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/plexos_2015_load_tbl.rds")
  nodes <- colnames(deane_2015_load_tbl)

  world_load_ts <- deane_2015_load_tbl %>%
    mutate(World = rowSums(across(all_of(nodes)))) %>%
    pull(World)
  
  sector_curves_tbl <- sector_curves_tbl %>%
    mutate(total_deane = world_load_ts) %>%
    mutate(balance = total_deane - industry - transport - residential - service) %>%
    select(timeId, year, month, day, hour, industry, transport, residential, service, balance, total_deane)
  # Pour réordonner juste
  
  
  return(sector_curves_tbl)
}

sector_hourly_curves_tbl <- add2015MATERVolumes()
print(sector_hourly_curves_tbl, n = 300)

write.table(sector_hourly_curves_tbl,
            file = file.path(csv_path, "castillo_2015_hourly_curves.csv"),
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
            file = file.path(csv_path, "castillo_2015_daily_curves.csv"),
            sep = ";",
            dec = ",",
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE
)


# print(world_load_ts)

# # flm de généraliser pour ajd
# generateSectorProfiles <- function() {
#   sector_curves_tbl <- readRDS(".\\src\\2060\\castillo_2015_load_tbl.rds")
#   
#   deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/deane_2015_load_tbl.rds")
#   nodes <- colnames(deane_2015_load_tbl)
#   
#   world_load_ts <- deane_2015_load_tbl %>%
#     mutate(World = rowSums(across(all_of(nodes)))) %>%
#     pull(World)
#   
#   sector_curves_tbl <- sector_curves_tbl %>%
#     mutate(total_deane = world_load_ts) %>%
#     mutate(balance = total_deane - industry - transport - residential - service)
#   
#   total_load = sum(world_load_ts)
#   
#   return(sector_curves_tbl)
# }
# 
# sector_profiles_tbl <- generateSectorProfiles()
# print(sector_profiles_tbl, n = 300)
