# source(".\\src\\featuresTest2.R")

# Objets en snake_case, fonctions en camelCase

CREATE_STUDY = TRUE
IMPORT_STUDY_NAME = "blabla" # quand je ferai des presets
LAUNCH_SIMULATION = TRUE
READ_RESULTS = TRUE

# Nom servant de base pour la classification de l'étude
study_basename <- "Etude_sur_R_Monde"
# Dans l'idéal ce serait bien aussi d'avoir une sorte de generateName intelligent avec les nodes genre
# ou un paramètre mais fin
# si j'ai europe_nodes qu'il écrive europe, si j'ai all nodes qu'il écrive monde, sinon cas par cas etc

GENERATE_LOAD = TRUE
GENERATE_REN = FALSE
GENERATE_WIND = TRUE
GENERATE_SOLAR_PV = TRUE
GENERATE_SOLAR_CSP = FALSE
GENERATE_LINES = TRUE
GENERATE_THERMAL = TRUE
# THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")
THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear")
ADD_VOLL = TRUE
INCLUDE_ZERO_NTC_LINES = FALSE

PRINT_FULL_LOG_TO_CONSOLE = TRUE


#### Todo: centralize but separate in different categories
# Like : addNodes parameters###
### Logging parameters ####
#etc#
DEFAULT_SCALING_FACTOR = 25



# NODES = c("EU-FRA", "EU-DEU", "EU-CHE")
#source(".\\src\\data\\addNodes.R") mdr le récursif là ouh là lààà


# Hardcoded to avoid recursion even though we can call getAllNodes()
DEANE_NODES_ALL = c('AF-AGO', 'AF-BDI', 'AF-BEN', 'AF-BFA', 'AF-BWA', 'AF-CAF', 
                    'AF-CIV', 'AF-CMR', 'AF-COD', 'AF-COG', 'AF-CPV', 'AF-DJI', 
                    'AF-DZA', 'AF-EGY', 'AF-ERI', 'AF-ESH', 'AF-ETH', 'AF-GAB', 
                    'AF-GHA', 'AF-GIN', 'AF-GMB', 'AF-GNB', 'AF-GNQ', 'AF-KEN', 
                    'AF-LBR', 'AF-LBY', 'AF-LSO', 'AF-MAR', 'AF-MDG', 'AF-MLI', 
                    'AF-MOZ', 'AF-MRT', 'AF-MUS', 'AF-MWI', 'AF-NAM', 'AF-NER', 
                    'AF-NGA', 'AF-RWA', 'AF-SDN', 'AF-SEN', 'AF-SLE', 'AF-SWZ', 
                    'AF-TGO', 'AF-TUN', 'AF-TZA', 'AF-UGA', 'AF-ZAF', 'AF-ZMB', 
                    'AF-ZWE', 'AS-AFG', 'AS-ARE', 'AS-BGD', 'AS-BHR', 'AS-BRN', 
                    'AS-BTN', 'AS-CHN-AN', 'AS-CHN-BE', 'AS-CHN-CH', 'AS-CHN-EM', 
                    'AS-CHN-FU', 'AS-CHN-GA', 'AS-CHN-GD', 'AS-CHN-GU', 'AS-CHN-GX', 
                    'AS-CHN-HA', 'AS-CHN-HB', 'AS-CHN-HE', 'AS-CHN-HJ', 'AS-CHN-HK', 
                    'AS-CHN-HN', 'AS-CHN-HU', 'AS-CHN-JI', 'AS-CHN-JS', 'AS-CHN-JX', 
                    'AS-CHN-LI', 'AS-CHN-MA', 'AS-CHN-NI', 'AS-CHN-QI', 'AS-CHN-SC', 
                    'AS-CHN-SD', 'AS-CHN-SH', 'AS-CHN-SI', 'AS-CHN-SX', 'AS-CHN-TI', 
                    'AS-CHN-TJ', 'AS-CHN-WM', 'AS-CHN-XI', 'AS-CHN-YU', 'AS-CHN-ZH', 
                    'AS-IDN', 'AS-IND-EA', 'AS-IND-NE', 'AS-IND-NO', 'AS-IND-SO', 
                    'AS-IND-WE', 'AS-IRN', 'AS-IRQ', 'AS-ISR', 'AS-JOR', 'AS-JPN-CE', 
                    'AS-JPN-HO', 'AS-JPN-KY', 'AS-JPN-OK', 'AS-JPN-SH', 'AS-JPN-TO', 
                    'AS-KAZ', 'AS-KGZ', 'AS-KHM', 'AS-KOR', 'AS-KWT', 'AS-LAO', 
                    'AS-LBN', 'AS-LKA', 'AS-MMR', 'AS-MNG', 'AS-MYS', 'AS-NPL', 
                    'AS-OMN', 'AS-PAK', 'AS-PHL', 'AS-PRK', 'AS-QAT', 'AS-RUS-CE', 
                    'AS-RUS-FE', 'AS-RUS-MV', 'AS-RUS-NW', 'AS-RUS-SI', 'AS-RUS-SO', 
                    'AS-RUS-UR', 'AS-SAU', 'AS-SGP', 'AS-SYR', 'AS-THA', 'AS-TJK', 
                    'AS-TKM', 'AS-TUR', 'AS-TWN', 'AS-UZB', 'AS-VNM', 'AS-YEM', 
                    'EU-ALB', 'EU-ARM', 'EU-AUT', 'EU-AZE', 'EU-BEL', 'EU-BGR', 
                    'EU-BIH', 'EU-BLR', 'EU-CHE', 'EU-CYP', 'EU-CZE', 'EU-DEU', 
                    'EU-DNK', 'EU-ESP', 'EU-EST', 'EU-FIN', 'EU-FRA', 'EU-GBR', 
                    'EU-GEO', 'EU-GRC', 'EU-HRV', 'EU-HUN', 'EU-IRL', 'EU-ISL', 
                    'EU-ITA', 'EU-KOS', 'EU-LTU', 'EU-LUX', 'EU-LVA', 'EU-MDA', 
                    'EU-MKD', 'EU-MNE', 'EU-NLD', 'EU-NOR', 'EU-POL', 'EU-PRT', 
                    'EU-ROU', 'EU-SRB', 'EU-SVK', 'EU-SVN', 'EU-SWE', 'EU-UKR',
                    'OC-ATA', 'OC-AUS-NT', 'OC-AUS-QL', 'OC-AUS-SA', 'OC-AUS-SW', 
                    'OC-AUS-TA', 'OC-AUS-VI', 'OC-AUS-WA', 'OC-FJI', 'OC-NZL', 
                    'OC-PNG', 'NA-CAN-AB', 'NA-CAN-AR', 'NA-CAN-BC', 'NA-CAN-MB', 
                    'NA-CAN-NL', 'NA-CAN-NO', 'NA-CAN-ON', 'NA-CAN-QC', 'NA-CAN-SK', 
                    'NA-CRI', 'NA-CUB', 'NA-DOM', 'NA-GTM', 'NA-HND', 'NA-JAM', 
                    'NA-MEX', 'NA-NIC', 'NA-PAN', 'NA-SLV', 'NA-TTO', 'NA-USA-AK', 
                    'NA-USA-AZ', 'NA-USA-CA', 'NA-USA-ER', 'NA-USA-FR', 'NA-USA-GU', 
                    'NA-USA-HA', 'NA-USA-ME', 'NA-USA-MW', 'NA-USA-NE', 'NA-USA-NW', 
                    'NA-USA-NY', 'NA-USA-PR', 'NA-USA-RA', 'NA-USA-RE', 'NA-USA-RM', 
                    'NA-USA-RW', 'NA-USA-SA', 'NA-USA-SC', 'NA-USA-SE', 'NA-USA-SN', 
                    'NA-USA-SS', 'NA-USA-SV', 'NA-USA-SW', 'SA-ARG', 'SA-BOL', 
                    'SA-BRA-CN', 'SA-BRA-CW', 'SA-BRA-J1', 'SA-BRA-J2', 'SA-BRA-J3', 
                    'SA-BRA-NE', 'SA-BRA-NW', 'SA-BRA-SE', 'SA-BRA-SO', 'SA-BRA-WE', 
                    'SA-CHL', 'SA-COL', 'SA-ECU', 'SA-GUF', 'SA-GUY', 'SA-PER', 
                    'SA-PRY', 'SA-URY', 'SA-VEN')
  
DEANE_NODES_EUROPE = c('EU-ALB', 'EU-ARM', 'EU-AUT', 'EU-AZE', 'EU-BEL', 'EU-BGR', 
                       'EU-BIH', 'EU-BLR', 'EU-CHE', 'EU-CYP', 'EU-CZE', 'EU-DEU', 
                       'EU-DNK', 'EU-ESP', 'EU-EST', 'EU-FIN', 'EU-FRA', 'EU-GBR', 
                       'EU-GEO', 'EU-GRC', 'EU-HRV', 'EU-HUN', 'EU-IRL', 'EU-ISL', 
                       'EU-ITA', 'EU-KOS', 'EU-LTU', 'EU-LUX', 'EU-LVA', 'EU-MDA', 
                       'EU-MKD', 'EU-MNE', 'EU-NLD', 'EU-NOR', 'EU-POL', 'EU-PRT', 
                       'EU-ROU', 'EU-SRB', 'EU-SVK', 'EU-SVN', 'EU-SWE', 'EU-UKR')

# C'est clairement trop brouillon personne va scroll pour changer NODES
# Il faudrait faire genre un "objects" et "variables" fin un truc qui ne change pas
# et un truc de paramètres que l'utilisateur peut être amené à bouger souvent
# (Comme je le dis depuis qq temps oups)

# NODES = DEANE_NODES_EUROPE
NODES = c("EU-CHE", "EU-DEU", "EU-FRA")
# plutôt avoir des variables qui peuvent bcp changer en "nodes"
# et des variables vrmt statiques (comme horizon plus bas, en attendant le preset...)
# en "NODES"
# ce serait bien que preset change aussi le NOM DE L'ETUDE
# c'est tellement ridicule d'avoir écrit "Monde" quand je fais un test sur trois points


# NODES = getNodesFromContinents(c("Europe"))
# NODES = c("EU-MDA", "EU-MKD", "EU-MNE") # test on 3 problematic countries
# NODES = "EU-MDA"
# NODES = c("EU-FRA", "AF-MAR", "AS-JPN-CE", "NA-CAN-QC", "OC-NZL", "SA-CHL")
# NODES = getAllNodes()
# Bientôt le All Nodes, pour ça il faut être sur d'avoir les bons parametres sur tous les secteurs thermiques

# A terme, ce serait tellement bien d'avoir une autorisation d'upload le dossier antares dans GitHub
# (quitte à mettre genre un licensing etc dans le readme)
# puis de faire un .bat qui lance automatiquement AntaresWebWorker en lancant le programme ? jsp


# Pourrait configurer en mode : "all", "continents", "select", etc.
# avec un fichier configureNodes.R par exemple
# dans sa version ultime je verrais bien un Excel avec choix multiples pour le front utilisateur, comme pour TiTAN
# (et si on pousse TiTAN jusqu'au bout, pourquoi pas un .bat ?)

# Ce qui est pas mal avec ça c'est que je peux mettre une version de R dans le Git et
# ça fait du local
#' @echo off
#' set R_PATH="C:\Program Files\R\R-4.0.2\bin\Rscript.exe"
#' set SCRIPT_PATH="%~dp0main.R"
#' %R_PATH% %SCRIPT_PATH%
#'   pause


simulation_mode = "Economy" # "Adequacy", "Economy" ou "Draft"
horizon = 2015 # entier, année d'étude
nb_MCyears = 10 # entier, nombre d'années Monte-Carlo
# A noter que nb_MCyears est probablement une variable qui peut changer
# et, qui affecte temps de la partie LaunchSimulation

# ajouter la partie configuration, qui contient notamment TS management,
# dans le grand excel qui résume les variables Antares

RENEWABLE_GENERATION_MODELLING = "aggregated" # "aggregated" ou "clusters"

# zones = c("AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA")
#c("FRA", "GBR", "DEU", "ITA", "ESP")


# pour l'environnement r : faire plutot dossier "study" de sorte à pouvoir en fait faire des presets
# qui pourraient etre activés avec un machin dans parameters, téléchargées, etc

#zones = deane_nodes_df$Node
#print(zones)
#print(zones[1])
#print(getISOfromDeane(zones[1]))
#print(getAntaresCoordsFromCountry(getISOfromDeane(zones[1])))