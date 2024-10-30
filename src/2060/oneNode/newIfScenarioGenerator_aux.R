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
# print(hydro_monthly_profiles_tbl)

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
# print(wind_in_ninja_lst)

wind_properties_2015_tbl <- base_generators_properties_tbl_2015 %>%
  filter(active_in_2015 & plexos_fuel_type == "Wind") %>%
  filter(generator_name %in% wind_in_ninja_lst) %>%
  mutate(total_capacity = nominal_capacity * nb_units)

# print(wind_properties_2015_tbl)
  

total_wind_capacity_2015 <- sum(
  wind_properties_2015_tbl %>% pull(total_capacity)
)
  
# print(total_wind_capacity_2015)


solarpv_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/solarpv_cf_ts_tbl.rds")
# print(hydro_monthly_profiles_tbl)

solarpv_in_ninja_lst <- colnames(solarpv_cf_ts_tbl %>% select(-datetime))
# print(solarpv_in_ninja_lst)

solarpv_properties_2015_tbl <- base_generators_properties_tbl_2015 %>%
  filter(active_in_2015 & antares_cluster_type == "Solar PV") %>%
  filter(generator_name %in% solarpv_in_ninja_lst) %>%
  mutate(total_capacity = nominal_capacity * nb_units)

# print(solarpv_properties_2015_tbl)


total_solarpv_capacity_2015 <- sum(
  solarpv_properties_2015_tbl %>% pull(total_capacity)
)


################ CSP LE RETOUR DE LA VENGEANCE

library(stringr)
solarpv_cf_ts_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/solarpv_cf_ts_tbl.rds")

# Ptet que le mieux, au lieu de faire des batteries, c'est plutôt passer par le mode clusters.. En vrai...
# Sans non plus ajouter chaque centrale individuellement mais genre, ça permet de distinguer comme outputs
# Solar PV et Solar Thermal...

solarcsp_cf_ts_tbl <- solarpv_cf_ts_tbl %>%
  rename_with(~ str_replace(., "_sol_", "_csp_"))

# print(solarcsp_cf_ts_tbl)

# generators_scenarios_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")
# csp_if_properties_tbl <- generators_scenarios_properties_tbl %>%
#   filter(if_technology_type == "CSP")

base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds")

csp_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds") %>%
  filter(antares_cluster_type == "Solar Thermal")

# Extract column names from solarpv_cf_ts_tbl
columns_in_solarcsp <- colnames(solarcsp_cf_ts_tbl)

# Filter generator names that match the column names in solarpv_cf_ts_tbl
matching_generators <- csp_generators_properties_tbl %>%
  filter(generator_name %in% columns_in_solarcsp) %>%
  select(generator_name)

# Display the matching generator names
# print(matching_generators, n = 67)

pv_generators_lst <- base_generators_properties_tbl %>%
  filter(antares_cluster_type == "Solar PV") %>%
  pull(generator_name)

# Filter and check presence of "_sol_capacity scaler" counterpart
filtered_generators <- matching_generators %>%
  ######### En vrai je pourrais faire ceci avec n'importe quel _sol_, pas juste les capacity scaler.
  # Peut etre que _sol_CentraleSolair était vraiment un PV (mais en pratique... non)
  filter(!str_detect(generator_name, "capacity scaler") |
           !str_replace(generator_name, "_csp_", "_sol_") %in% pv_generators_lst) %>%
  pull(generator_name) %>% unique()

# Display the filtered generator names
# print(filtered_generators)

new_csp_properties_tbl <- csp_generators_properties_tbl %>%
  filter(generator_name %in% filtered_generators)

# print(new_csp_properties_tbl)

# saveRDS(new_csp_properties_tbl, ".\\src\\objects\\true_csp_properties_tbl.rds")

true_csp_2015_capacity <- sum(
  new_csp_properties_tbl %>%
    mutate(total_capacity = nb_units * nominal_capacity) %>%
    pull(total_capacity)
)

# print(true_csp_2015_capacity)

filteredcsp_cf_ts_tbl <- solarcsp_cf_ts_tbl %>%
  select(datetime, all_of(filtered_generators))

# print(filteredcsp_cf_ts_tbl)

# saveRDS(filteredcsp_cf_ts_tbl, ".\\src\\objects\\truecsp_cf_ts_tbl.rds")



# print(total_solarpv_capacity_2015)

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