# volumesMATERcapacity2015 = c(
#   Bioenergy = 125800,
# 
#   CSP = 4803,
#   Coal = 2469000,
#   Gas = 1330000,
#   Geothermal = 11751,
#   Hydro = 1247110,
#   Nuclear = 364000,
#   Oil = 245600,
#   PV = 127820,
#   Wind = 331843
# )

volumesPLEXOScapacity2015 = c(
  # Bioenergy = 125800,
  
  CSP = 4803, # manually checked
  # Coal = 2469000,
  # Gas = 1330000,
  Geothermal = 11751,
  Hydro = 1134619, # manually checked, in aux
  # Nuclear = 364000,
  # Oil = 245600,
  PV = 127820,
  Wind = 431309.1 # manually checked, in aux
)

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

S1_tbl <- tibble(
    scenario = "S1",
    if_technology_type = names(volumesMATERcapacity2060_S1),
    total_capacity_2060 = as.numeric(volumesMATERcapacity2060_S1[if_technology_type])
  )

S2_tbl <- tibble(
  scenario = "S2",
  if_technology_type = names(volumesMATERcapacity2060_S2),
  total_capacity_2060 = as.numeric(volumesMATERcapacity2060_S2[if_technology_type])
)

S3_tbl <- tibble(
  scenario = "S3",
  if_technology_type = names(volumesMATERcapacity2060_S3),
  total_capacity_2060 = as.numeric(volumesMATERcapacity2060_S3[if_technology_type])
)

S4_tbl <- tibble(
  scenario = "S4",
  if_technology_type = names(volumesMATERcapacity2060_S4),
  total_capacity_2060 = as.numeric(volumesMATERcapacity2060_S4[if_technology_type])
)

if_2060_capacities_tbl <- bind_rows(S1_tbl, S2_tbl, S3_tbl, S4_tbl)
print(if_2060_capacities_tbl, n = 50)

saveRDS(if_2060_capacities_tbl, ".\\src\\2060\\oneNode\\if_2060_capacities_tbl.rds")

# print(S1_tbl)

# volumes_MATER_tbl <- tibble(
#   if_technology_type = names(volumesMATERcapacity2015),
#   # if_2015 = as.numeric(volumesMATERcapacity2015),
#   if_2060_S1 = as.numeric(volumesMATERcapacity2060_S1[names(volumesMATERcapacity2015)]),
#   if_2060_S2 = as.numeric(volumesMATERcapacity2060_S2[names(volumesMATERcapacity2015)]),
#   if_2060_S3 = as.numeric(volumesMATERcapacity2060_S3[names(volumesMATERcapacity2015)]),
#   if_2060_S4 = as.numeric(volumesMATERcapacity2060_S4[names(volumesMATERcapacity2015)])
# )