################################################################################
################################## VARIABLES ###################################

color_palette = "productionStackWithBatteryContributions"

variables_of_interest_areas <- c("SOLAR", "WIND",
                                 "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL",
                                 "LOAD",
                                 "H. STOR",
                                 "BALANCE",
                                 "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                                 "UNSP. ENRG",
                                 "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
                                 "Battery_injection", "Battery_withdrawal", "Battery_level",
                                 "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
                                 "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
                                 "Other3_injection", "Other3_withdrawal", "Other3_level", # Rappel : CAE
                                 
                                 "CO2 EMIS."
                                 
                                 # (mais j'aimerais grave importer des trucs de links !!)
)

################################################################################
################################## CONSTANTS ###################################

HEIGHT_4K = 2*1080

NB_HOURS_IN_TIMESTEP <- c(
  hourly = 1,
  daily = 24,
  weekly = 7 * 24,
  # monthly is too complicated, not implemented for now since we probably won't use it...
  annual = 52 * 7 * 24 # Antares actually optimises 52 weeks and not all 365 days.
)

MWH_IN_GWH = 1000
MWH_IN_TWH = 1000000

NB_MWH_IN_UNIT <- c(
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
                    "UNSP. ENRG",
                    "PSP_closed_injection", "PSP_closed_withdrawal", "PSP_closed_level",
                    "Battery_injection", "Battery_withdrawal", "Battery_level",
                    "Other1_injection", "Other1_withdrawal", "Other1_level", # Rappel : thermal
                    "Other2_injection", "Other2_withdrawal", "Other2_level", # Rappel : hydrogen
                    "Other3_injection", "Other3_withdrawal", "Other3_level", # Rappel : CAE
                    
                    "CO2 EMIS."
)
                           