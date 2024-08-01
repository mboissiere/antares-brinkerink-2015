all_deane_nodes_lst <- readRDS(".\\src\\objects\\all_deane_nodes_lst.rds")
full_2015_generators_tbl <- readRDS(".\\src\\objects\\full_2015_generators_tbl.rds")
full_2015_batteries_tbl <- readRDS(".\\src\\objects\\full_2015_batteries_tbl.rds")


# # Note : I might have to manually make categories for THE, CHE, PHS etc etc...
# # Oh wait, there it is actually, since I want to filter by PHS
# 
# # Define a function to extract the middle string from the battery_name
# extract_middle_string <- function(battery_name) {
#   return(substr(battery_name, 5, 7))
# }
# 
# # Add the battery_group column to the tibble
# full_2015_batteries_tbl <- full_2015_batteries_tbl %>%
#   mutate(battery_group = case_when(
#     extract_middle_string(battery_name) == "CHE" ~ "Chemical Battery",
#     extract_middle_string(battery_name) == "THE" ~ "Thermal",
#     extract_middle_string(battery_name) == "PHS" ~ "Pumped Hydro Storage",
#     extract_middle_string(battery_name) == "HYD" ~ "Hydrogen",
#     extract_middle_string(battery_name) == "CAE" ~ "Compressed Air Energy",
#     TRUE ~ NA_character_ # In case there are other types not listed
#   )) %>%
#   select(battery_name, continent, node, battery_group, units, capacity, max_power, initial_state, efficiency)
# 
# # print(full_2015_batteries_tbl)
# 
# saveRDS(full_2015_batteries_tbl, file = ".\\src\\objects\\full_2015_batteries_tbl.rds")


# print(full_2015_generators_tbl)

# preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
# source(preprocessPlexosData_module)
# 
# batteries_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
#   # Initialization of batteries table with only generator names and continent of origin
#   filter(class == "Battery") %>%
#   select(name, category) %>%
#   rename(battery_name = name,
#          continent = category)
# 
# # Adding country/node info to each battery
# batteries_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
#   filter(parent_class == "Battery" & child_class == "Node") %>%
#   rename(battery_name = parent_object,
#          node = child_object) %>%
#   left_join(batteries_tbl, by = "battery_name")
# 
# # No need for mutating the battery names to uppercase, because no Ninja dataset.
# 
# batteries_tbl <- batteries_tbl %>%
#   select(battery_name, continent, node)
# 
# battery_properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
#   filter(collection == "Batteries") %>% #& scenario == "{Object}Include All Storage") %>%
#   # No bueno, le include all storage est que sur units et du coup ça fait disparaitre le reste
#   # Mais comment sélectionner le bon units du coup...
#   filter(!(property == "Units" & scenario != "{Object}Include All Storage")) %>%
#   # Bien, mais ça suffit pas : il y a une duplication sur "Max Power" là où
#   # il y a à la fois includePHS et include all storage
#   # le plus simple est de virer les include PHS (même si ça veut pas dire qu'on
#   # exclut les PHS, ça vaut bien de le rendre clair ptet)
#   filter(!(property == "Max Power" & scenario == "{Object}Include PHS")) %>%
#   rename(battery_name = child_object)
# 
# batteries_tbl <- batteries_tbl %>%
#   left_join(battery_properties_tbl, by = "battery_name") %>%
#   select(battery_name, continent, node, property, value)
# 
# batteries_tbl <- batteries_tbl %>%
#   pivot_wider(names_from = property, values_from = value) %>%
#   rename(
#     units = "Units",
#     capacity = "Capacity",
#     max_power = `Max Power`,
#     initial_state = `Initial SoC`,
#     efficiency = `Charge Efficiency`
#   )
# 
# full_2015_batteries_tbl <- batteries_tbl
# print(full_2015_batteries_tbl)
# 
# saveRDS(full_2015_batteries_tbl, file = ".\\src\\objects\\full_2015_batteries_tbl.rds")