getGlobalPollution <- function() {
  
  area_fuel_pollution_tbl <- getContinentalPollution()
  
  world_pollution_tbl <- area_fuel_pollution_tbl %>%
    filter(fuel == "Total") %>%
    select(area, pollution_tons)
  
  # print(world_pollution_tbl)
  
  world_pollution_tbl <- world_pollution_tbl %>%
    mutate(area = recode(area,
                         "africa" = "Africa", 
                         "asia" = "Asia", 
                         "europe" = "Europe", 
                         "north america" = "North America", 
                         "oceania" = "Oceania", 
                         "south america" = "South America"))
  
  # print(world_pollution_tbl)
  
  # Summing pollution data and adding a "Global" row
  # 1. Create a table with just the continental data (no "Global")
  continental_tbl <- world_pollution_tbl %>%
    filter(area != "Global") %>%
    ungroup()
  
  # 2. Create a separate table for the "Global" total, ungrouping any previous grouping
  global_tbl <- continental_tbl %>%
    summarise(area = "Global", pollution_tons = sum(pollution_tons))
  
  # 3. Combine the two tables (continental data + global data)
  final_tbl <- bind_rows(continental_tbl, global_tbl) %>%
    arrange(desc(pollution_tons))
  
  # print(final_tbl)
  return(final_tbl)
}