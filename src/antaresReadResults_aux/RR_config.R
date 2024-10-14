################################################################################
################################### OBJECTS ####################################

HEIGHT_720P = 720
HEIGHT_HD = 1080
HEIGHT_4K = 2*1080
DPI_150 = 150
DPI_200 = 200
DPI_300 = 300
# Les variables avant les constantes c'est pas le plus malin en vrai...

WORLDS <- "world"
CONTINENTS <- readRDS(".\\src\\objects\\deane_continents_lst.rds")
COUNTRIES <- readRDS(".\\src\\objects\\deane_countries_lst.rds")
REGIONS <- readRDS(".\\src\\objects\\deane_regions_lst.rds")

################################################################################
################################## VARIABLES ###################################

# color_palette = "productionStackWithBatteryContributions"
color_palette = "eCO2MixFusionStack"
# NB : the palette list for load monotones isn't in config atm


variables_of_interest_areas <- c("SOLAR", "WIND",
                                 "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
                                 "LOAD",
                                 "H. STOR",
                                 "BALANCE",
                                 "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                                 "UNSP. ENRG", "SPIL. ENRG",
                                 "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
                                 "Battery_injection", "Battery_withdrawal", "Battery_level",
                                 "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
                                 "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
                                 "Other3_injection", "Other3_withdrawal", "Other3_level", # Rappel : CAE
                                 
                                 "CO2 EMIS."
                                 
                                 # (mais j'aimerais grave importer des trucs de links !!)
)


graphs_folder_names_by_mode <- c(
  global = file.path("Graphs", "1 - Global-level graphs"),
  continental = file.path("Graphs", "2 - Continental-level graphs"),
  national = file.path("Graphs", "3 - National-level graphs"),
  regional = file.path("Graphs", "4 - Regional-level graphs")
)

data_to_iterate_by_mode <- list( #c et list rien à voir en fait mdr
  global = WORLDS,
  continental = CONTINENTS,
  national = COUNTRIES,
  regional = REGIONS
)

boolean_parameter_by_mode <- c(
  global = save_global_graphs,
  continental = save_continental_graphs,
  national = save_national_graphs,
  regional = save_regional_graphs
)

# This is starting to be a mess...

preferred_unit_by_mode <- c(
  global = "TWh",
  continental = "GWh",
  national = "MWh",
  regional = "MWh"
)

# Une piste pour pouvoir faire des programmes qui généralisent, mais bon, c'est relou pour l'instant

prodstack_height <- HEIGHT_HD
prodstack_width <- 2 * HEIGHT_HD

monotone_height = HEIGHT_720P
monotone_width = 2 * HEIGHT_720P
monotone_resolution = DPI_150

importexport_height <- HEIGHT_4K
importexport_width <- 1.5 * 2 * HEIGHT_4K # Can be * 1.5 on top, if needed extra width
importexport_resolution <- DPI_300

################################################################################
################################## CONSTANTS ###################################

NB_HOURS_IN_TIMESTEP <- c(
  hourly = 1,
  daily = 24,
  weekly = 7 * 24,
  # monthly is too complicated, not implemented for now since we probably won't use it...
  annual = 52 * 7 * 24 # Antares actually optimises 52 weeks and not all 365 days.
)

MWH_IN_GWH = 1000
MWH_IN_TWH = 1000000
TONS_IN_MEGATON = 1000000

NB_MWH_IN_UNIT <- c(
  MWh = 1,
  GWh = 1000,
  TWh = 1000000
)

# Comment
# (because yes, I'll have to comment this code one day)
# Columns as of Antares v8.8 that are expressed in MWh.
# For facilitating conversion in GWh and the like.
MWH_COLUMNS = c("BALANCE", "ROW BAL.", "PSP", "MISC. NDG", "LOAD", "H. ROR", "WIND", "SOLAR",
                "NUCLEAR", "LIGNITE", "COAL", "GAS", "OIL", "MIX. FUEL",
                "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                "H. STOR", "H. PUMP", "H. INFL", 
                "PSP_open_level", "PSP_closed_level", "Pondage_level", "Battery_level", 
                "Other1_level", "Other2_level", "Other3_level", "Other4_level", "Other5_level",
                "UNSP. ENRG", "SPIL. ENRG", "AVL DTG", "DTG MRG", "MAX MRG",
                
                "PSP_open_injection", "PSP_closed_injection", "Pondage_injection", "Battery_injection", 
                "Other1_injection", "Other2_injection", "Other3_injection", "Other4_injection", "Other5_injection",
                "PSP_open_withdrawal", "PSP_closed_withdrawal", "Pondage_withdrawal", "Battery_withdrawal", 
                "Other1_withdrawal", "Other2_withdrawal", "Other3_withdrawal", "Other4_withdrawal", "Other5_withdrawal")

# Et ce n'est pas précisé dans les sorties Antares que l'injection/soutirage des batteries ce sont des MWh,
# c'est écrit "MW", mais... ce serait incohérent dans nos graphes sinon.

# A noter que le "diviser par 24" machin ca devrait etre un parametre !!
# reglable et tout pour avoir des MWh si on veut et des MW si on veut aussi !!!
  
COMMON_COLUMNS <- c("SOLAR", "WIND",
                    "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
                    "LOAD",
                    "H. STOR",
                    "BALANCE",
                    "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                    "UNSP. ENRG", "SPIL. ENRG",
                    "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
                    "Battery_injection", "Battery_withdrawal", "Battery_level",
                    "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
                    "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
                    "Other3_injection", "Other3_withdrawal", "Other3_level", # Rappel : CAE
                    
                    "CO2 EMIS."
)


ENERGY_SOURCE_COLUMNS <- c("MISC. DTG", "NUCLEAR", "WIND", "SOLAR", "H. STOR",
                           "MIX. FUEL", "GAS", "COAL", "OIL", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                           
                           "PSP_closed_injection", "PSP_closed_withdrawal",
                           "Battery_injection", "Battery_withdrawal",
                           "Other1_injection", "Other1_withdrawal",
                           "Other2_injection", "Other2_withdrawal",
                           "Other3_injection", "Other3_withdrawal",
                           
                           "BALANCE", "UNSP. ENRG", "SPIL. ENRG")

RENAMED_ENERGY_SOURCE_COLUMNS <- c("GEOTHERMAL", "NUCLEAR", "WIND", "SOLAR", "HYDRO",
                                   "BIO AND WASTE", "GAS", "COAL", "OIL", "OTHER",
                                   "PSP STOR", "CHEMICAL STOR", "THERMAL STOR", "HYDROGEN STOR", "COMPRESSED AIR STOR", # à comprendre comme une injection
                                   "IMPORTS", "UNSUPPLIED", "SPILLAGE")

emissions_data <- readRDS(".\\src\\objects\\emissions_by_continent_fuel.rds")

emissions_tbl <- emissions_data %>%
  mutate(continent = tolower(continent)) %>%
  filter(fuel_type != "Oil") %>%
  mutate(fuel_column = case_when(
    fuel_type == "Gas" ~ "GAS",
    fuel_type == "Coal" ~ "COAL",
    fuel_type == "Oil country level" ~ "OIL",
    TRUE ~ NA_character_ # In case there are other types not listed
  )) %>%
  select(continent, fuel_column, production_rate)

deane_result_variables = c("MIX. FUEL", "COAL", "GAS", "MISC. DTG", "H. STOR", "NUCLEAR", "OIL", "SOLAR", "WIND")
new_deane_result_variables = c("Bio and Waste", "Coal", "Gas", "Geothermal", "Hydro", "Nuclear", "Oil", "Solar", "Wind")
# Technically, are these constants or variables ??




# sources <- c("NUCLEAR", "WIND", "SOLAR", "MISC. DTG", "H. STOR",
#              "MIX. FUEL", "GAS", "COAL", "OIL", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
#              "PSP_closed_withdrawal", "Battery_withdrawal", "Other1_withdrawal",
#              "Other2_withdrawal", "Other3_withdrawal",
#              "BALANCE", "UNSP. ENRG")

# sources_new <- c("NUCLEAR", "WIND", "SOLAR", "GEOTHERMAL", "HYDRO",
#                  "BIO AND WASTE", "GAS", "COAL", "OIL", "OTHER",
#                  "PSP STOR", "CHEMICAL STOR", "THERMAL STOR", "HYDROGEN STOR", "COMPRESSED AIR STOR", # à comprendre comme une injection
#                  "IMPORTS", "UNSUPPLIED")

########## VARIA #################

# geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
# 
# tolowerVec <- Vectorize(tolower) # à ranger dans utils en vrai
# geography_lower_tbl <- as_tibble(tolowerVec(geography_tbl))
# 
# CONTINENTS <- geography_lower_tbl$continent %>% unique() #ça peut pas être global ça ?
# COUNTRIES <- geography_lower_tbl$country %>% unique()
# 
# regions_tbl <- geography_lower_tbl %>%
#   filter(!is.na(region))
# 
# REGIONS <- regions_tbl$region %>% unique() #ça peut pas être global ça ?