DATA_PATH = file.path("input", "dataverse_files")
HYDRO_2015_PATH = file.path(DATA_PATH, "Hydro_Monthly_Profiles (2015).txt")
# Il faudra demander à Deane si c'est 2015 dans le papier ou la moyenne !
# Si c'est la moyenne... pourquoi alors avoir enlevé les centrales nucléaires japonaises ?

getCFTableFromHydro <- function(hydro_data_path) {
  tbl <- read.table(hydro_data_path,
                    header = TRUE,
                    sep = ",",
                    stringsAsFactors = FALSE,
                    encoding = "UTF-8",
                    check.names = FALSE
  )
  tbl$NAME <- toupper(tbl$NAME)
  tbl <- as_tibble(tbl)
  
  return(tbl)
}


hydro_2015_tbl <- getCFTableFromHydro(HYDRO_2015_PATH)
print(hydro_2015_tbl)
# print(colnames(hydro_2015_tbl))

hydro_nominal_tbl <- readRDS(".\\src\\objects\\hydro_nominal_capacities_2015.rds")
print(hydro_nominal_tbl)

getProductionTableFromHydro <- function(hydro_CF_tbl, hydro_nominal_tbl) {
  combined_tbl <- hydro_CF_tbl %>%
    left_join(hydro_nominal_tbl, by = c("NAME" = "generator_name"))
  
  # Multiply the monthly values by the nominal capacity
  result_tbl <- combined_tbl %>%
    mutate(across(starts_with("M"), ~ . / 100 * nominal_capacity))
  return(result_tbl)
}

hydro_production_tbl <- getProductionTableFromHydro(hydro_2015_tbl, hydro_nominal_tbl)
print(hydro_production_tbl)

getCountryTableFromHydro <- function(hydro_production_tbl) {
  hydro_country_tbl <- hydro_production_tbl %>%
    group_by(node) %>%
    summarise(
      across(starts_with("M"), sum), # .names = "total_{col}"),
      total_nominal_capacity = sum(nominal_capacity)
    )
  
  return(hydro_country_tbl)
}

hydro_country_tbl <- getCountryTableFromHydro(hydro_production_tbl)


print(hydro_country_tbl)


# > print(hydro_country_tbl)
# # A tibble: 220 x 14
# node       M1     M2     M3     M4     M5     M6     M7      M8     M9    M10    M11     M12 total_nominal_capacity
# <chr>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>                  <dbl>
#   1 AF-AGO  667.   674.   651.   629.   606.   515.   453.   441.    480.   567.   656.   675.                     920.
# 2 AF-BDI   33.0   34.0   34.9   34.6   33.6   35.7   35.5   35.4    35.5   32.7   33.7   33.2                     49 
# 3 AF-BFA   10.0   10.1   11.2   10.8   12.3   10.8   10.6    9.42   10.8   11.4   11.3    9.83                    30 
# 4 AF-CAF   15.2   14.4   13.2   12.7   12.0   11.5   11.4   11.9    11.8   12.7   12.8   14.5                     19 
# 5 AF-CIV   69.5   75.6  119.   150.   186.   217.   174.   181.    227.   214.   153.    89.5                    599 
# 6 AF-CMR  467.   473.   522.   537.   559.   551.   529.   514.    533.   532.   542.   478.                     721.
# 7 AF-COD 1797.  1798.  1306.  1464.  1314.   853.   567.   483.    553.  1150.  1799.  1825.                    2805 
# 8 AF-COG  150.   151.   151.   120.    96.9   73.0   69.4   68.5    71.6   85.3  130.   151.                     219 
# 9 AF-DZA   19.9   21.9   18.1   17.2   16.8   15.7   14.5   14.7    12.7   17.4   17.2   19.9                    275 
# 10 AF-EGY 1495.  1478.  1503.  1700.  1664.  1629.  1251.  1247.   1329.  1658.  1844.  1608.                    2850 
# # i 210 more rows
# # i Use `print(n = ...)` to see more rows

# row = 10
# print(hydro_country_tbl[row,])

# On va faire une pause pour l'instant :
saveRDS(hydro_country_tbl,".\\src\\objects\\hydro_monthly_production_countries_2015_tbl.rds")







# #######################################
# # print(hydro_2015_tbl[1,])
# # print(hydro_2015_tbl[1,]$M1)
# # Aaaah, il y a une nuance entre [1,] et [1] !
# # et en prenant [1,] on peut prendre $M1, $M2, open...
# # peut-etre faudrait refactorer les writeInputTS comme ça
# 