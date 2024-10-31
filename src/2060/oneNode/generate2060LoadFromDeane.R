deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_2015_load_tbl.rds")
deane_all_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")

# deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_2015_load_tbl.rds") %>%
#   select(any_of(deane_all_nodes_lst)) # %>% # any_of will throw an error bc of sa-bra-j1, ...
#   # mutate(World = rowSums(across(all_of(colnames(deane_2015_load_tbl)))))
# 
# print(colnames(deane_2015_load_tbl))
# 
# saveRDS(deane_2015_load_tbl, ".\\src\\objects\\deane_2015_load_tbl.rds")
  
  # Error in `mutate()`:
  #   i In argument: `World = rowSums(across(all_of(colnames(deane_2015_load_tbl))))`.
  # Caused by error in `across()`:
  #   i In argument: `all_of(colnames(deane_2015_load_tbl))`.
  # Caused by error in `all_of()`:
  #   ! Can't subset elements that don't exist.
  # x Elements `na-can`, `na-usa`, `as-ind`, `sa-bra`, `as-jpn`, etc. don't exist.
  #### Good thing I filtered eh

deane_2015_load_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_2015_load_tbl.rds") 

deane_2015_world_tbl <- deane_2015_load_tbl %>%
  mutate(World = rowSums(across(all_of(colnames(deane_2015_load_tbl)))))

# print(colnames(deane_2015_world_tbl))
# print(deane_2015_world_tbl %>% select(World))

total_2015_deane_load <- sum(
  deane_2015_world_tbl %>% pull(World)
)

# print(total_2015_deane_load)
# Faux car doublons, corriger

S1_2060_load_vector <- c(
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
  
total_2060_S1_load <- sum(S1_2060_load_vector)
# print(total_2060_S1_load)


S2_2060_load_vector <- c(
  industry = 1005157829 + 1039721465 + 314720827 
  + 5776352632 + 3895299262 + 2250208346 + 470633068
  + 6841802624 + 5114821259 + 1114698143,
  # Agriculture + Aluminum primary production + Cement and clinker primary production 
  # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
  # + Other industries + Other materials production + Textile
  transport = 5895707113 + 3271309875,
  # Passenger transport + Freight
  residential = 10299431780,
  # Residential buildings
  service = 6519686260
  # Tertiary buildings
)

total_2060_S2_load <- sum(S2_2060_load_vector)
# print(total_2060_S2_load)


S3_2060_load_vector <- c(
  industry = 1718375364 + 2155799786 + 355660908 
  + 2308576632 + 18567800808 + 3487841159 + 632940259
  + 13930744769 + 8556489011 + 7968363598,
  # Agriculture + Aluminum primary production + Cement and clinker primary production 
  # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
  # + Other industries + Other materials production + Textile
  transport = 4720226128 + 1675724294,
  # Passenger transport + Freight
  residential = 11968109592,
  # Residential buildings
  service = 9521531857
  # Tertiary buildings
)

total_2060_S3_load <- sum(S3_2060_load_vector)
# print(total_2060_S3_load)


S4_2060_load_vector <- c(
  industry = 1010916846 + 926335599 + 297244981 
  + 2657817347 + 6786808814 + 2045068323 + 428177112
  + 7289033444 + 6047650239 + 1641929719,
  # Agriculture + Aluminum primary production + Cement and clinker primary production 
  # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
  # + Other industries + Other materials production + Textile
  transport = 6267477718 + 1848413781,
  # Passenger transport + Freight
  residential = 9644959571,
  # Residential buildings
  service = 8207072457
  # Tertiary buildings
)

total_2060_S4_load <- sum(S4_2060_load_vector)
# print(total_2060_S4_load)

load_capacity_ratios_tbl <- tibble(
  scenario = c("S1", "S2", "S3", "S4"), 
  load_capacity_ratio = c(total_2060_S1_load/total_2015_deane_load,
                     total_2060_S2_load/total_2015_deane_load,
                     total_2060_S3_load/total_2015_deane_load,
                     total_2060_S4_load/total_2015_deane_load)
)
print(load_capacity_ratios_tbl)
saveRDS(load_capacity_ratios_tbl, ".\\src\\2060\\oneNode\\load_capacity_ratios_tbl.rds")

# 
# volumesMATER2015 = c(
#   industry = 756440746 + 964867785 + 206486176 
#   + 810017230 + 2097842974 + 958089158 + 231775314
#   + 3067154595 + 2124112513 + 1092711323,
#   # Agriculture + Aluminum primary production + Cement and clinker primary production 
#   # + Digital + Energy production + Infrastructure manufactury + Iron and steel primary production
#   # + Other industries + Other materials production + Textile
#   transport = 96139319 + 96695382,
#   # Passenger transport + Freight
#   residential = 6341838625,
#   # Residential buildings
#   service = 5581947974
#   # Tertiary buildings
# )