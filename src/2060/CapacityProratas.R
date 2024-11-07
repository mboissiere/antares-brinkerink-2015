volumesMATERcapacity2015 = c(
  Bioenergy = 125800,
  # CSP = 2804, ## EDITED IN OUR MODELLING, SEE ANTARES_CREATESTUDY_2060_AUX ON CSP SECTION
  # L'objectif étant d'avoir un capacity_ratio = if_2060/if_2015 qui soit exact par rapport aux capacités
  # réelles de plexos world 2015 toussa. et on a 4803 capacités de CSP dans plexos.
  
  # ce travail aurait pu être fait sur le reste également, surtout que la disponibilité des TS dans
  # renewables.ninja + les maintenances, compliquent la question...
  CSP = 4803,
  Coal = 2469000,
  Gas = 1330000,
  Geothermal = 11751,
  Hydro = 1247110,
  Nuclear = 364000,
  Oil = 245600,
  PV = 127820,
  Wind = 331843
)

# le graphe comparatif qu'on avait fait sur excel assure qu'on dise pas trop de bêtises
# mais c'est vrai que dans l'absolu... il faudrait plutôt... prendre des capas PLEXOS... partout..
# puisqu'on fait x... capacity_ratio sur, bah, ça.

volumesMATERcapacity2060_S1 = c(
  Bioenergy = 297200,
  CSP = 179979, 
  Coal = 66800,
  Gas = 190000,
  Geothermal = 51737,
  Hydro = 1079880,
  Nuclear = 334000,
  Oil = 0,
  PV = 8197926,
  Wind = 3080168
)

volumesMATERcapacity2060_S2 = c(
  Bioenergy = 881800,
  CSP = 240260, 
  Coal = 525600,
  Gas = 621200,
  Geothermal = 72674,
  Hydro = 1731960,
  Nuclear = 527000,
  Oil = 37600,
  PV = 11588717,
  Wind = 4371546
)

volumesMATERcapacity2060_S3 = c(
  Bioenergy = 890800,
  CSP = 405714, 
  Coal = 5356200,
  Gas = 7305600,
  Geothermal = 123557,
  Hydro = 1812170,
  Nuclear = 530000,
  Oil = 66600,
  PV = 13376812,
  Wind = 4544601
)

volumesMATERcapacity2060_S4 = c(
  Bioenergy = 549800,
  CSP = 200526, 
  Coal = 0,
  Gas = 1012000,
  Geothermal = 76200,
  Hydro = 2092450,
  Nuclear = 540000,
  Oil = 39600,
  PV = 12360457,
  Wind = 4820770
)

# Convert named vectors to tibbles
volumes_MATER_tbl <- tibble(
  if_technology_type = names(volumesMATERcapacity2015),
  if_2015 = as.numeric(volumesMATERcapacity2015),
  if_2060_S1 = as.numeric(volumesMATERcapacity2060_S1[names(volumesMATERcapacity2015)]),
  if_2060_S2 = as.numeric(volumesMATERcapacity2060_S2[names(volumesMATERcapacity2015)]),
  if_2060_S3 = as.numeric(volumesMATERcapacity2060_S3[names(volumesMATERcapacity2015)]),
  if_2060_S4 = as.numeric(volumesMATERcapacity2060_S4[names(volumesMATERcapacity2015)])
)

# Il faut penser à le rajouter le CSP ! Parce qu'il est pas encore implémenté !!
# > adapted_generators_properties_tbl %>% filter(if_technology_type == "CSP")
# # A tibble: 67 x 8
# generator_name             node      nominal_capacity nb_units total_capacity if_technology_type antares_cluster_type plexos_fuel_type
# <chr>                      <chr>                <dbl>    <dbl>          <dbl> <chr>              <chr>                <chr>           
#   1 are_csp_capacity scaler    as-are                 100        1            100 CSP                Solar Thermal        Solar           
# 2 are_csp_shams18306         as-are                 100        1            100 CSP                Solar Thermal        Solar           
# 3 aus_csp_liddellsolart507   oc-aus-sw                9        1              9 CSP                Solar Thermal        Solar           
# 4 chn_csp_datangdelingha5184 as-chn-qi               10        1             10 CSP                Solar Thermal        Solar 

base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds")
# saveRDS(base_generators_properties_tbl, "~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl_2015.rds")

# pv_2015_capacity_plexos <- sum(
#   base_generators_properties_tbl %>%
#   filter(antares_cluster_type == "Solar PV" & active_in_2015) %>%
#   mutate(total_capacity = nb_units * nominal_capacity) %>%
#   pull(total_capacity)
# )
# 
# print(pv_2015_capacity_plexos)

# Et si je modifie juste base_generators_properties_tbl... Je change tout !
# et je n'ai pas à trop modifier mon code !! ooooooo

# On va désormais désigner de "capacity ratio" le rapport total 2060/2015 qui fait que
# juste si je multiplie tous les nominal capacities par ça bah normalement ça devrait le faire enft

# pv_capacity_ratio_S1 <- volumesMATERcapacity2060_S1["pv"]/pv_2015_capacity_plexos
# 
# pv_properties_tbl_2015 <- base_generators_properties_tbl %>%
#   filter(antares_cluster_type == "Solar PV" & active_in_2015) %>%
#   mutate(total_capacity = nb_units * nominal_capacity)
# 
# pv_properties_tbl_2060 <- base_generators_properties_tbl %>%
#   filter(antares_cluster_type == "Solar PV" & active_in_2015) %>%
#   mutate(total_capacity = nb_units * nominal_capacity) %>%
#   mutate(total_capacity = total_capacity * pv_capacity_ratio_S1) %>%
#   mutate(nominal_capacity = total_capacity / nb_units)
# 
# print(pv_properties_tbl_2015)
# print(pv_properties_tbl_2060)

# Oh yeah, it's all coming together

# wind_2015_capacity_plexos <- sum(
#   base_generators_properties_tbl %>%
#     filter(plexos_fuel_type == "Wind" & active_in_2015) %>%
#     mutate(total_capacity = nb_units * nominal_capacity) %>%
#     pull(total_capacity)
# )
# 
# print(wind_2015_capacity_plexos)
# 
# wind_capacity_ratio_S1 <- volumesMATERcapacity2060_S1["wind"]/wind_2015_capacity_plexos
# 
# print(wind_capacity_ratio_S1)
# 
# wind_properties_tbl_2015 <- base_generators_properties_tbl %>%
#   filter(plexos_fuel_type == "Wind" & active_in_2015) %>%
#   mutate(total_capacity = nb_units * nominal_capacity)
# 
# wind_properties_tbl_2060 <- base_generators_properties_tbl %>%
#   filter(plexos_fuel_type == "Wind" & active_in_2015) %>%
#   mutate(total_capacity = nb_units * nominal_capacity) %>%
#   mutate(total_capacity = total_capacity * wind_capacity_ratio_S1) %>%
#   mutate(nominal_capacity = total_capacity / nb_units)
# 
# print(wind_properties_tbl_2015)
# print(wind_properties_tbl_2060)

############


adapted_generators_properties_tbl <- base_generators_properties_tbl %>%
  mutate(
    if_technology_type = case_when(
      # [1] "Gas"           "Hydro"         "Oil"           "Solar PV"      "Other 4"       "Solar Thermal" "Mixed Fuel"   
      # [8] "Hard Coal"     "Nuclear"       "Wind Onshore"  "Wind Offshore" "Other 3"       "Other"         "Other 2"
      antares_cluster_type == "Solar PV" ~ "PV",
      antares_cluster_type == "Solar Thermal" ~ "CSP",
      antares_cluster_type == "Wind Onshore" ~ "Wind",
      antares_cluster_type == "Wind Offshore" ~ "Wind",
      antares_cluster_type == "Mixed Fuel" ~ "Bioenergy",
      antares_cluster_type == "Hard Coal" ~ "Coal",
      antares_cluster_type == "Other" ~ "Geothermal",
      
      antares_cluster_type == "Gas" ~ "Gas",
      antares_cluster_type == "Hydro" ~ "Hydro",
      antares_cluster_type == "Nuclear" ~ "Nuclear",
      antares_cluster_type == "Oil" ~ "Oil",
      
      TRUE ~ "Other" # will disappear lmao
    )
  ) %>%
  filter(active_in_2015)%>%
  filter(if_technology_type != "Other") %>% # Adios
  mutate(total_capacity = nominal_capacity * nb_units) %>%
  select(generator_name, node, nominal_capacity, nb_units, total_capacity, if_technology_type, antares_cluster_type,
         plexos_fuel_group) # Le reste en vrai on peut s'en passer

# print(adapted_generators_properties_tbl, n = 200)

adapted_generators_properties_tbl_2060 <- adapted_generators_properties_tbl %>%
  rename(total_capacity_2015 = total_capacity,
         nominal_capacity_2015 = nominal_capacity) %>%
  left_join(volumes_MATER_tbl, by = "if_technology_type") %>%
  # select(-plexos_fuel_type) %>%
  
  mutate(S1_capacity_ratio = if_2060_S1/if_2015,
         total_capacity_2060_S1 = total_capacity_2015 * S1_capacity_ratio,
         nominal_capacity_2060_S1 = total_capacity_2060_S1 / nb_units) %>%
  
  mutate(S2_capacity_ratio = if_2060_S2/if_2015,
         total_capacity_2060_S2 = total_capacity_2015 * S2_capacity_ratio,
         nominal_capacity_2060_S2 = total_capacity_2060_S2 / nb_units) %>%
  
  mutate(S3_capacity_ratio = if_2060_S3/if_2015,
         total_capacity_2060_S3 = total_capacity_2015 * S3_capacity_ratio,
         nominal_capacity_2060_S3 = total_capacity_2060_S3 / nb_units) %>%
  
  mutate(S4_capacity_ratio = if_2060_S4/if_2015,
         total_capacity_2060_S4 = total_capacity_2015 * S4_capacity_ratio,
         nominal_capacity_2060_S4 = total_capacity_2060_S4 / nb_units)


#   filter(nominal_capacity_2060_S1 != 0) %>% 
#   filter(nominal_capacity_2060_S4 != 0)
# # Si on met les scénarios à la même adresse, faut faire ce tri plus tard.
# # Sinon, le oil à 0 dans S1 et le coal à 0 dans S4 se font tej alors que
# # le oil peut être non nul dans S4 etc.

# print(adapted_generators_properties_tbl_2060)

# saveRDS(adapted_generators_properties_tbl_2060, ".\\src\\2060\\generators_properties_if_2060.rds")
# Autre structure : faire tout d'un trait et genre un "scenario" "S1" qui filtre...


generators_if_properties_2060 <- adapted_generators_properties_tbl %>%
  rename(total_capacity_2015 = total_capacity,
         nominal_capacity_2015 = nominal_capacity) %>%
  left_join(volumes_MATER_tbl, by = "if_technology_type") # %>%
# select(-plexos_fuel_type)

# print(generators_if_properties_2060)


if_2060_S1_tbl <- generators_if_properties_2060 %>%
  mutate(scenario = "S1",
         capacity_ratio = if_2060_S1/if_2015,
         total_capacity_2060 = total_capacity_2015 * capacity_ratio,
         nominal_capacity_2060 = total_capacity_2060 / nb_units) %>%
  select(generator_name, node, if_technology_type, scenario,
         nominal_capacity_2015, total_capacity_2015, nb_units,
         nominal_capacity_2060, total_capacity_2060, capacity_ratio,
         antares_cluster_type, plexos_fuel_group)

if_2060_S2_tbl <- generators_if_properties_2060 %>%
  mutate(scenario = "S2",
         capacity_ratio = if_2060_S2/if_2015,
         total_capacity_2060 = total_capacity_2015 * capacity_ratio,
         nominal_capacity_2060 = total_capacity_2060 / nb_units) %>%
  select(generator_name, node, if_technology_type, scenario,
         nominal_capacity_2015, total_capacity_2015, nb_units,
         nominal_capacity_2060, total_capacity_2060, capacity_ratio,
         antares_cluster_type, plexos_fuel_group)

if_2060_S3_tbl <- generators_if_properties_2060 %>%
  mutate(scenario = "S3",
         capacity_ratio = if_2060_S3/if_2015,
         total_capacity_2060 = total_capacity_2015 * capacity_ratio,
         nominal_capacity_2060 = total_capacity_2060 / nb_units) %>%
  select(generator_name, node, if_technology_type, scenario,
         nominal_capacity_2015, total_capacity_2015, nb_units,
         nominal_capacity_2060, total_capacity_2060, capacity_ratio,
         antares_cluster_type, plexos_fuel_group)

if_2060_S4_tbl <- generators_if_properties_2060 %>%
  mutate(scenario = "S4",
         capacity_ratio = if_2060_S2/if_2015,
         total_capacity_2060 = total_capacity_2015 * capacity_ratio,
         nominal_capacity_2060 = total_capacity_2060 / nb_units) %>%
  select(generator_name, node, if_technology_type, scenario,
         nominal_capacity_2015, total_capacity_2015, nb_units,
         nominal_capacity_2060, total_capacity_2060, capacity_ratio,
         antares_cluster_type, plexos_fuel_group)

generators_if_properties_2060 <- bind_rows(if_2060_S1_tbl, if_2060_S2_tbl,
                                           if_2060_S3_tbl, if_2060_S4_tbl)

# print(generators_if_properties_2060)
# saveRDS(generators_if_properties_2060, ".\\src\\2060\\generators_scenarios_properties_tbl.rds")


# if_2060_S1_tbl

# mutate(S1_capacity_ratio = if_2060_S1/if_2015,
#        total_capacity_2060_S1 = total_capacity_2015 * S1_capacity_ratio,
#        nominal_capacity_2060_S1 = total_capacity_2060_S1 / nb_units) %>%
# 
# mutate(S2_capacity_ratio = if_2060_S2/if_2015,
#        total_capacity_2060_S2 = total_capacity_2015 * S2_capacity_ratio,
#        nominal_capacity_2060_S2 = total_capacity_2060_S2 / nb_units) %>%
# 
# mutate(S3_capacity_ratio = if_2060_S3/if_2015,
#        total_capacity_2060_S3 = total_capacity_2015 * S3_capacity_ratio,
#        nominal_capacity_2060_S3 = total_capacity_2060_S3 / nb_units) %>%
# 
# mutate(S4_capacity_ratio = if_2060_S4/if_2015,
#        total_capacity_2060_S4 = total_capacity_2015 * S4_capacity_ratio,
#        nominal_capacity_2060_S4 = total_capacity_2060_S4 / nb_units)

# adapted_generators_properties_tbl_2060_check <- adapted_generators_properties_tbl_2060 %>%
#   select(generator_name, #nominal_capacity_2015, nb_units, 
#          if_technology_type, total_capacity_2015,
#          S1_capacity_ratio, total_capacity_2060_S1,
#          S2_capacity_ratio, total_capacity_2060_S2,
#          S3_capacity_ratio, total_capacity_2060_S3,
#          S4_capacity_ratio, total_capacity_2060_S4)
# 
# print(adapted_generators_properties_tbl_2060_check, n = 500)


# cf remarque à JY : trè petites centrales à charbon. peut-être qu'on pourrait faire un truc qui les
# agrège dès lors qu'on garde en tête genre min stable power, mais ça nécessiterait de travailler sur
# thermal_properties_tbl et pas sur base_properties_tbl qui a cette info.

# aussi, le fioul crée plein de centrales à 0. on peut les tej !



# NB : dans If, le "Other" genre marémoteur etc, passe à la trappe, ça peut être bon de le remarquer.
# Risque effectivement de sous estimer technologie prometteuse genre littéralement le possible développement
# du marémoteur n'est pas modélisé. on peut supposer que c'est acceptable vu que c'est pas non plus
# la technologie qui va sauver le monde en terme de viabilité technique et économique.

get2060ScenarioTable <- function(scenario_number) {
  # base_generators_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/base_generators_properties_tbl.rds")
  generators_scenarios_properties_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/2060/generators_scenarios_properties_tbl.rds")
  
  new_scenario_tbl <- generators_scenarios_properties_tbl %>%
    filter(scenario == scenario_number) %>%
    filter(nominal_capacity_2060 != 0) %>%
    rename(nominal_capacity = nominal_capacity_2060) %>%
    select(generator_name, node, antares_cluster_type, nominal_capacity, nb_units, plexos_fuel_group, if_technology_type)
  # Pas besoin des continents, les districts sont gérés avec les nodes seulement
  return(new_scenario_tbl)
}
# # print(base_generators_properties_tbl)
# base_S1_tbl <- get2060ScenarioTable("S1")
# print(base_S1_tbl)


