# source(".\\src\\featuresTest2.R")

# Objets en snake_case, fonctions en camelCase

GENERATE_2060 = FALSE
GENERATE_2060_CSP = TRUE
WORLD_NODE = TRUE
IF_STUDY_NAME = "If S4 Economy v3 (Castillo load)"
IF_SCENARIO = "S1"
LOAD_PROFILES = "Castillo" # can be "Castillo" or "Deane"

READ_2060 = TRUE
THERMAL_BELOW = TRUE
save_co2_emissions = FALSE

IMPORT_STUDY_NAME = "If S1 Economy v3 (Deane load)"
IMPORT_SIMULATION_NAME = "20241031-1357eco-S1_defaillance50k"

# IMPORT_STUDY_NAME = "If S2 Economy v3 (Deane load)"
# IMPORT_SIMULATION_NAME = "20241031-1357eco-S2_defaillance50k"
# 
# IMPORT_STUDY_NAME = "If S3 Economy v3 (Deane load)"
# IMPORT_SIMULATION_NAME = "20241031-1357eco-S3_defaillance50k"

# IMPORT_STUDY_NAME = "If S4 Economy v3 (Deane load)"
# IMPORT_SIMULATION_NAME = "20241031-1357eco-S4_defaillance50k"

# UTILISER LES OBJECTS POUR FAIRE UNE COPIE DES PARAMETRES ET LE STOCKER ET
# TRAVAILLER LA DESSUS. ON GOD.
# PARCE QUE SINON IMPOSSIBILITE DE MODIF PARAMETRES POUR LANCER DEUX ETUDES DIFF
# ex une uniform voll + hurdle costs. les hurdle costs vont se mettre à la toute fin
# sur la création des lignes donc ça va être pendant que je rompiche si je lance la nuit.
# Et jsute NODES en fait qui est appelé à tout bout de champ.


# Nom servant de base pour la classification de l'étude
study_basename <- "WorldT20B5_globGrid vf2"
# "World20T5B w hurdle costs" # pourrait être corrélé à import_study_name en vrai
INCLUDE_DATE_IN_STUDY = FALSE
# Ptn j'vais péter un câble si c'est vrai mais jcrois que si jamais l'étude a le même nom bah...
# ça overwrite déjà en fait. Tout seul.

# bug actuel : si je prends un nom qui existe déjà et que après il dit "peut pas ajouter noeud, skipping"
# ensuite il n'arrive pas à faire un global district

# INFO [2024-10-07 11:02:51] [NODES] - Adding eu-swe node...
# ERROR [2024-10-07 11:02:51] [WARN] - Could not create node eu-swe - skipping and continuing...
# INFO [2024-10-07 11:02:51] [NODES] - Adding eu-ukr node...
# ERROR [2024-10-07 11:02:51] [WARN] - Could not create node eu-ukr - skipping and continuing...
# INFO [2024-10-07 11:02:51] [MAIN] - Done adding nodes! (run time : 2.24s).
# 
# INFO [2024-10-07 11:02:51] [MAIN] - Adding districts...
# 
# INFO [2024-10-07 11:02:51] [DISTRICTS] - Creating global district...
# Error in createDistrict(name = "world", add_area = all_areas, output = TRUE) : 
#   Invalid area in 'add_area'
# De plus : Warning message:
#   Parameter 'horizon' is missing or inconsistent with 'january.1st' and 'leapyear'. Assume correct year is 2018.
# To avoid this warning message in future simulations, open the study with Antares and go to the simulation tab, put a valid year number in the cell 'horizon' and use consistent values for parameters 'Leap year' and '1st january'. 

# ouais donc mission faire derniers ajustements (retirer CSP ou l'implémenter diff,
# notamment... jsp si y a d'autres trucs ? clusteriser batteries ?)
# et lancer un run monde pour voir comment bougent les histogrammes.
# lancer rédaction du rapport en parallèle qui plongera les mains dans la doc PLEXOS, etc

RENEWABLE_GENERATION_MODELLING = "aggregated" # "aggregated" ou "clusters"

# en gros faudrait faire create/editStudy avec des overwrite de partout
# et "create" devient aussi bien "overwrite" quand on coche/décoche dans le Excel

# le test full.adjusted v full pourrait tenir en une ligne dans architecture.R, dans un monde meilleur

# Et si... on essayait sans les capacity scalers ?
# Vu qu'il y en a bcp en Europe

# petite bizarrerie pas bien méchante : seems like ça marche plus en launchsimulation actuellement
# mais, sur antaresweb ça marche. le test CHE-DEU-FRA avec et sans activateTS notamment, post-maintenance rate.
# bon.

# i just got bugs of like "oh no prepro doesnt work"... is it just a matter of writing files
# with a path name limit ????
# oh my god. yeah it really is just that.
# ok STOP HAVING LONG NAMES christ

# wow, did we cover everything ? i guess CSP as storage is the biggest thing remaining.
# holy hell, we gotta parallelize some stuff though. like load monotones. that's just TOO LONG.

# et ce serait sympa de mettre ces noms dans les logs aussi, c'est dommage de devoir les repérer par heures...
CREATE_STUDY = FALSE
# Faire un paramètre genre "duplicate to input" qui copie preset dans input
# au lieu de le garder seulement dans antares
# voire, réussir à ne plus passer par le dossier antares (mais j'y crois peu..)
# une notice README pourrait préciser espace mémoire qu'il faut pour un dossier antares
# continent/monde, d'abord vide puis avec une simulation....


# IMPORT_STUDY_NAME = "v2_20clu__2024_09_04_22_33_36" # we've had a good run

# IMPORT_STUDY_NAME = "Deane_testWorld_v1__2024_08_25_21_23_09"
# IMPORT_STUDY_NAME = "WorldT20B5 UniformVoLL v3" # "WorldT20B5 w hurdles v4"  # 

# IMPORT_STUDY_NAME = "EU_clutest__2024_09_10_21_29_47"
# NB : dans l'implémentation actuelle de readResults c'est un peu omega chiant
# genre il faut que je précise les nodes que j'étudie sans par défaut et du coup
# "ah t'as chargé l'asie ? mais tu veux regarder les nodes de l'europe cong"

# IMPORT_STUDY_NAME = "Deane_Beta_EU__2024_08_08_15_48_17" #"deaneEurope_minimal" # quand je ferai des presets
LAUNCH_SIMULATION_NAME = "acc_test"
INCLUDE_DATE_IN_SIMULATION = FALSE
LAUNCH_SIMULATION = FALSE

# IMPORT_SIMULATION_NAME = "20241029-1736adq-accurateUCM_10MCyears_v8.6"
# IMPORT_SIMULATION_NAME = "20240905-0707eco-world_vOutages_accurateUCM" # So long comrade
# IMPORT_SIMULATION_NAME = "20240826-0706eco-fastUCM_worldDistrict" # -1 for latest
# IMPORT_SIMULATION_NAME =  "20241010-0740eco-accurate_test-2" # "20241008-0629eco-accurateUCM" # "20240905-0707eco-world_vOutages_accurateUCM"
# IMPORT_SIMULATION_NAME = "20240905-0707eco-20240910-2240eco-renewabletest"
# Or what if I just want to skip it ?
# IMPORT_SIMULATION_NAME = "20240731-1517eco-simulation__2024_07_31_15_17_31" # et là aussi on peut en faire
READ_RESULTS = FALSE
# svp avancer sur export des résultats en tableau et sur division des CF par 100 en clusters

# NB : ptet faire en sorte d'automatiquement copier une nouvelle étude (si launch siulation)
# là où il faut puisque là on pioche dans antares_presets et forcément il trouve r
PLOT_TIMESTEP = "hourly" # not sure it's well integrated atm

# if (EXPORT_TO_OUTPUT_FOLDER) {
#   réfléchir à quelque chose pour faciliter la sauvegarde de captures d'écran
#   et éventuellement une duplication de presets & logs (de toute façon output est
#   dans le gitignore)
# }
EXPORT_TO_OUTPUT_FOLDER = FALSE
INCLUDE_HURDLE_COSTS = FALSE
HURDLE_COST = 0.1
UNIFORM_VOLL = FALSE

INFINITE_NTC = TRUE
GLOBAL_GRID = TRUE

deane_all_nodes_lst <- readRDS(".\\src\\objects\\deane_all_nodes_lst.rds")
deane_europe_nodes_lst <- readRDS(".\\src\\objects\\deane_europe_nodes_lst.rds")
# africa_nodes_lst <- readRDS(".\\src\\objects\\africa_nodes_lst.rds")
# asia_nodes_lst <- readRDS(".\\src\\objects\\asia_nodes_lst.rds")
# north_america_nodes_lst <- readRDS(".\\src\\objects\\north_america_nodes_lst.rds")
# south_america_nodes_lst <- readRDS(".\\src\\objects\\south_america_nodes_lst.rds")
# oceania_nodes_lst <- readRDS(".\\src\\objects\\oceania_nodes_lst.rds")

# NODES = "eu-ita"
# NODES = deane_europe_nodes_lst
NODES = deane_all_nodes_lst
# NODES = c("EU-CHE", "EU-DEU", "EU-FRA")
# NODES = c("eu-che", "eu-deu", "eu-fra")
# NODES = c("eu-fra", "eu-gbr", "eu-deu", "eu-ita", "eu-esp", "af-mar", "af-dza", "af-tun")

# NODES = tolower(c("EU-FRA", "EU-GBR", "EU-BEL", "EU-LUX", "EU-DEU", "EU-CHE", "EU-ITA", "EU-ESP",
# "SA-ARG", "SA-CHL", "SA-URY", "SA-PRY",
# "AF-ZAF", "AF-NAM", "AF-BWA", "AF-ZWE", "AF-MOZ", "AF-SWZ", "AF-LSO"))
# un bon échantillon de test pour maintenance rate, mais pour réajuster les histogrammes
# il faudra tout mettre ! cf dernier CR


# ptet faire un paramètre "catchExceptions" pour pouvoir genre.
# activer/désactiver à souhait, l'un étant mieux pour bruteforce un programme et l'autre pour identifier source de pb ?

EXPORT_MPS = TRUE
REGENERATE_OBJECTS = FALSE # if true, will recreate all R objects.
# if false, will check if they exist, and only recreate them if they don't.
# bug actuel : il regénère les objects genre 3 fois. j'ai 3 fois le "oui euh found duplicates"
# ce qui est insupportable mdrrr

# Je crois que cette feature merde parce qu'il y a un loop infini de saveObjects
# qui appelle generate et vice versa
# ah quoique ptet c juste long


# NB : toutes les fonctions qui ré-appellent "NODES" en misant dessus / sans faire
# jsp une intersection avec le jeu de données ou quoi, sont pas si robustes.
# en effet si on a envie de faire tourner deux sessions R en même temps, on peut overwrite
# et causer des erreurs, eg un run NA suivi d'un run World et qui puise des noeuds qui existent pas,
# ce qui lancent des erreurs
# (peut-être que c'est pour ça que TiTAN faisait des .bats, faisaient des copies de variables,
# et une fois que le run était lancé c'était pas touche ?)

# NODES = "EU-DEU"
# NODES = c(north_america_nodes_lst, south_america_nodes_lst)
# print(NODES)

save_daily_production_stacks = TRUE
save_hourly_production_stacks = FALSE # with start and end dates somewhere in config...
divide_stacks_by_hours = FALSE

save_load_monotones = FALSE
# divide_monotones_by_hours = TRUE # n'a aucun sens, c'est hourly par nature


save_import_export = FALSE

# save_deane_histograms = FALSE # deprecated jcrois
save_deane_comparisons = FALSE # seront totalement guez avec If mais tant pis c'est marrant
# devrait etre en 1er vu comment c'est rapide

save_global_graphs = TRUE
save_continental_graphs = FALSE
save_national_graphs = FALSE
save_regional_graphs = FALSE
save_co2_emissions = TRUE


# Ah, un truc qu'on a pas encore mis, mais qui rendraient pertinentes les années Monte-Carlo,
# c'est les pannes prévues et non prévues sur le thermique...

# Très possible que next step soit de gérer l'aggrégation. 
# Faire tous les thermiques et tous les batteries, sur un continent, ça risque de...
# ... plus être possible.
# Mais c'est bien de faire des runs et au moins j'aurai un retour genre
# "ah ce niveau d'agrégation c'est x temps à tourner avec y gigas de mémoire..."
# ça peut être de beaux jeux de données / documentation
# (tout en gardant en tête tout de même qu'il faut alors préciser specs de la machine...)

UNIT_COMMITMENT_MODE = "accurate" # "fast" or "accurate"
# it could be intelligent to include unit commitment mode in the
# simulation name, when running automatic simulation launcher.

# notons aussi que c'est débile de le print au début de la création d'étude
# comme on le fait actuellement, puisque ça n'intervient que dans la partie
# simulation



# En vrai, si on fait tourner sur VM, ça peut tout à fait être accurate.

# Ce serait bien en fait de générer les études et puis les faire tourner sur AntaresWeb en vrai.
# Oh, et puis vu que j'ai mappé le disque avec un raccourci, ptet que ya  moyen
# que mon code fasse ce genre de truc automatiquement ????
# bbon c'est osef pour l'open source mais voilà quoi
# ou du moins récup les résultats pour AntaresViz jsp

# Dans l'idéal ce serait bien aussi d'avoir une sorte de generateName intelligent avec les nodes genre
# ou un paramètre mais fin
# si j'ai europe_nodes qu'il écrive europe, si j'ai all nodes qu'il écrive monde, sinon cas par cas etc

# one extra reason that it's coherent to do tolower instead of toupper:
# that's how the .txt files in antares are

GENERATE_LOAD = TRUE
# GENERATE_REN = FALSE

GENERATE_WIND = TRUE
# Nota bene : il mouline sur le vent (haha) même pour trois points
# donc je pense qu'il réimporte des trucs là genre GenerateObjects style
GENERATE_SOLAR_PV = TRUE
# Technically my PV implementation is very bad because if I had
# solar PV off (which i never do) then I wouldn't have CSP either.
# But this is fiiiiiiiiiiiiine right.
GENERATE_SOLAR_CSP = FALSE
# ahhahaaaaahahahahaha on l'a pas fait hahaha on n'a pas mis le CSP hahahahahh
# Avoir que le CSP ça fait crasher..
# ou alors le CSP est mal mis ??

# Nota bene : les CSP font tolower() automatiquement
# est-ce que je mettrais pas les thermiques en tolower au lieu de toupper ?
# quoique pas forcément le plus dyslexique ffriendly haha*
# ça change !
GENERATE_LINES = TRUE
GENERATE_THERMAL = TRUE
# there should also be a log like... "not importing thermal"
GENERATE_HYDRO = TRUE
GENERATE_BATTERIES = TRUE
# i should really say batteries
# bc storage will be done for csp independantly
## (will it ?)

# autre subtilité : on pourrait vouloir antaresediter une simulation existante...
# par exemple là j'ai un big deane world mais je pourrais vouloir changer un truc,
# comme par exemple ajouter des districts...
# peut-être qu'il faudrait plutôt avoir antaresUpdateStudy ?
# après tout beaucoup de fonctions ont des arguments overwrite...
# peut-être qu'une districtisation au sein de readResults, ça suffirait pour l'instant...

GENERATE_DISTRICTS = TRUE
THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel", "Oil", 
                  "Other", "Other 2", "Other 3", "Other 4") #, "Other 4" is actually useless but isok
# Nota bene : comme je filoute et met directement (provisoirement) "Other4" ici
# en fait c'est pas compté dans les thermal types
# c'est géré par variable import csp qui lance le programme ou pas
# (ce qui est... très bien !)
AGGREGATE_THERMAL = TRUE
CLUSTER_THERMAL = TRUE
NB_CLUSTERS_THERMAL = 20
#NB_CLUSTERS_THERMAL = 20
CLUSTER_NAME_LIMIT = 60
#faudrait un true ou false
# CLUSTER_THERMAL = 5 # cette customisation est ARCHI FAUSSE ET PROVISOIRE
# ET PAS DU TOUT MODULABLE AUTREMENT QUE 10 ET 5 meme si ce serait facile mais en attendant
# here it will be 10. We should make it customizeable but uuuhhh 

# En vrai faire un petit morceau de maths qui explique "en fait voici pourquoi trop de variables
# c pa bi1 pour un pb d'optimisation qui inverse probablement des matrices, et du coup
# j'ai fait un algorithme de k-clustering et voici comment ça marche et en fait y a
# les k-médoides et les elbow method" ça serait une diiiiiinguerie comment ce serait intéressant
# parce que mine de rien il s'en passe des trucs sous le capot mdr
AGGREGATE_BATTERIES = TRUE
# notons que ceci influe implémentation à l'échelle de importBatteries
# c'est plus une question de "model_units_seperately" en fait vu qu'on peut
# clusteriser à balle avec un algo de k-means, mais ensuite
# modéliser les batteries aux 14 units comme séparées si on veut
# c'est donc pas le même mot à employer que ce qu'on a fait pour le thermique imo
CLUSTER_BATTERIES = TRUE
NB_CLUSTERS_BATTERIES = 5
# NB_CLUSTERS_BATTERIES = 10

# NB : in PLEXOS there are 30658 generators and 1108 batteries.
# This suggest a 30 to 1 ratio in clustering could be fine honestly.
# 15-clusters for generators and no clustering for batteries seemed to be a sweetspot for accurate runs.
# Could we try 30-clusters for generators, and, c'mon let's be nice, 5-clusters for batteries ?
# I bet accuracy would be pretty sweet, and storage space wouldn't be that insane.
# (be wary tho : if there were 1/30 batteries, then also the clustering will be 1/30 effective to reduce overall size.)


# But honestly. Add clustering to batteries because do we really need fine
# tuning with like 8 gazillion chemical batteries if their capacities are shit ?

# Everything is here now EXCEPT CSP
## Il serait bien de faire un code qui check quelles centrales existent dans ninja
## mais pas dans PLEXOS, et ensuite de voir si on retrouve les CSP dans le cas du solaire.
## (pour les éoliennes, il devrait pas y en avoir du tout, donc TRES intéressant si y en a...)

# Question que Nicolas posait aussi : y a de la défaillance en Europe ?

# bientôt battery types soon tkt
# Idée : paramétriser simplifications genre
# "get all other" ou juste geothermal
# fin en fait c'est ça mdr mais c'est peu explicite là ce serait bien de faire un
# include marémoteur qui en fait traduit ça
# et aussi le fait de faire des batteries en _k, d'agréger des clusters ou pas...

# Other being Geothermal
# could also import Other 2 but it's so minimal...
# Si on réfléchit genre 30 s je trouve ça trop bizarre le géo et le marémoteur
# en cluster thermique mais bon... je vois pas comment faire autrement.
# THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel")
# THERMAL_TYPES = c("Hard Coal", "Gas", "Nuclear", "Mixed Fuel", "Oil")
ADD_VOLL = TRUE
INCLUDE_ZERO_NTC_LINES = TRUE

PRINT_FULL_LOG_TO_CONSOLE = TRUE
# bientôt le clustering log


#### Todo: centralize but separate in different categories
# Like : addNodes parameters###
### Logging parameters ####
#etc#
DEFAULT_SCALING_FACTOR = 20



# NODES = c("EU-FRA", "EU-DEU", "EU-CHE")
#source(".\\src\\data\\addNodes.R") mdr le récursif là ouh là lààà


# # Hardcoded to avoid recursion even though we can call getAllNodes()
# DEANE_NODES_ALL = c('AF-AGO', 'AF-BDI', 'AF-BEN', 'AF-BFA', 'AF-BWA', 'AF-CAF', 
#                     'AF-CIV', 'AF-CMR', 'AF-COD', 'AF-COG', 'AF-CPV', 'AF-DJI', 
#                     'AF-DZA', 'AF-EGY', 'AF-ERI', 'AF-ESH', 'AF-ETH', 'AF-GAB', 
#                     'AF-GHA', 'AF-GIN', 'AF-GMB', 'AF-GNB', 'AF-GNQ', 'AF-KEN', 
#                     'AF-LBR', 'AF-LBY', 'AF-LSO', 'AF-MAR', 'AF-MDG', 'AF-MLI', 
#                     'AF-MOZ', 'AF-MRT', 'AF-MUS', 'AF-MWI', 'AF-NAM', 'AF-NER', 
#                     'AF-NGA', 'AF-RWA', 'AF-SDN', 'AF-SEN', 'AF-SLE', 'AF-SWZ', 
#                     'AF-TGO', 'AF-TUN', 'AF-TZA', 'AF-UGA', 'AF-ZAF', 'AF-ZMB', 
#                     'AF-ZWE', 'AS-AFG', 'AS-ARE', 'AS-BGD', 'AS-BHR', 'AS-BRN', 
#                     'AS-BTN', 'AS-CHN-AN', 'AS-CHN-BE', 'AS-CHN-CH', 'AS-CHN-EM', 
#                     'AS-CHN-FU', 'AS-CHN-GA', 'AS-CHN-GD', 'AS-CHN-GU', 'AS-CHN-GX', 
#                     'AS-CHN-HA', 'AS-CHN-HB', 'AS-CHN-HE', 'AS-CHN-HJ', 'AS-CHN-HK', 
#                     'AS-CHN-HN', 'AS-CHN-HU', 'AS-CHN-JI', 'AS-CHN-JS', 'AS-CHN-JX', 
#                     'AS-CHN-LI', 'AS-CHN-MA', 'AS-CHN-NI', 'AS-CHN-QI', 'AS-CHN-SC', 
#                     'AS-CHN-SD', 'AS-CHN-SH', 'AS-CHN-SI', 'AS-CHN-SX', 'AS-CHN-TI', 
#                     'AS-CHN-TJ', 'AS-CHN-WM', 'AS-CHN-XI', 'AS-CHN-YU', 'AS-CHN-ZH', 
#                     'AS-IDN', 'AS-IND-EA', 'AS-IND-NE', 'AS-IND-NO', 'AS-IND-SO', 
#                     'AS-IND-WE', 'AS-IRN', 'AS-IRQ', 'AS-ISR', 'AS-JOR', 'AS-JPN-CE', 
#                     'AS-JPN-HO', 'AS-JPN-KY', 'AS-JPN-OK', 'AS-JPN-SH', 'AS-JPN-TO', 
#                     'AS-KAZ', 'AS-KGZ', 'AS-KHM', 'AS-KOR', 'AS-KWT', 'AS-LAO', 
#                     'AS-LBN', 'AS-LKA', 'AS-MMR', 'AS-MNG', 'AS-MYS', 'AS-NPL', 
#                     'AS-OMN', 'AS-PAK', 'AS-PHL', 'AS-PRK', 'AS-QAT', 'AS-RUS-CE', 
#                     'AS-RUS-FE', 'AS-RUS-MV', 'AS-RUS-NW', 'AS-RUS-SI', 'AS-RUS-SO', 
#                     'AS-RUS-UR', 'AS-SAU', 'AS-SGP', 'AS-SYR', 'AS-THA', 'AS-TJK', 
#                     'AS-TKM', 'AS-TUR', 'AS-TWN', 'AS-UZB', 'AS-VNM', 'AS-YEM', 
#                     'EU-ALB', 'EU-ARM', 'EU-AUT', 'EU-AZE', 'EU-BEL', 'EU-BGR', 
#                     'EU-BIH', 'EU-BLR', 'EU-CHE', 'EU-CYP', 'EU-CZE', 'EU-DEU', 
#                     'EU-DNK', 'EU-ESP', 'EU-EST', 'EU-FIN', 'EU-FRA', 'EU-GBR', 
#                     'EU-GEO', 'EU-GRC', 'EU-HRV', 'EU-HUN', 'EU-IRL', 'EU-ISL', 
#                     'EU-ITA', 'EU-KOS', 'EU-LTU', 'EU-LUX', 'EU-LVA', 'EU-MDA', 
#                     'EU-MKD', 'EU-MNE', 'EU-NLD', 'EU-NOR', 'EU-POL', 'EU-PRT', 
#                     'EU-ROU', 'EU-SRB', 'EU-SVK', 'EU-SVN', 'EU-SWE', 'EU-UKR',
#                     'OC-ATA', 'OC-AUS-NT', 'OC-AUS-QL', 'OC-AUS-SA', 'OC-AUS-SW', 
#                     'OC-AUS-TA', 'OC-AUS-VI', 'OC-AUS-WA', 'OC-FJI', 'OC-NZL', 
#                     'OC-PNG', 'NA-CAN-AB', 'NA-CAN-AR', 'NA-CAN-BC', 'NA-CAN-MB', 
#                     'NA-CAN-NL', 'NA-CAN-NO', 'NA-CAN-ON', 'NA-CAN-QC', 'NA-CAN-SK', 
#                     'NA-CRI', 'NA-CUB', 'NA-DOM', 'NA-GTM', 'NA-HND', 'NA-JAM', 
#                     'NA-MEX', 'NA-NIC', 'NA-PAN', 'NA-SLV', 'NA-TTO', 'NA-USA-AK', 
#                     'NA-USA-AZ', 'NA-USA-CA', 'NA-USA-ER', 'NA-USA-FR', 'NA-USA-GU', 
#                     'NA-USA-HA', 'NA-USA-ME', 'NA-USA-MW', 'NA-USA-NE', 'NA-USA-NW', 
#                     'NA-USA-NY', 'NA-USA-PR', 'NA-USA-RA', 'NA-USA-RE', 'NA-USA-RM', 
#                     'NA-USA-RW', 'NA-USA-SA', 'NA-USA-SC', 'NA-USA-SE', 'NA-USA-SN', 
#                     'NA-USA-SS', 'NA-USA-SV', 'NA-USA-SW', 'SA-ARG', 'SA-BOL', 
#                     'SA-BRA-CN', 'SA-BRA-CW', 'SA-BRA-J1', 'SA-BRA-J2', 'SA-BRA-J3', 
#                     'SA-BRA-NE', 'SA-BRA-NW', 'SA-BRA-SE', 'SA-BRA-SO', 'SA-BRA-WE', 
#                     'SA-CHL', 'SA-COL', 'SA-ECU', 'SA-GUF', 'SA-GUY', 'SA-PER', 
#                     'SA-PRY', 'SA-URY', 'SA-VEN')
#   
# DEANE_NODES_EUROPE = c('EU-ALB', 'EU-ARM', 'EU-AUT', 'EU-AZE', 'EU-BEL', 'EU-BGR', 
#                        'EU-BIH', 'EU-BLR', 'EU-CHE', 'EU-CYP', 'EU-CZE', 'EU-DEU', 
#                        'EU-DNK', 'EU-ESP', 'EU-EST', 'EU-FIN', 'EU-FRA', 'EU-GBR', 
#                        'EU-GEO', 'EU-GRC', 'EU-HRV', 'EU-HUN', 'EU-IRL', 'EU-ISL', 
#                        'EU-ITA', 'EU-KOS', 'EU-LTU', 'EU-LUX', 'EU-LVA', 'EU-MDA', 
#                        'EU-MKD', 'EU-MNE', 'EU-NLD', 'EU-NOR', 'EU-POL', 'EU-PRT', 
#                        'EU-ROU', 'EU-SRB', 'EU-SVK', 'EU-SVN', 'EU-SWE', 'EU-UKR')

# C'est clairement trop brouillon personne va scroll pour changer NODES
# Il faudrait faire genre un "objects" et "variables" fin un truc qui ne change pas
# et un truc de paramètres que l'utilisateur peut être amené à bouger souvent
# (Comme je le dis depuis qq temps oups)


# NODES = DEANE_NODES_ALL
# NODES = c("EU-CHE", "EU-DEU", "EU-FRA")
# NODES = "EU-FRA"
# NODES = c("AF-MAR", "EU-ESP", "EU-DEU", "EU-FRA")


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


# zones = c("AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA")
#c("FRA", "GBR", "DEU", "ITA", "ESP")


# pour l'environnement r : faire plutot dossier "study" de sorte à pouvoir en fait faire des presets
# qui pourraient etre activés avec un machin dans parameters, téléchargées, etc

#zones = deane_nodes_df$Node
#print(zones)
#print(zones[1])
#print(getISOfromDeane(zones[1]))
#print(getAntaresCoordsFromCountry(getISOfromDeane(zones[1])))