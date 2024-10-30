getHydroMonthlyProfiles <- function() {
  tbl <- read.table(".\\input\\dataverse_files\\Hydro_Monthly_Profiles (2015).txt",
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
    mutate(NAME = tolower(NAME))
  return(tbl)
}

hydro_monthly_profiles_tbl <- getHydroMonthlyProfiles()
print(hydro_monthly_profiles_tbl)

hydro_in_ninja_lst <- hydro_monthly_profiles_tbl %>% pull(NAME)

base_generators_properties_tbl_2015 <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl_2015.rds")

hydro_properties_2015_tbl <- base_generators_properties_tbl_2015 %>%
  filter(active_in_2015 & antares_cluster_type == "Hydro") %>%
  filter(generator_name %in% hydro_in_ninja_lst) %>%
  mutate(total_capacity = nominal_capacity * nb_units)

total_hydro_capacity_2015 <- sum(
  hydro_properties_2015_tbl %>% pull(total_capacity)
)

wind_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/wind_cf_ts_tbl.rds")
# print(hydro_monthly_profiles_tbl)

wind_in_ninja_lst <- colnames(wind_cf_ts_tbl %>% select(-datetime))
print(wind_in_ninja_lst)

wind_properties_2015_tbl <- base_generators_properties_tbl_2015 %>%
  filter(active_in_2015 & plexos_fuel_type == "Wind") %>%
  filter(generator_name %in% wind_in_ninja_lst) %>%
  mutate(total_capacity = nominal_capacity * nb_units)

# print(wind_properties_2015_tbl)
  

total_wind_capacity_2015 <- sum(
  wind_properties_2015_tbl %>% pull(total_capacity)
)
  
print(total_wind_capacity_2015)

# nuclear_properties_2015_tbl <- base_generators_properties_tbl_2015 %>%
#   filter(active_in_2015 & antares_cluster_type == "Nuclear") %>%
#   mutate(total_capacity = nominal_capacity * nb_units)
# 
# print(nuclear_properties_2015_tbl)

# total_nuclear_capacity_2015 <- sum(
#   # nuclear_properties_2015_tbl %>% pull(total_capacity)
# )
# 
# print(total_nuclear_capacity_2015)

# Mm pas besoin, l'hydro est pas si régionalisée et a pas besoin de capacity ratio'