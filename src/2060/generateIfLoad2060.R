source(".\\src\\2060\\regionProfilesToUTC.R")

volumesMATER2060_S1 = c(
  industry = 1476383197 + 251209726 + 268605588 
  + 431341784 + 3336602758 + 907237037 + 177648819
  + 5130976270 + 3067070068 + 601499895,
  # Agriculture + Aluminum primary production + Cement and clinker primary production 
  # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
  # + Other industries + Other materials production + Textile
  transport = 2439810833 + 1731885873,
  # Passenger transport + Freight
  residential = 7658717726,
  # Residential buildings
  service = 5168755716
  # Tertiary buildings
)

nodes_plus_world <- c(deane_all_nodes_lst, "World")

exportCurves <- function(name, image_profiles_path, volume) {
  image_profiles_tbl <- readRDS(image_profiles_path)
  
  hourly_volumes_tbl <- getNodesSectorVolumes(image_profiles_tbl, volume)
  print(hourly_volumes_tbl)
  
  rds_file_name = paste0(name, "_2060_curves_tbl.rds")
  save_path = file.path("src", "2060", "true 2060", rds_file_name)
  saveRDS(hourly_volumes_tbl, save_path)
  
  hourly_csv_file_name = paste0("hourly", name, "_UTC_2060.csv")
  
  write.table(hourly_volumes_tbl,
              file = file.path(save_path, hourly_csv_file_name),
              sep = ";",
              dec = ",",
              quote = FALSE,
              row.names = FALSE,
              col.names = TRUE)
  
  daily_volumes_tbl <- hourly_volumes_tbl %>%
    group_by(year, month, day) %>%
    summarise(across(all_of(nodes_plus_world), sum))
  
  daily_csv_file_name = paste0("daily", name, "_UTC_2060.csv")
  
  write.table(daily_volumes_tbl,
              file = file.path(save_path, daily_csv_file_name),
              sep = ";",
              dec = ",",
              quote = FALSE,
              row.names = FALSE,
              col.names = TRUE
  )
}

exportCurves(name = "industry_S1",
             image_profiles_path = "~/GitHub/antares-brinkerink-2015/src/2060/industry_2015_image_profiles.rds",
             volume = volumesMATER2060_S1["industry"]
             )