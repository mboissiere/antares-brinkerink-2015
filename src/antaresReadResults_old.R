# A peu près sûr que ce fichier est complètement inutile mais j'ai pas envie
# de le supprimer et que tout explose

###########

# Chargement des packages nécessaires
# library(antaresRead)
library(antaresProcessing)
library(antaresViz)

source("parameters.R")
source(".\\src\\logging.R")

# Ouais faut vraiment rendre ça plus propre
# (cf readResultsComments.R)


if (!CREATE_STUDY) {
  study_name = IMPORT_STUDY_NAME
  study_path = file.path("input", "antares_presets", study_name,
                         fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
  logMain(msg)
}
if (!LAUNCH_SIMULATION) {
  simulation_name = IMPORT_SIMULATION_NAME
} else {
  simulation_name = -1
}
setSimulationPath(study_path, simulation_name)

if (simulation_name == -1) {
  msg = "[MAIN] - Opening latest simulation..."
  logMain(msg)
  } else {
    msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
    logMain(msg)
  }

setRam(16)

# start_date <- "2015-01-01"
# end_date <- "2015-12-31"

source(".\\src\\antaresReadResults_aux\\productionStacksPresets.R")
source(".\\src\\data\\addNodes.R")

################################################################################

# initializeOutputFolder <- function(
#     #nodes
#     ) {
#   # output_dir = file.path("output", "test")
#   output_dir = paste0("./output/results_", study_name, "-sim-",
#                       simulation_name
#                       )
#   # msg = "[OUTPUT] - Initializing output folder..."
#   # logFull(msg)
#   if (!dir.exists(output_dir)) {
#   dir.create(output_dir)
#   }
#
#
#   continents_dir <- file.path(output_dir, "continent_graphs")
#   if (!dir.exists(continents_dir)) {
#     dir.create(continents_dir)
#   }
#
#   countries_dir <- file.path(output_dir, "country_graphs")
#   if (!dir.exists(countries_dir)) {
#     dir.create(countries_dir)
#   }
#
#   nodes_tbl <- getNodesTable(nodes)
#   continents <- nodes_tbl$continent %>% unique()
#   for (continent in continents) {
#     continent_dir <- file.path(countries_dir, tolower(continent))
#     if (!dir.exists(continent_dir)) {
#       dir.create(continent_dir)
#     }
#
#     # Possible piste d'amélioration :
#     # faire une arborisation [1] world avec dedans des png des graphes par continent à la deane
#     # puis [6] continents avec dossiers africa, asia etc et ce que j'ai l'habitude de faire
#     # (en fait des graphes de chaque pays)
#     # ET ! dans chaque pays en fait il y a des régions finalement.
#     # dans les graphes pays, prendre en fait les districts as-chn na-usa etc au lieu des régions
#     # mais au sein de chaque continent en fait faire des dossiers genre
#     # [34] as-chn regions, [5] as-ind regions, [24] na-usa regions, etc
#     # et hop architecture monde -> continent -> pays -> région au fur et à mesure qu'on clique
#     # (avec à chaque fois des dossiers prodStack, prodMonotone, etc)
#     # (j'ai tellement envie de faire stack des exports genre dans quels pays ça part etc...)
#
#   }
#   return(output_dir)
# }

initializeOutputFolder_v2 <- function(
    # perhaps include the name of chosen palette (in parameters !) in this folder.
  # this could help create colorblind-friendly palettes all in one go
  # instead of multiplying folders and subfolders
    ) {
  output_dir = paste0("./output/results_", study_name, "-sim-",
                      simulation_name
                      )
  if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  }

  graphs_dir <- file.path(output_dir, "Graphs")
  if (!dir.exists(graphs_dir)) {
    dir.create(graphs_dir)
  }

  # On top of a "graphs" folder, make a folder of csvs
  # (that isn't exactly the raw data... but like antaresRead>tibble>csv
  # which would make it less of a pain for potential readers)

  global_dir <- file.path(graphs_dir, "1 - Global-level graphs")
  if (!dir.exists(global_dir)) {
    dir.create(global_dir)
  }

  continental_dir <- file.path(graphs_dir, "2 - Continental-level graphs")
  if (!dir.exists(continental_dir)) {
    dir.create(continental_dir)
  }

  national_dir <- file.path(graphs_dir, "3 - National-level graphs")
  if (!dir.exists(national_dir)) {
    dir.create(national_dir)
  }

  # ranking_dir <- file.path(national_dir, "Import-Export Ranking")
  # if (!dir.exists(ranking_dir)) {
  #   dir.create(ranking_dir)
  # }

  regional_dir <- file.path(graphs_dir, "4 - Regional-level graphs")
  if (!dir.exists(regional_dir)) {
    dir.create(regional_dir)
  }

  # geo_scales_dirs = c(global_dir, continental_dir, national_dir, regional_dir)

  rawdata_dir <- file.path(output_dir, "Raw data (EMPTY)")
  if (!dir.exists(rawdata_dir)) {
    dir.create(rawdata_dir)
  }
  # backupStudy(
  #   backupfile,
  #   what = "study",
  #   opts = antaresRead::simOptions(),
  #   extension = ".zip"
  # )

  # Copy of the output files of an Antares study.
  #
  # Usage
  # copyOutput(opts, extname, mcYears = "all")

  # for (folder in geo_scales_dirs) {
    # prod_stack_dir <- file.path(folder, "Production stacks")
    # # ça ça pourrait aussi ce mettre en liste genre, la liste des noms possibles
    # # de trucs qu'on peut faire
    # if (!dir.exists(prod_stack_dir)) {
    #   dir.create(prod_stack_dir)
    # }
    #
    # load_monot_dir <- file.path(folder, "Load monotones")
    # if (!dir.exists(load_monot_dir)) {
    #   dir.create(load_monot_dir)
    # }
    #
    # emis_histo_dir <- file.path(folder, "Emissions histograms")
    # if (!dir.exists(emis_histo_dir)) {
    #   dir.create(emis_histo_dir)
    # }
    # Only in continental for now. Honestly I should just put these
    # outside of initiation.. initiate should only be for output_dir
    #
    # genr_histo_dir <- file.path(folder, "Generation histograms")
    # if (!dir.exists(genr_histo_dir)) {
    #   dir.create(genr_histo_dir)
    # }
    # NB : this is actually only implemented in continental so far
  # }
  return(output_dir)
}

# initializeOutputFolder()

# et après faut ptet du preprocessing de AntaresRead genre...
# on prend areas et district, on prend des tolower du geography_tbl et on fait un
# countries, un continents, un regions qui vient remplacer le prod_data

# ou bien un objet antaresread nouveau à chaque fois genre
# for country in geography
# if .isna region aller mettre le nom dans areas ou dans districts
# if country = node peut-être
# fin jsp parcourir row par row


################################################################################

HEIGHT = 2*1080
WIDTH = 2*HEIGHT
TIMESTEPS = c("hourly", "daily", "weekly", "monthly", "annual")

variables_of_interest <- c("SOLAR", "WIND",
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
                           # Tout ce qu'on a dans les histos c'est CO2 Emission et Generation
                           # (pure donc, sans batteries jpense) totale en TWh
                           # c'est donc amplement fine ce qu'on importe ici

                           # (mais j'aimerais grave importer des trucs de links !!)

                           )
# Pourrait être une variable globale vu comment elle pop souvent tbh

# Variables typiques quand on importe des liens :
# "FLOW LIN.", "UCAP LIN." et des trucs de congestion on dirait

nb_hours_in_timestep <- c(
  hourly = 1,
  daily = 24,
  weekly = 7 * 24,
  # monthly is too complicated, not implemented for now since we probably won't use it...
  annual = 52 * 7 * 24 # Antares actually optimises 52 weeks and not all 365 days.
)

variables_in_mwh = c("BALANCE", "ROW BAL.", "PSP", "MISC. NDG", "LOAD", "H. ROR", "WIND", "SOLAR",
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


variables_of_interest_in_mwh <- intersect(variables_of_interest, variables_in_mwh)

##############################
# simplify
# If TRUE and only one type of output is imported then a data.table is returned. If FALSE, the result will always be a list of class "antaresData".
getAntaresData <- function(nodes, timestep) {
  areas = getAreas(nodes)
  antares_data <- readAntares(areas = areas,
                              mcYears = NULL,#"all", # let's see if maybe it's better at averages
                              select = variables_of_interest,
                              timeStep = timestep
  )
  return(antares_data)
  }
# may seem redundant but saves time on the other variables if known
# and we might switch often from hourly, to daily, etc
# hm and yet I don't use it anymore...


##########

getGlobalData <- function(timestep, convert_to_MW = TRUE) {  # ou alors : faire des fonctions :
  # convert_to_MW, convert_to_TWh fin jsp que ce soit des procédés à part que get data

  # ATTENTION J'AI PAS ENCORE DIVISE PAR EUH 24 POUR LE DAILY SELON SI C'EST MACHIN ETC
  # Et de manière générale il faut probablement garder un truc uniforme genre. MWh partout.
  # Sinon ça contribue ptet à rendre graphes difficiles à lire. Quoique : sur les continents on connaît
  # nos capacités en GW, techno par techno.
  global_data <- readAntares(areas = NULL,
                              districts = "world", # ça pourrait être une variable etc etc
                              mcYears = NULL,
                              select = variables_of_interest,
                              timeStep = timestep,
                             simplify = TRUE
  )
  # print(global_data)
  if (convert_to_MW) {
    hours <- nb_hours_in_timestep[[timestep]]

    global_data <- global_data %>%
      mutate(across(all_of(variables_of_interest_in_mwh), ~ . / hours))
  }


  # print(global_data)

  #global_data <- as.antaresDataTable(global_data)
  # ça n'a pas l'air d'être nécessaire ?

  # à tester
  # print(antares_data)
  return(global_data)
}

geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
# print(geography_tbl)

# geography_lower_tbl <- geography_tbl %>%
#   mutate(continent = tolower(continent),
#          country = tolower(country),
#          region = tolower(region),
#          node = tolower(node)
#          )
tolowerVec <- Vectorize(tolower)
geography_lower_tbl <- as_tibble(tolowerVec(geography_tbl))
# print(geography_lower_tbl, n = 258)

continents <- geography_lower_tbl$continent %>% unique() #ça peut pas être global ça ?
# print(continents)

# NB !!!!
# On voit des choses étranges genre Asie un plateau qui s'étend sur tout midi.
# C'est un peu normal, ça s'appelle le décalage horaire !
# Pour rappel l'Excel de demande s'appelait UTC, c'est pas pour rien !

getContinentalData <- function(timestep, convert_to_MW = TRUE) {
  #hours <- nb_hours_in_timestep[[timestep]]
  # districts = getDistricts(NULL)
  # continental_districts <- intersect(districts, continents)
  # mdr c'est débile att

  continental_districts = getDistricts(select = continents,
                                       regexpSelect = FALSE)
  # antares fait déjà un taf d'intersection ! même s'il y a des districts en trop
  # dans ce qu'on passe en argument de getDistricts
  # print(districts)
  continental_data <- readAntares(areas = NULL, # ça existe ça ? j'y crois bof
                              districts = continental_districts,
                              mcYears = NULL,#"all", # let's see if maybe it's better at averages
                              select = variables_of_interest,
                              timeStep = timestep,
                              simplify = TRUE
                              )

  if (convert_to_MW) {
    hours <- nb_hours_in_timestep[[timestep]]

    continental_data <- continental_data %>%
      mutate(across(all_of(variables_of_interest_in_mwh), ~ . / hours))
  }

  # print(continental_data)
  return(continental_data)
}
# Attention à être clair : un graphe continental, c'est un graphe où les données sont
# à échelle des continents.
# un plot stack avec SEULEMENT l'europe dessus, c'est un graphe continental.
# un histogramme qui compare PLUSIEURS continents entre eux, c'est AUSSI un graphe continental.

CONTINENTS <- geography_lower_tbl$continent %>% unique() #ça peut pas être global ça ?

COUNTRIES <- geography_lower_tbl$country %>% unique() #ça peut pas être global ça ?
# print(countries)
# > getAreas(countries)
# [1] "sa-arg"    "sa-bol"    "sa-bra-cn" "sa-bra-cw" "sa-bra-j1" "sa-bra-j2" "sa-bra-j3" "sa-bra-ne"
# [9] "sa-bra-nw" "sa-bra-se" "sa-bra-so" "sa-bra-we" "sa-chl"    "sa-col"    "sa-ecu"    "sa-guf"
# [17] "sa-guy"    "sa-per"    "sa-pry"    "sa-ury"    "sa-ven"
# chelou qu'il y ait des régions là-dedans
# ok c bon ça la lisait comme des regexp

#ignore.case
#Should the case be ignored when evaluating the regular expressions ?
# depuis le début...

getNationalData <- function(timestep, convert_to_MW = TRUE) {
  country_areas = getAreas(select = COUNTRIES, #lowercase y avait un pb, verifions que si ca se trouve il FAUT que ce soit global
                           regexpSelect = FALSE)
  country_districts = getDistricts(select = COUNTRIES,
                                   regexpSelect = FALSE)

  # print(continental_districts)
  antares_data <- readAntares(areas = country_areas,
                               districts = country_districts,
                               mcYears = NULL,# again, if it's averages we want, which should be a parameter imo
                               select = variables_of_interest,
                               timeStep = timestep
  )

  areas_data <- antares_data$areas
  districts_data <- antares_data$districts

  colnames(districts_data)[colnames(districts_data) == "district"] <- "area"
  # if (!identical(colnames(areas_data), colnames(districts_data))) {
  #   stop("Columns in 'areas' and 'districts' are not identical.")
  # }
  combined_data <- rbind(areas_data, districts_data)

  if (convert_to_MW) {
    hours <- nb_hours_in_timestep[[timestep]]

    combined_data <- combined_data %>%
      mutate(across(all_of(variables_of_interest_in_mwh), ~ . / hours))
  }

  # print(combined_data)
  # Possible qu'il soit reconnu comme un "simple datatable" et non un antaresDataTable
  # de type areas. Si c'est le cas, il y a des fonctions pour interpréter un df en objet antares
  national_data <- as.antaresDataTable(combined_data, synthesis = TRUE, timeStep = timestep, type = "areas")
  # synthesis = TRUE et le fait que mcYears soit NULL / une moyenne, c'est la même je crois
  # print(national_data)
  return(national_data)
}

regions_tbl <- geography_lower_tbl %>%
  filter(!is.na(region))

# print(regions_tbl)

regions <- regions_tbl$region %>% unique() #ça peut pas être global ça ?
REGIONS <- regions
# print(regions)

getRegionalData <- function(timestep, convert_to_MW = TRUE) {
  regional_areas = getAreas(select = regions,
                            regexpSelect = FALSE)

  regional_data <- readAntares(areas = regional_areas,
                              districts = NULL,
                              mcYears = NULL,# again, if it's averages we want, which should be a parameter imo
                              select = variables_of_interest,
                              timeStep = timestep
  )

  if (convert_to_MW) {
    hours <- nb_hours_in_timestep[[timestep]]

    regional_data <- regional_data %>%
      mutate(across(all_of(variables_of_interest_in_mwh), ~ . / hours))
  }

  # print(regional_data)
  return(regional_data)
}


################################################################################

saveProductionStacks <- function(output_dir,
                                 timestep = "daily",
                                 start_date = "2015-01-01",
                                 end_date = "2015-12-31",
                                 stack_palette = "productionStackWithBatteryContributions"
) {
  # on a pas encore de global district...... mais ça a l'air fascinant en vrai... asap !
  saveGlobalProductionStack(output_dir, timestep, start_date, end_date, stack_palette)
  saveContinentalProductionStacks(output_dir, timestep, start_date, end_date, stack_palette) # unit en argument ?
  #avec un par défaut ?
  saveNationalProductionStacks(output_dir, timestep, start_date, end_date, stack_palette)
  saveRegionalProductionStacks(output_dir, timestep, start_date, end_date, stack_palette)

  # Idée : MWh pour pays, GWh pour continents, TWh pour monde
  # OU en vrai de vrai
  # MWh pour région, GWh pour pays, TWh pour continent, PWh pour monde
  # ptdr les PETA WATT HEURE unité de fou
  # (on va dire kTWh hein)

  # Wow y a pas de solaire au Brésil genre ??
}

################################################################################

saveGlobalProductionStack <- function(output_dir,
                                      timestep = "daily",
                                      start_date = "2015-01-01",
                                      end_date = "2015-12-31",
                                      stack_palette = "productionStackWithBatteryContributions"
) {
  msg = "[MAIN] - Preparing to save global production stack..."
  logMain(msg)

  global_data <- getGlobalData(timestep)

  global_dir <- file.path(output_dir, "Graphs", "1 - Global-level graphs")

  # prod_stack_dir <- file.path(global_dir, "Production stacks")
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(global_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }



  global_unit = "TWh"
  # peut etre qu'un truc ce serait genre
  # faire une fonction auxilliaire "saveproductionstack" avec en argument bah juste le node et le data
  # et après hop la diff entre global/regional c'est jsute ce qu'on met dans le For
  stack_plot <- prodStack(
      x = global_data,
      stack = stack_palette,
      areas = "world",
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste(timestep, "production stack for the world in 2015", global_unit),
      unit = global_unit,
      interactive = FALSE
    )
    png_path = file.path(prod_stack_dir, "world.png")
    savePlotAsPng(stack_plot, file = png_path,
                  width = WIDTH, #3*WIDTH,
                  height = HEIGHT # 2*HEIGHT)
    )
    #msg = paste("[OUTPUT] - The", timestep, "production stack for", cont, "from", start_date, "to", end_date, "has been saved!")
  msg = "[MAIN] - Done saving global production stack!" # et l'art du timer, il se perd...
  # Et en fait c'est ptet pas là qu'il faudrait mettre le main, sinon incohérence avec les autres trucs où l'on précise timestep et date etc
  logMain(msg)
}


saveContinentalProductionStacks <- function(output_dir,
                                            timestep = "daily",
                                            start_date = "2015-01-01",
                                            end_date = "2015-12-31",
                                            stack_palette = "productionStackWithBatteryContributions"
                                 # pour le colorblind check, faire un "colorblindify" pour aperçus
) {
  msg = "[MAIN] - Preparing to save continental production stacks..."
  logMain(msg)

  continental_data <- getContinentalData(timestep)

  # # Il m'a fait que l'amérique du nord, ch elou
  # print(as_tibble(continental_data))

  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")

  # prod_stack_dir <- file.path(continental_dir, "Production stacks")
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(continental_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }

  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
  #print(continents)

  continental_unit = "GWh"

  for (cont in continents) {
    stack_plot <- prodStack(
      x = continental_data,
      stack = stack_palette,
      areas = cont,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste(timestep, "production stack for", cont, "in 2015", continental_unit),
      unit = continental_unit,
      interactive = FALSE
    )
    msg = paste("[OUTPUT] - Saving production stack for", cont, "continent...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(cont, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = WIDTH, #3*WIDTH,
                  height = HEIGHT # 2*HEIGHT)
    )
    msg = paste("[OUTPUT] - The", timestep, "production stack for", cont, "from", start_date, "to", end_date, "has been saved!")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving continental production stacks!" # et l'art du timer, il se perd...
  logMain(msg)
}


saveNationalProductionStacks <- function(output_dir,
                                         timestep = "daily",
                                         start_date = "2015-01-01",
                                         end_date = "2015-12-31",
                                         stack_palette = "productionStackWithBatteryContributions"
) {
  msg = "[MAIN] - Preparing to save national production stacks..."
  logMain(msg)

  national_data <- getNationalData(timestep)

  # Il m'a fait que l'amérique du nord, ch elou
  # print(national_data)

  national_dir <- file.path(output_dir, "Graphs", "3 - National-level graphs")

  # prod_stack_dir <- file.path(national_dir, "Production stacks")
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(national_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }

  countries <- getAreas(select = COUNTRIES, regexpSelect = FALSE)
  # on va faire plus simple...
  districts <- getDistricts(select = COUNTRIES, regexpSelect = FALSE)
  # districts <- getDistricts(select = national_data$district %>% unique(),
  #                       regexpSelect = FALSE)
  # print(countries)
  # print(districts)
  # ceci ne devrait pas marcher..
  # [1] "na-cri" "na-cub" "na-dom" "na-gtm" "na-hnd" "na-jam" "na-mex" "na-nic" "na-pan" "na-slv" "na-tto" "sa-arg" "sa-bol" "sa-chl" "sa-col"
  # [16] "sa-ecu" "sa-guf" "sa-guy" "sa-per" "sa-pry" "sa-ury" "sa-ven"
  # [1] "na-can"        "na-usa"        "north america" "sa-bra"        "south america"
  countries <- c(countries, districts)
  countries <- sort(countries) # ce sera plus propre dans création de fichiers psk
  # les pays régionalisés peuvent se retrouver en bas tsais
  # print(countries)

  national_unit = "MWh"

  for (ctry in countries) {
    stack_plot <- prodStack(
      x = national_data,
      stack = stack_palette,
      areas = ctry,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste(timestep, "production stack for", ctry, "in 2015", national_unit),
      unit = national_unit,
      interactive = FALSE
    )
    msg = paste("[OUTPUT] - Saving production stack for", ctry, "country...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(ctry, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = WIDTH, #3*WIDTH,
                  height = HEIGHT # 2*HEIGHT)
    )
    msg = paste("[OUTPUT] - The", timestep, "production stack for", ctry, "from", start_date, "to", end_date, "has been saved!")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving national production stacks!" # et l'art du timer, il se perd...
  logMain(msg)
}
# Le géothermique devrait pas etre tout en bas, avant même éolien et solaire en vrai ?


saveRegionalProductionStacks <- function(output_dir,
                                         timestep = "daily",
                                         start_date = "2015-01-01",
                                         end_date = "2015-12-31",
                                         stack_palette = "productionStackWithBatteryContributions"
) {
  msg = "[MAIN] - Preparing to save regional production stacks..."
  logMain(msg)

  regional_data <- getRegionalData(timestep)
  #print(regional_data)

  # # Il m'a fait que l'amérique du nord, ch elou
  # print(as_tibble(continental_data))

  regional_dir <- file.path(output_dir, "Graphs", "4 - Regional-level graphs")

  # prod_stack_dir <- file.path(regional_dir, "Production stacks")
  prod_stack_folder <- paste("Production stacks", "-", timestep, "from", start_date, "to", end_date)
  prod_stack_dir <- file.path(regional_dir, prod_stack_folder)
  if (!dir.exists(prod_stack_dir)) {
    dir.create(prod_stack_dir)
  }

  regions <- getAreas(select = REGIONS, regexpSelect = FALSE)
  #print(regions)

  regional_unit = "MWh"

  for (regn in regions) {
    stack_plot <- prodStack(
      x = regional_data,
      stack = stack_palette,
      areas = regn,
      dateRange = c(start_date, end_date),
      timeStep = timestep,
      main = paste(timestep, "production stack for", regn, "in 2015", regional_unit), # where tf parentheses
      unit = regional_unit,
      interactive = FALSE
    )
    msg = paste("[OUTPUT] - Saving production stack for", regn, "region...")
    logFull(msg)
    png_path = file.path(prod_stack_dir, paste0(regn, ".png"))
    savePlotAsPng(stack_plot, file = png_path,
                  width = WIDTH, #3*WIDTH,
                  height = HEIGHT # 2*HEIGHT)
    )
    msg = paste("[OUTPUT] - The", timestep, "production stack for", regn, "from", start_date, "to", end_date, "has been saved!")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving regional production stacks!" # et l'art du timer, il se perd...
  logMain(msg)
}

# Pretty good ! Messy, but good

# Now, histograaaams !

###########################################################
# saveProductionStacks <- function(output_dir,
#                                  timestep = "daily",
#                                  stack_palette = "productionStackWithBatteryContributions"
#                                  # pour le colorblind check, faire un "colorblindify" pour aperçus
# ) {
#   msg = "[OUTPUT] - Preparing to save production stacks to output folder..."
#   logFull(msg)
#
#   # IL DOIT BIEN Y AVOIR UN MOYEN DE LE FAIRE TOUT D'UN COUP
#   # (ou bien je vais juste 4 fonctions horriblement similaires et puis juste
#   # saveProductionStacks = l'enchainement des 4 ? ça me parait nul...)
#
#   # Provisoire psk j'ai pas encore le district monde
#   # D'ailleurs ce code est à tester avec des runs partiels, et des runs monde
#   # genre est-ce que si j'ai juste 6 vieux noeuds ou 3 continents il pete un cable
#   # global_data <- getGlobalData(timestep)
#   continental_data <- getContinentalData(timestep)
#   national_data <- getNationalData(timestep)
#   regional_data <- getRegionalData(timestep)
#
#   # antares_datatables_lst <- c(global_data, continental_data, national_data, regional_data)
#   # # ceci est extremement ghetto, voyons voir si c'est autorisé par la convention de Genève
#   # # ok bah ça marche pas
#
#   # global_dir <- file.path(output_dir, "1 - Global-level graphs")
#   continental_dir <- file.path(output_dir, "2 - Continental-level graphs")
#   national_dir <- file.path(output_dir, "3 - National-level graphs")
#   regional_dir <- file.path(output_dir, "4 - Regional-level graphs")
#   ## Tout ça c'est global à chaque truc.. Est-ce qu'on pourrait pas le garder
#   # de côté, en vrai ??
#
#   # geo_scales_dirs = c(global_dir, continental_dir, national_dir, regional_dir)
#
#   folder_name = "Production stacks" # déjà initialisé aussi d'ailleurs
#   # c'est si moche jpp
#   # et puis là je fais quoi... un for machin avec global dir et global data ??
#   # ça aurait pu juste être l'affaire de... fin faire une même fonctio navec des "modes" jsp
#   # c'est terrible
#
#   # bon je vais faire un truc atroce au début mais voilà hein
#
#
#   country_graphs_dir = file.path(output_folder, "country_graphs")
#   nodes_tbl <- getNodesTable(nodes)
#   continents <- nodes_tbl$continent %>% unique()
#   # for (cnt in continents) {
#
#     # nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
#     # nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
#     #
#     # prod_stack_dir <- file.path(country_graphs_dir, tolower(cnt), "productionStack")
#     # maybe could be part of the global variables / config
#     # but the ones that we don't touch too much unlike parameters
#
#   unit = "GWh"
#     # Idée : MWh pour pays, GWh pour continents, TWh pour monde
#   # }
# }

################################################################################

# saveCountryProductionStacks <- function(nodes,
#                                         output_folder,
#                                         stack_palette = "productionStackWithBatteryContributions",
#                                         timestep = "daily"
#                                         ) {
#   msg = "[OUTPUT] - Preparing to save production stacks to output folder..."
#   logFull(msg)
#   areas = getAreas(nodes)
#   prod_data <- getAntaresData(nodes, timestep)
#
#   country_graphs_dir = file.path(output_folder, "country_graphs")
#   nodes_tbl <- getNodesTable(nodes)
#   continents <- nodes_tbl$continent %>% unique()
#   for (cnt in continents) {
#
#     nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
#     nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
#
#     prod_stack_dir <- file.path(country_graphs_dir, tolower(cnt), "productionStack")
#     # maybe could be part of the global variables / config
#     # but the ones that we don't touch too much unlike parameters
#
#     unit = "GWh"
#     for (country in nodes_in_continent) {
#       if (stack_palette == "dynamic") {
#         null_variables = list()
#         for (variable in variables_of_interest) {
#           var_in_area_df <- readAntares(areas = country,
#                                         mcYears = "all",
#                                         timeStep = timestep,
#                                         select = variable
#           )[[variable]]
#           df_is_null <- all(var_in_area_df == 0)
#           if (df_is_null) {
#             null_variables <- c(null_variables, variable)
#           }
#         }
#         createFilteredStack(stack_palette, null_variables)
#       }
#
#       stack_plot <- prodStack(
#         x = prod_data,
#         stack = stack_palette,
#         areas = country,
#         dateRange = c(start_date, end_date),
#         timeStep = timestep,
#         main = paste(timestep, "production stack for", country, "in 2015", unit),
#         unit = unit,
#         interactive = FALSE
#       )
#       msg = paste("[OUTPUT] - Saving", timestep, "production stack for", country, "node...")
#       logFull(msg)
#       png_path = file.path(prod_stack_dir, paste0(country, "_", timestep, ".png"))
#       savePlotAsPng(stack_plot, file = png_path,
#                     width = WIDTH, #3*WIDTH,
#                     height = HEIGHT # 2*HEIGHT)
#                     )
#       msg = paste("[OUTPUT] - The", timestep, "production stack for", country, "has been saved!")
#       logFull(msg)
#     }
#   }
# }

################################################################################
# NB : this one doesn't work so far

saveUnsuppliedAndSpillage <- function(nodes,
                                      output_folder,
                                      timestep
                                      ) {
  areas = getAreas(nodes)
  energy_data <- readAntares(areas = areas,
                           mcYears = "all",
                           select = c("UNSP. ENRG", "SPIL. ENRG"),
                           timeStep = timestep
  )
  msg = "[OUTPUT] - Preparing to save load monotones to output folder..."
  logFull(msg)
  country_graphs_dir = file.path(output_folder, "country_graphs")
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  for (cnt in continents) {
    nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
    nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
    unsp_spil_dir <- file.path(country_graphs_dir, tolower(cnt), "unsuppliedAndSpillage")
    if (!dir.exists(unsp_spil_dir)) {
      dir.create(unsp_spil_dir)
    }
    unit = "MWh"
    for (country in nodes_in_continent) {
      ts_plot <- plot(
        x = energy_data,
        type = "ts",
        variable =  -`UNSP. ENRG`,
        colors = "red",
        elements = country,
        dateRange = c(start_date, end_date),
        main = paste(timestep, "unsupplied energy for", country, "in 2015 (MWh)"),
        interactive = FALSE
        )
      msg = paste("[OUTPUT] - Saving", timestep, "unsupplied/spilled energy for", country, "node...")
      logFull(msg)
      png_path = file.path(unsp_spil_dir, paste0(country, "_", timestep, ".png"))
      savePlotAsPng(ts_plot, file = png_path,
                    width = WIDTH,
                    height = HEIGHT)
      msg = paste("[OUTPUT] - The", timestep, "unsupplied/spilled energy for", country, "has been saved!")
      logFull(msg)
    }
  }
}

################################################################################

resolution_dpi = 300
height_pixels = 2*1080
width_pixels = 2*height_pixels

sources <- c("NUCLEAR", "WIND", "SOLAR", "MISC. DTG", "H. STOR",
                    "MIX. FUEL", "GAS", "COAL", "OIL", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4",
                    "PSP_closed_withdrawal", "Battery_withdrawal", "Other1_withdrawal",
                    "Other2_withdrawal", "Other3_withdrawal",
                    "BALANCE", "UNSP. ENRG")

sources_new <- c("NUCLEAR", "WIND", "SOLAR", "GEOTHERMAL", "HYDRO",
                 "BIO AND WASTE", "GAS", "COAL", "OIL", "OTHER",
                 "PSP STOR", "CHEMICAL STOR", "THERMAL STOR", "HYDROGEN STOR", "COMPRESSED AIR STOR", # à comprendre comme une injection
                 "IMPORTS", "UNSUPPLIED")

library(dplyr)
library(tidyr)
library(ggplot2)

################################


saveGlobalLoadMonotone <- function(output_dir,
                                    timestep = "hourly"
) {
  msg = "[MAIN] - Preparing to save global load monotone..."
  logMain(msg)

  global_data <- getGlobalData(timestep)
  global_tbl <- as_tibble(global_data)
  # print(continental_tbl)

  global_dir <- file.path(output_dir, "Graphs", "1 - Global-level graphs")

  load_monot_dir <- file.path(global_dir, "Load monotones")

  if (!dir.exists(load_monot_dir)) {
    dir.create(load_monot_dir, recursive = TRUE)
  }

  world <- getDistricts(select = "world", regexpSelect = FALSE)
  #print(continents)

  # unit = "GWh"

  glob_tbl <- global_tbl %>%
    filter(district == "world")

  glob_tbl_sorted <- glob_tbl[order(-glob_tbl$LOAD), ] %>%
    select(timeId, time, LOAD, sources)

  glob_tbl_succint <- glob_tbl_sorted %>%
    mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
           IMPORTS = -BALANCE) %>%
    select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
    rename(
      GEOTHERMAL = `MISC. DTG`,
      HYDRO = `H. STOR`,
      `BIO AND WASTE` = `MIX. FUEL`,
      `PSP STOR` = `PSP_closed_withdrawal`,
      `CHEMICAL STOR` = `Battery_withdrawal`,
      `THERMAL STOR` = `Other1_withdrawal`,
      `HYDROGEN STOR` = `Other2_withdrawal`,
      `COMPRESSED AIR STOR` = `Other3_withdrawal`,
      UNSUPPLIED = `UNSP. ENRG`
    )

  glob_tbl_long <- glob_tbl_succint %>%
    select(time, LOAD, sources_new) %>%
    pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production")

  glob_tbl_long$energy_source <- factor(glob_tbl_long$energy_source, levels = rev(sources_new))


  # Calculate the percentage of time
  glob_tbl_long <- glob_tbl_long %>%
    mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)
  # Ah but this is incorrect because it uses long and so it's like ??? Uh??

  # # A tibble: 148,512 x 5
  # time                   LOAD energy_source production percent_time
  # <dttm>                <dbl> <fct>              <dbl>        <dbl>
  #   1 2015-01-08 13:00:00 3152131 NUCLEAR           369183     0
  # 2 2015-01-08 13:00:00 3152131 WIND               66367     0.000673
  # 3 2015-01-08 13:00:00 3152131 SOLAR              52667     0.00135
  # 4 2015-01-08 13:00:00 3152131 GEOTHERMAL         13178     0.00202
  # 5 2015-01-08 13:00:00 3152131 HYDRO             551312     0.00269
  # 6 2015-01-08 13:00:00 3152131 BIO AND WASTE     107908     0.00337
  # 7 2015-01-08 13:00:00 3152131 GAS               468406     0.00404
  # 8 2015-01-08 13:00:00 3152131 COAL             1449232     0.00471
  # 9 2015-01-08 13:00:00 3152131 OIL                63354     0.00539
  # 10 2015-01-08 13:00:00 3152131 OTHER               6903     0.00606

  # print(glob_tbl_sorted)
  # print(glob_tbl_long)

  # Assuming glob_tbl_sorted is already calculated as before
  max_value <- max(glob_tbl_long$LOAD)
  min_value <- min(glob_tbl_long$LOAD)

  # Indexes for maximum and minimum positions
  max_index <- 1  # Since the data is sorted in descending order
  min_index <- 100 #I mean maybe coz we have percentages ?
  # Very experimental stuff here

  p <- ggplot(glob_tbl_long, aes(x = percent_time)) +
    # geom_bar(aes(y = production, fill = energy_source), stat = "identity") +
    geom_area(aes(y = production, fill = energy_source), position = "stack") +  # Stacked area for energy sources
    #geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
    geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +  # Load duration curve as a step function
    scale_fill_manual(values = c("GEOTHERMAL" = "springgreen", "NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "HYDRO" = "blue",
                                 "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                                 "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                                 "IMPORTS" = "grey", "UNSUPPLIED" = "grey25")) +
    labs(x = "Percentage of Time (%)", y = "Production (MWh)", fill = "world energy mix") +
    # bcp de choses ici qui dépendent de unit, ce serait bien de le streamline...
    theme_minimal() +
    theme(
      legend.position = "right",
      legend.text = element_text(size = 8), # Legend text size
      legend.title = element_text(size = 10), # Legend title size
      legend.key.size = unit(0.4, "cm"), # Size of the legend keys
      legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
      legend.margin = margin(0, 0, 0, 0), # Margin around the legend
      legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box

      axis.title.x = element_text(size = 10), # X-axis title size
      axis.title.y = element_text(size = 10), # Y-axis title size

      axis.text.x = element_text(size = 8), # X-axis labels size
      axis.text.y = element_text(size = 8)  # Y-axis labels size
    ) +
    # Add annotations for the maximum and minimum values
    annotate("text", x = max_index, y = max_value, label = paste("Peak:", round(max_value, 2)),
             vjust = -1, hjust = 0, color = "black", size = 3) +  # Adjust vjust/hjust as needed
    annotate("text", x = min_index, y = max_value, label = paste("Base:", round(min_value, 2)), # y = min_value before, but not as convenient
             vjust = 1, hjust = 1, color = "black", size = 3)

  # One thing is odd. In the load monotone, the peak is at 315..., but in the daily stack,
  # value doesn't seem to be at 3.1
  # maybe I would have to get an hourly graph to truly truly verify it. It's not like it's completely stupid.
  # But this whole "get the daily but divide by 24" might create some averaging shenanigans and confusion.

  plot_path <- file.path(load_monot_dir, "world_monotone.png")
  ggsave(filename = plot_path, plot = p,
         width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
         dpi = resolution_dpi)

  msg = "[MAIN] - Done saving global load monotone!"
  logMain(msg)
}


saveContinentalLoadMonotones <- function(output_dir,
                                         timestep = "hourly" #,
                                      #stack_palette = "productionStackWithBatteryContributions"
                                      # pour l'instant implémenté en dur dans ce code, mais ça peut changer oui
                                      ) {
  msg = "[MAIN] - Preparing to save continental load monotones..."
  logMain(msg)

  continental_data <- getContinentalData(timestep)
  continental_tbl <- as_tibble(continental_data)
  # print(continental_tbl)

  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")

  load_monot_dir <- file.path(continental_dir, "Load monotones")

  if (!dir.exists(load_monot_dir)) {
    dir.create(load_monot_dir, recursive = TRUE)
  }

  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
    #print(continents)

  continental_unit = "GWh"

  for (cont in continents) {
    cont_tbl <- continental_tbl %>%
      filter(district == cont)

    cont_tbl_sorted <- cont_tbl[order(-cont_tbl$LOAD), ] %>%
      select(timeId, time, LOAD, sources)

    cont_tbl_succint <- cont_tbl_sorted %>%
      mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
             IMPORTS = -BALANCE) %>%
      select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
      rename(
        GEOTHERMAL = `MISC. DTG`,
        HYDRO = `H. STOR`,
        `BIO AND WASTE` = `MIX. FUEL`,
        `PSP STOR` = `PSP_closed_withdrawal`,
        `CHEMICAL STOR` = `Battery_withdrawal`,
        `THERMAL STOR` = `Other1_withdrawal`,
        `HYDROGEN STOR` = `Other2_withdrawal`,
        `COMPRESSED AIR STOR` = `Other3_withdrawal`,
        UNSUPPLIED = `UNSP. ENRG`
      )

    cont_tbl_long <- cont_tbl_succint %>%
      select(time, LOAD, sources_new) %>%
      pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production")

    cont_tbl_long$energy_source <- factor(cont_tbl_long$energy_source, levels = rev(sources_new))

    # Calculate the percentage of time
    cont_tbl_long <- cont_tbl_long %>%
      mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)

    # Assuming glob_tbl_sorted is already calculated as before
    max_value <- max(cont_tbl_long$LOAD)
    min_value <- min(cont_tbl_long$LOAD)

    # Indexes for maximum and minimum positions
    max_index <- 1  # Since the data is sorted in descending order
    min_index <- 100 #I mean maybe coz we have percentages ?
    # Very experimental stuff here

    p <- ggplot(cont_tbl_long, aes(x = percent_time)) +
      # geom_bar(aes(y = production, fill = energy_source), stat = "identity") +
      geom_area(aes(y = production, fill = energy_source), position = "stack") +  # Stacked area for energy sources
      #geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
      geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +  # Load duration curve as a step function
      scale_fill_manual(values = c("GEOTHERMAL" = "springgreen", "NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "HYDRO" = "blue",
                                   "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                                   "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                                   "IMPORTS" = "grey", "UNSUPPLIED" = "grey25")) +
      labs(x = "Percentage of Time (%)", y = "Production (MWh)", fill = paste(cont, "energy mix")) +
      # bcp de choses ici qui dépendent de unit, ce serait bien de le streamline...
      theme_minimal() +
      theme(
        legend.position = "right",
        legend.text = element_text(size = 8), # Legend text size
        legend.title = element_text(size = 10), # Legend title size
        legend.key.size = unit(0.4, "cm"), # Size of the legend keys
        legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
        legend.margin = margin(0, 0, 0, 0), # Margin around the legend
        legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box

        axis.title.x = element_text(size = 10), # X-axis title size
        axis.title.y = element_text(size = 10), # Y-axis title size

        axis.text.x = element_text(size = 8), # X-axis labels size
        axis.text.y = element_text(size = 8)  # Y-axis labels size
      ) +
      # Add annotations for the maximum and minimum values
      annotate("text", x = max_index, y = max_value, label = paste("Peak:", round(max_value, 2)),
               vjust = -1, hjust = 0, color = "black", size = 3) +  # Adjust vjust/hjust as needed
      annotate("text", x = min_index, y = max_value, label = paste("Base:", round(min_value, 2)), # y = min_value before, but not as convenient
               vjust = 1, hjust = 1, color = "black", size = 3)

    msg = paste("[OUTPUT] - Saving", timestep, "load monotone for", cont, "node...")
    logFull(msg)
    plot_path <- file.path(load_monot_dir, paste0(cont,"_monotone.png"))
    ggsave(filename = plot_path, plot = p,
           width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
           dpi = resolution_dpi)
    msg = paste("[OUTPUT] - The", timestep, "load monotone for", cont, "has been saved!")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving continental load monotones!"
  logMain(msg)
}

# Une idée en plus : mettre en légende d'abscisse le pourcentage genre de 0 à 100, comme ça on peut lire graphiquement
# lire "pendant 50% de l'année on a tant de production)

saveNationalLoadMonotones <- function(output_dir,
                                         timestep = "hourly" #,
                                         #stack_palette = "productionStackWithBatteryContributions"
                                         # pour l'instant implémenté en dur dans ce code, mais ça peut changer oui
) {
  msg = "[MAIN] - Preparing to save national load monotones..."
  logMain(msg)

  national_data <- getNationalData(timestep)
  national_tbl <- as_tibble(national_data)

  # print(national_data)

  national_dir <- file.path(output_dir, "Graphs", "3 - National-level graphs")

  load_monot_dir <- file.path(national_dir, "Load monotones")

  if (!dir.exists(load_monot_dir)) {
    dir.create(load_monot_dir, recursive = TRUE)
  }

  countries <- getAreas(select = COUNTRIES, regexpSelect = FALSE)
  districts <- getDistricts(select = COUNTRIES, regexpSelect = FALSE)
  countries <- c(countries, districts)
  countries <- sort(countries)

  national_unit = "MWh"

  for (ctry in countries) {
    ctry_tbl <- national_tbl %>%
      filter(area == ctry)

    ctry_tbl_sorted <- ctry_tbl[order(-ctry_tbl$LOAD), ] %>%
      select(timeId, time, LOAD, sources)

    ctry_tbl_succint <- ctry_tbl_sorted %>%
      mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
             IMPORTS = -BALANCE) %>%
      select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
      rename(
        GEOTHERMAL = `MISC. DTG`,
        HYDRO = `H. STOR`,
        `BIO AND WASTE` = `MIX. FUEL`,
        `PSP STOR` = `PSP_closed_withdrawal`,
        `CHEMICAL STOR` = `Battery_withdrawal`,
        `THERMAL STOR` = `Other1_withdrawal`,
        `HYDROGEN STOR` = `Other2_withdrawal`,
        `COMPRESSED AIR STOR` = `Other3_withdrawal`,
        UNSUPPLIED = `UNSP. ENRG`
      )

    ctry_tbl_long <- ctry_tbl_succint %>%
      select(time, LOAD, sources_new) %>%
      pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production")

    ctry_tbl_long$energy_source <- factor(ctry_tbl_long$energy_source, levels = rev(sources_new))

    # Calculate the percentage of time
    ctry_tbl_long <- ctry_tbl_long %>%
      mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)

    # Assuming glob_tbl_sorted is already calculated as before
    max_value <- max(ctry_tbl_long$LOAD)
    min_value <- min(ctry_tbl_long$LOAD)

    # Indexes for maximum and minimum positions
    max_index <- 1  # Since the data is sorted in descending order
    min_index <- 100 #I mean maybe coz we have percentages ?
    # Very experimental stuff here

    p <- ggplot(ctry_tbl_long, aes(x = percent_time)) +
      # geom_bar(aes(y = production, fill = energy_source), stat = "identity") +
      geom_area(aes(y = production, fill = energy_source), position = "stack") +  # Stacked area for energy sources
      #geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
      geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +  # Load duration curve as a step function
      scale_fill_manual(values = c("GEOTHERMAL" = "springgreen", "NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "HYDRO" = "blue",
                                   "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                                   "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                                   "IMPORTS" = "grey", "UNSUPPLIED" = "grey25")) +
      labs(x = "Percentage of Time (%)", y = "Production (MWh)", fill = paste(ctry, "energy mix")) +
      # ATTENTION pour l'instant tout est en MWh il me semble
      # c'est pas comme antaresViz où "GWh" est passé dans les unités
      # bcp de choses ici qui dépendent de unit, ce serait bien de le streamline...
      theme_minimal() +
      theme(
        legend.position = "right",
        legend.text = element_text(size = 8), # Legend text size
        legend.title = element_text(size = 10), # Legend title size
        legend.key.size = unit(0.4, "cm"), # Size of the legend keys
        legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
        legend.margin = margin(0, 0, 0, 0), # Margin around the legend
        legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box

        axis.title.x = element_text(size = 10), # X-axis title size
        axis.title.y = element_text(size = 10), # Y-axis title size

        axis.text.x = element_text(size = 8), # X-axis labels size
        axis.text.y = element_text(size = 8)  # Y-axis labels size
      ) +
      # Add annotations for the maximum and minimum values
      annotate("text", x = max_index, y = max_value, label = paste("Peak:", round(max_value, 2)),
               vjust = -1, hjust = 0, color = "black", size = 3) +  # Adjust vjust/hjust as needed
      annotate("text", x = min_index, y = max_value, label = paste("Base:", round(min_value, 2)), # y = min_value before, but not as convenient
               vjust = 1, hjust = 1, color = "black", size = 3)

    msg = paste("[OUTPUT] - Saving", timestep, "load monotone for", ctry, "node...")
    logFull(msg)
    plot_path <- file.path(load_monot_dir, paste0(ctry,"_monotone.png"))
    ggsave(filename = plot_path, plot = p,
           width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
           dpi = resolution_dpi)
    msg = paste("[OUTPUT] - The", timestep, "load monotone for", ctry, "has been saved!")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving national load monotones!"
  logMain(msg)
}

saveRegionalLoadMonotones <- function(output_dir,
                                      timestep = "hourly" #,
                                      #stack_palette = "productionStackWithBatteryContributions"
                                      # pour l'instant implémenté en dur dans ce code, mais ça peut changer oui
) {
  msg = "[MAIN] - Preparing to save national load monotones..."
  logMain(msg)

  regional_data <- getRegionalData(timestep)
  regional_tbl <- as_tibble(regional_data)

  regional_dir <- file.path(output_dir, "Graphs", "4 - Regional-level graphs")

  load_monot_dir <- file.path(regional_dir, "Load monotones")

  if (!dir.exists(load_monot_dir)) {
    dir.create(load_monot_dir, recursive = TRUE)
  }

  regions <- getAreas(select = REGIONS, regexpSelect = FALSE)

  regional_unit = "MWh"

  for (regn in regions) {
    regn_tbl <- regional_tbl %>%
      filter(area == regn)

    regn_tbl_sorted <- regn_tbl[order(-regn_tbl$LOAD), ] %>%
      select(timeId, time, LOAD, sources)

    regn_tbl_succint <- regn_tbl_sorted %>%
      mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
             IMPORTS = -BALANCE) %>%
      select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
      rename(
        GEOTHERMAL = `MISC. DTG`,
        HYDRO = `H. STOR`,
        `BIO AND WASTE` = `MIX. FUEL`,
        `PSP STOR` = `PSP_closed_withdrawal`,
        `CHEMICAL STOR` = `Battery_withdrawal`,
        `THERMAL STOR` = `Other1_withdrawal`,
        `HYDROGEN STOR` = `Other2_withdrawal`,
        `COMPRESSED AIR STOR` = `Other3_withdrawal`,
        UNSUPPLIED = `UNSP. ENRG`
      )

    regn_tbl_long <- regn_tbl_succint %>%
      select(time, LOAD, sources_new) %>%
      pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production")

    regn_tbl_long$energy_source <- factor(regn_tbl_long$energy_source, levels = rev(sources_new))

    # Calculate the percentage of time
    regn_tbl_long <- regn_tbl_long %>%
      mutate(percent_time = (row_number() - 1) / (n() - 1) * 100)

    # Assuming glob_tbl_sorted is already calculated as before
    max_value <- max(regn_tbl_long$LOAD)
    min_value <- min(regn_tbl_long$LOAD)

    # Indexes for maximum and minimum positions
    max_index <- 1  # Since the data is sorted in descending order
    min_index <- 100 #I mean maybe coz we have percentages ?
    # Very experimental stuff here

    p <- ggplot(regn_tbl_long, aes(x = percent_time)) +
      # geom_bar(aes(y = production, fill = energy_source), stat = "identity") +
      geom_area(aes(y = production, fill = energy_source), position = "stack") +  # Stacked area for energy sources
      geom_step(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +  # Load duration curve as a step function
      scale_fill_manual(values = c("GEOTHERMAL" = "springgreen", "NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "HYDRO" = "blue",
                                   "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
                                   "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
                                   "IMPORTS" = "grey", "UNSUPPLIED" = "grey25")) +
      labs(x = "Percentage of Time (%)", y = "Production (MWh)", fill = paste(regn, "energy mix")) +
      # ATTENTION pour l'instant tout est en MWh il me semble
      # c'est pas comme antaresViz où "GWh" est passé dans les unités
      # bcp de choses ici qui dépendent de unit, ce serait bien de le streamline...
      theme_minimal() +
      theme(
        legend.position = "right",
        legend.text = element_text(size = 8), # Legend text size
        legend.title = element_text(size = 10), # Legend title size
        legend.key.size = unit(0.4, "cm"), # Size of the legend keys
        legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
        legend.margin = margin(0, 0, 0, 0), # Margin around the legend
        legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box

        axis.title.x = element_text(size = 10), # X-axis title size
        axis.title.y = element_text(size = 10), # Y-axis title size

        axis.text.x = element_text(size = 8), # X-axis labels size
        axis.text.y = element_text(size = 8)  # Y-axis labels size
      ) +
      # Add annotations for the maximum and minimum values
      annotate("text", x = max_index, y = max_value, label = paste("Peak:", round(max_value, 2)),
               vjust = -1, hjust = 0, color = "black", size = 3) +  # Adjust vjust/hjust as needed
      annotate("text", x = min_index, y = max_value, label = paste("Base:", round(min_value, 2)), # y = min_value before, but not as convenient
               vjust = 1, hjust = 1, color = "black", size = 3)

    msg = paste("[OUTPUT] - Saving", timestep, "load monotone for", regn, "node...")
    logFull(msg)
    plot_path <- file.path(load_monot_dir, paste0(regn,"_monotone.png"))
    ggsave(filename = plot_path, plot = p,
           width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
           dpi = resolution_dpi)
    msg = paste("[OUTPUT] - The", timestep, "load monotone for", regn, "has been saved!")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving regional load monotones!"
  logMain(msg)
}

####

# BOISSIERE Matteo
# Sur cette histoire de trous qu'on avait vu sur les monotones de consommation, j'ai l'impression que c'est juste une limite de l'interface graphique. On avait été surpris de voir quelques bandes par-ci par-là, mais sur cet exemple et en zoomant, on voit que ça ressemble fort à des "bandes" unit…
#
# Un contournement simple pourrait être de passer par un geom_step() plutôt qu'un histogramme.
#


saveLoadMonotones <- function(output_dir,
                              timestep = "hourly"
                              ) {
  saveGlobalLoadMonotone(output_dir, timestep)
  saveContinentalLoadMonotones(output_dir, timestep)
  saveNationalLoadMonotones(output_dir, timestep)
  saveRegionalLoadMonotones(output_dir, timestep)
  
}

#################################

# saveCountryProductionMonotones <- function(nodes,
#                                            output_dir,
#                                            timestep = "hourly") {
#   hourly_prod_data <- getAntaresData(nodes, timestep)
#   hourly_prod_tbl <- as_tibble(hourly_prod_data)
#
#   areas = getAreas(nodes)
#
#   nodes_tbl <- getNodesTable(nodes)
#   continents <- nodes_tbl$continent %>% unique()
#   for (cnt in continents) {
#     nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
#     nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
#     continent_dir <- file.path(output_dir, "country_graphs", cnt)
#     for (country in nodes_in_continent) {
#       area_tbl <- hourly_prod_tbl %>%
#         filter(area == country)
#
#       area_tbl_sorted <- area_tbl[order(-area_tbl$LOAD), ] %>%
#         select(timeId, time, LOAD, sources)
#
#       area_tbl_succint <- area_tbl_sorted %>%
#         mutate(OTHER = `MISC. DTG 2` + `MISC. DTG 3` + `MISC. DTG 4`,
#                IMPORTS = -BALANCE) %>%
#         select(-`MISC. DTG 2`, -`MISC. DTG 3`, -`MISC. DTG 4`) %>%
#         rename(
#           GEOTHERMAL = `MISC. DTG`,
#           HYDRO = `H. STOR`,
#           `BIO AND WASTE` = `MIX. FUEL`,
#           `PSP STOR` = `PSP_closed_withdrawal`,
#           `CHEMICAL STOR` = `Battery_withdrawal`,
#           `THERMAL STOR` = `Other1_withdrawal`,
#           `HYDROGEN STOR` = `Other2_withdrawal`,
#           `COMPRESSED AIR STOR` = `Other3_withdrawal`,
#           UNSUPPLIED = `UNSP. ENRG`
#         )
#
#       area_tbl_long <- area_tbl_succint %>%
#         select(time, LOAD, sources_new) %>%
#         pivot_longer(cols = sources_new, names_to = "energy_source", values_to = "production_mwh")
#
#       area_tbl_long$energy_source <- factor(area_tbl_long$energy_source, levels = rev(sources_new))
#
#       # La production est mille fois trop grande, c'est peut-être un problème des mc years...
#
#
#       p <- ggplot(area_tbl_long, aes(x = reorder(time, -LOAD))) +
#         geom_bar(aes(y = production_mwh, fill = energy_source), stat = "identity") +
#         geom_line(aes(y = LOAD, group = 1), color = "black", linewidth = 0.5) +
#         scale_fill_manual(values = c("NUCLEAR" = "yellow", "WIND" = "turquoise", "SOLAR" = "orange",  "GEOTHERMAL" = "springgreen", "HYDRO" = "blue",
#                                      "BIO AND WASTE" = "darkgreen", "GAS" = "red", "COAL" = "darkred", "OIL" = "darkslategray", "OTHER" = "lavender",
#                                      "PSP STOR" = "darkblue", "CHEMICAL STOR" = "goldenrod", "THERMAL STOR" = "burlywood", "HYDROGEN STOR" = "darkmagenta", "COMPRESSED AIR STOR" = "salmon",
#                                      "IMPORTS" = "grey", "UNSUPPLIED" = "grey25")) +
#         labs(x = "Load (in reverse order)", y = "Production (MWh)", fill = paste(country, "energy mix")) +
#         theme_minimal() +
#         theme(
#           legend.position = "right",
#           legend.text = element_text(size = 8), # Legend text size
#           legend.title = element_text(size = 10), # Legend title size
#           legend.key.size = unit(0.4, "cm"), # Size of the legend keys
#           legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
#           legend.margin = margin(0, 0, 0, 0), # Margin around the legend
#           legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box
#
#           axis.title.x = element_text(size = 10), # X-axis title size
#           axis.title.y = element_text(size = 10), # Y-axis title size
#
#           axis.text.x = element_text(size = 8), # X-axis labels size
#           axis.text.y = element_text(size = 8)  # Y-axis labels size
#         )
#
#       msg = paste("[OUTPUT] - Saving", timestep, "load monotone for", country, "node...")
#       logFull(msg)
#       plot_path <- file.path(continent_dir, "productionMonotone", paste0(country,"_monotone.png"))
#       ggsave(filename = plot_path, plot = p,
#              width = width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
#              dpi = resolution_dpi)
#       msg = paste("[OUTPUT] - The", timestep, "load monotone for", country, "has been saved!")
#       logFull(msg)
#     }
#   }
#   # faudrait ajouter la défaillance aussi...
# }

# Next step : continental graphs
# Setting districts via antaresEditObject and antaresRead sounds like
# the easiest, honestly
# not only districts for disaggregated countries (USA, China)
# but also for continents

# Voir en tout cas si y a pas moyen d'avoir des monotones sur AntaresViz.
# le passage par ggplot2 est quand même assez long en temps de calcul, rien à voir
# par rapport aux stacks de production faits sur AntaresViz...
# (10s pour un stack vs 3 min pour une monotone (qui s'est mm pas sauvegardée))
# update : plutôt 45s en vrai, ça va un peu mieux. et la sauvegarde c'était une question de répertoire.
# et ça peut aussi faciliter le travail si les districts sont implémentées

################################################################################

saveImportExportRanking <- function(output_dir) {
                        # timestep = "annual") # does it have any other sense otherwise ?
  msg = "[MAIN] - Preparing to save import/export ranking of countries..."
  logMain(msg)

  national_data <- getNationalData("annual", FALSE)

  national_dir <- file.path(output_dir, "Graphs", "3 - National-level graphs")

  ranking_dir <- file.path(national_dir, "Import-Export Ranking")

  if (!dir.exists(ranking_dir)) {
    dir.create(ranking_dir, recursive = TRUE)
  }

  # Convert data to tibble
  national_tbl <- as_tibble(national_data)

  # Create a column for export/import status
  national_tbl <- national_tbl %>%
    mutate(BALANCE_TWH = BALANCE/MWH_IN_TWH,
           EXPORT_TWH = -BALANCE_TWH,
           Status = ifelse(BALANCE > 0, "Export", "Import"))
  # ça n'a aucun sens mais ça marche comme ça
  # de manière générale faudrait vrmt faire un truc genre...
  # "convert antares data to twh" ou un truc comme ça..............

  # print(national_tbl)

  # Filter out countries with zero import/export balance
  national_tbl <- national_tbl %>%
    filter(BALANCE_TWH != 0)

  # Sort the data by BALANCE in descending order
  national_tbl <- national_tbl %>%
    arrange(EXPORT_TWH)

  # print(national_tbl, n = 250)

  # Create the bar plot with perfect alignment
  p <- ggplot(national_tbl, aes(x = reorder(area, EXPORT_TWH), y = BALANCE_TWH, fill = Status)) +
    geom_bar(stat = "identity", width = 0.8) +  # Adjust width if needed
    scale_fill_manual(values = c("Export" = "green", "Import" = "red")) +
    labs(x = "Country", y = "Export (TWh)", title = "Country Export/Import Balance") +
    #scale_x_discrete(expand = c(0, 0)) +  # Remove space around the bars
    scale_y_continuous(sec.axis = dup_axis(name = "Export (TWh)")) +  # Duplicate y-axis on the right
    geom_text(aes(label = ifelse(abs(BALANCE_TWH) >= 10, round(BALANCE_TWH, 0), round(BALANCE_TWH, 1))),
              vjust = ifelse(national_tbl$BALANCE_TWH > 0, -0.5, 1.5),  # Position labels above or below the bars
              hjust = 0.5,  # Center the text horizontally
              size = 2) +  # Adjust size as needed

    geom_vline(xintercept = seq(1.5, nrow(national_tbl) - 0.5, by = 1), color = "grey90", linetype = "solid") +  # Vertical lines for readability
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = 0, r = 5, b = 0, l = -5)),  # Adjusting text position
          axis.ticks.x = element_blank(),  # Remove default ticks to avoid misalignment
          legend.position = "none",

          # Make the grid lines dotted
          panel.grid.major.x = element_line(color = "grey90", linetype = "dotted", size = 0.5),  # Separation lines between bars
          #panel.grid.major.y = element_line(color = "gray", linetype = "dotted", size = 0.5)   # Horizontal grid lines behind bars

          axis.title.y.right = element_text(margin = margin(l = 10)))  # Add space between axis and text

  plot_path <- file.path(ranking_dir, "allCountries.png") # ici, peut-être pertinent de faire
  # seulement quelques pays
  # par contre faut se décider monsieur : je fais de l'anglais ou du français ?
  # cf noms de dossiers vs légendes des graphes hehe
  ggsave(filename = plot_path, plot = p,
         width = 1.5 * width_pixels/resolution_dpi, height = height_pixels/resolution_dpi,
         # is a particularly wide graph...
         dpi = resolution_dpi)

    msg = "[MAIN] - Import/export ranking of countries has been saved !"
    logMain(msg)
}


################################################################################


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
# Ou alors stocker directement... hm.. attends

# 18 Oil country level north america            73.8
# 19 Oil               south america           107.
# 20 Oil               north america           107.
# Quel enfer, ça veut dire il faut faire ça générateur par générateur ?
# Ou alors mettre genre en Other4 le oil country level vs oil pas country level
# et après on peut le récupérer, mais on peut quand même faire la même couleur sur
# AntaresViz en faisant OIL = la somme des deux.....
# ohlala

# de façon provisoire on va tej Oil..

# print(emissions_tbl)

continental_data <- getContinentalData("annual")
continental_tbl <- as_tibble(continental_data) %>%
  select(district, timeId, COAL, GAS, OIL)

# for (fuel in c("COAL", "GAS", "OIL")) {
#   co2_column = paste0(fuel,"_CO2")
#   continental_tbl <- mutate(
#     co2_column = case_when(
#       district == "Gas" ~ "GAS",
#       fuel_type == "Coal" ~ "COAL",
#       fuel_type == "Oil country level" ~ "OIL",
#       TRUE ~ NA_character_ # In case there are other types not listed
#     )) %>%
#   )
# }

# bon jsp je suis paumé un peu

# print(continental_tbl)

# Histogram time babey

HEIGHT_720P = 720

##############################

# Explicitly load the necessary packages
library(ggplot2)
library(tidyverse)


deane_result_variables = c("MIX. FUEL", "COAL", "GAS", "MISC. DTG", "H. STOR", "NUCLEAR", "OIL", "SOLAR", "WIND")
new_deane_result_variables = c("Bio and Waste", "Coal", "Gas", "Geothermal", "Hydro", "Nuclear", "Oil", "Solar", "Wind")

# technology_colors <- c(
#   "Bio and Waste" = "#006400",  # Dark Green
#   "Coal" = "#808080",           # Grey
#   "Gas" = "#FF0000",            # Red
#   "Geothermal" = "#8B4513",     # SaddleBrown
#   "Hydro" = "#1E90FF",          # DodgerBlue
#   "Nuclear" = "#FFD700",        # Gold
#   "Oil" = "#8B0000",            # DarkRed
#   "Solar" = "#FFA500",          # Orange
#   "Wind" = "#4682B4"            # SteelBlue
# )

technology_colors <- c(
    "Bio and Waste" = "darkgreen",
    "Coal" = "darkred",
    "Gas" = "red",
    "Geothermal" = "springgreen",
    "Hydro" = "blue",
    "Nuclear" = "yellow",
    "Oil" = "darkslategray",
    "Solar" = "orange",
    "Wind" = "turquoise"
  )

# Idée : déjà renommer les trucs dans getContinentalData ? psk là il va y avoir MISC DTG
# alors que je veux avoir écrit bio and waste, geothermal etc
MWH_IN_TWH = 1000000

saveContinentalGenerationHistograms <- function(output_dir,
                                                timestep = "annual" # ici je l'ai mm pas utilisé je crois
                                                # ah si dans l'import..
                                                # c'est vrai qu'on pourrait en faire d'autres. est-ce utile ?
                                              # This is the Deane-type histogram
) {
  msg = "[MAIN] - Preparing to save continental generation histograms..."
  logMain(msg)

  continental_data <- getContinentalData(timestep, FALSE)
  continental_tbl <- as_tibble(continental_data)
  # print(continental_tbl)

  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")

  genr_histo_dir <- file.path(continental_dir, "Generation histograms")

  if (!dir.exists(genr_histo_dir)) {
    dir.create(genr_histo_dir, recursive = TRUE)
  }

  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)

  # continental_unit = "TWh"

  continental_tbl <- continental_tbl %>%
    # Rename variables
    rename(`Bio and Waste` = `MIX. FUEL`,
           Coal = COAL,
           Gas = GAS,
           Geothermal = `MISC. DTG`,
           Hydro = `H. STOR`,
           Nuclear = NUCLEAR,
           Oil = OIL,
           Solar = SOLAR,
           Wind = WIND
    ) %>%
    mutate(across(all_of(new_deane_result_variables), ~ . / MWH_IN_TWH)) %>% # convert to TWh
    select(district, new_deane_result_variables)

  # print(continental_tbl)

  # Convert the data to long format
  continental_long_tbl <- continental_tbl %>%
    pivot_longer(cols = all_of(new_deane_result_variables),
                 names_to = "Technology",
                 values_to = "Generation") %>%
    mutate(Technology = factor(Technology, levels = new_deane_result_variables))

  # print(continental_long_tbl)

  for (cont in continents) {

    cont_tbl <- continental_long_tbl %>%
      filter(district == cont)

    # print(cont_tbl)


    p <- ggplot(cont_tbl, aes(x = Technology, y = Generation, fill = Technology)) +
      geom_bar(stat = "identity", position = "dodge", color = "#334D73") +

      # Add text labels above the bars
      geom_text(aes(label = round(Generation, 2)),
                vjust = -0.5, # Adjusts the vertical position of the text
                color = "black",
                size = 3.5) + # Adjust the size as needed

      # Assign specific colors to each technology
      scale_fill_manual(values = technology_colors) +

      # scale_fill_manual(values = rep("#334D73", length(new_deane_result_variables))) +
      labs(title = paste("Generation comparison", cont, "(TWh)"),
           #x = "Technology",
           y = "TWh") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "none")
      # theme(
      #   legend.position = "right",
      #   legend.text = element_text(size = 8), # Legend text size
      #   legend.title = element_text(size = 10), # Legend title size
      #   legend.key.size = unit(0.4, "cm"), # Size of the legend keys
      #   legend.spacing.x = unit(0.2, "cm"), # Spacing between legend items
      #   legend.margin = margin(0, 0, 0, 0), # Margin around the legend
      #   legend.box.margin = margin(0, 0, 0, 0), # Margin around the legend box
      #
      #   axis.title.x = element_text(size = 10), # X-axis title size
      #   axis.title.y = element_text(size = 10), # Y-axis title size
      #
      #   axis.text.x = element_text(size = 8), # X-axis labels size
      #   axis.text.y = element_text(size = 8)  # Y-axis labels size
      # )

    # histo_plot <- plot(continental_data,
    #                    variable = deane_result_variables,
    #                    elements = cont,
    #                    mcYear = "average",
    #                    type = "barplot",
    #                    dateRange = NULL,
    #                    aggregate = "none",
    #                    interactive = FALSE,
    #                    colors = "#334D73",
    #                    unit = continental_unit,
    #                    main = paste("Generation comparison", cont, "(TWh)") # aie la robustesse
    # )

    msg = paste("[OUTPUT] - Saving generation histograms for", cont, "continent...")
    logFull(msg)
    png_path = file.path(genr_histo_dir, paste0(cont, "_generation.png"))
    ggsave(filename = png_path, plot = p,
           width = 2*HEIGHT_720P/resolution_dpi, height = 2*HEIGHT_720P/resolution_dpi,
           # is a particularly wide graph...
           dpi = resolution_dpi)
    # savePlotAsPng(gener_plot, file = png_path,
    #               width = HEIGHT_720P * 2,
    #               height = HEIGHT_720P
    #               )
    msg = paste("[OUTPUT] - Done saving generation histograms for", cont, "continent !")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving continental generation histograms!"
  logMain(msg)
}


########################
KILOGRAMS_IN_TON = 1000
# The numbers are off. Perhaps they were percentages.
# So it's like, producing one MWh gives out also x% of CO2 ?
# Weird.
PERCENTAGE = 100
# But wait, they CANT be percentages, because there are values like 104 and 103...
# WHAT THE HELL IS GOING ON
TONS_IN_MEGATON = 1000000 # 10e6


# print(emissions_tbl)

saveContinentalEmissionHistograms <- function(output_dir,
                                                timestep = "annual" # ici je l'ai mm pas utilisé je crois
                                                # ah si dans l'import..
                                                # c'est vrai qu'on pourrait en faire d'autres. est-ce utile ?
                                                # This is the Deane-type histogram
) {
  msg = "[MAIN] - Preparing to save continental emission histograms..."
  logMain(msg)

  # timestep = "annual" #TEMPORARY
  continental_data <- getContinentalData(timestep, FALSE)
  continental_tbl <- as_tibble(continental_data) %>%
    select(district, timeId, time, COAL, GAS, OIL)
  # print(continental_tbl)

  # Step 1: Reshape the continental_tbl to a long format
  continental_long_tbl <- continental_tbl %>%
    pivot_longer(cols = c("COAL", "GAS", "OIL"),
                 names_to = "fuel_column",
                 values_to = "production")

  # Step 2: Join the two tibbles on the continent and fuel type
  pollution_tbl <- continental_long_tbl %>%
    left_join(emissions_tbl, by = c("district" = "continent", "fuel_column"))

  # print(pollution_tbl)

  # Step 3: Calculate pollution by multiplying production by the production_rate
  pollution_tbl <- pollution_tbl %>%
    mutate(pollution = production * production_rate,
           # pollution_tons = pollution / KILOGRAMS_IN_TON,
           pollution_percentage = pollution / PERCENTAGE,
           pollution_megatons = pollution_percentage / TONS_IN_MEGATON)
  # Still really weird...

  # print(pollution_tbl)

  # I think production rate is in kgCO2/MWh. Given how high these numbers are.
  # In the end Deane paper, the results are in MTons (so 100000 Tons)
  # and they're in the hundreds.

  # Step 4: Summarize pollution by district, timeId, and time, keeping fuel-wise pollution and total
  pollution_tbl <- pollution_tbl %>%
    group_by(district, timeId, time, fuel_column) %>%
    summarise(pollution_megatons = sum(pollution_megatons, na.rm = TRUE), .groups = 'drop')

  # print(pollution_tbl)

  # Step 5: Add a row for total pollution
  pollution_tbl <- pollution_tbl %>%
    bind_rows(
      pollution_tbl %>%
        group_by(district, timeId, time) %>%
        summarise(fuel_column = "Total", pollution_megatons = sum(pollution_megatons, na.rm = TRUE), .groups = 'drop')
    ) %>%
    arrange(district,
            timeId, time,
            factor(fuel_column, levels = c("COAL", "GAS", "OIL", "Total"))) %>%
    select(district, fuel_column, pollution_megatons)

  # print(pollution_tbl, n = 25)

    # rename(Coal = COAL,
    #        Gas = GAS,
    #        Oil = OIL)



  # # Step 5: Merge the pollution data back into the original continental_tbl
  # continental_tbl_with_pollution <- continental_tbl %>%
  #   left_join(pollution_tbl, by = c("district", "timeId", "time"))
  #
  # # Print the final tibble with the pollution column
  # print(continental_tbl_with_pollution)

  continental_dir <- file.path(output_dir, "Graphs", "2 - Continental-level graphs")

  emis_histo_dir <- file.path(continental_dir, "Emissions histograms")

  if (!dir.exists(emis_histo_dir)) {
    dir.create(emis_histo_dir, recursive = TRUE)
  }

  continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)

  # continental_tbl <- continental_tbl %>%
  #   # Rename variables
  #   rename(`Bio and Waste` = `MIX. FUEL`,
  #          Coal = COAL,
  #          Gas = GAS,
  #          Geothermal = `MISC. DTG`,
  #          Hydro = `H. STOR`,
  #          Nuclear = NUCLEAR,
  #          Oil = OIL,
  #          Solar = SOLAR,
  #          Wind = WIND
  #   ) %>%
  #   mutate(across(all_of(new_deane_result_variables), ~ . / MWH_IN_TWH)) %>% # convert to TWh
  #   select(district, new_deane_result_variables)

  # print(continental_tbl)
  #
  # # Convert the data to long format
  # continental_long_tbl <- continental_tbl %>%
  #   pivot_longer(cols = all_of(new_deane_result_variables),
  #                names_to = "Technology",
  #                values_to = "Generation") %>%
  #   mutate(Technology = factor(Technology, levels = new_deane_result_variables))

  # Ensure 'fuel_column' is a factor and levels are ordered as required
  pollution_tbl <- pollution_tbl %>%
    mutate(fuel_column = factor(fuel_column, levels = c("Total", "OIL", "GAS", "COAL")))

  # print(pollution_tbl)

  for (cont in continents) {

    # Filter the data for the current continent
    cont_data <- pollution_tbl %>%
      filter(district == cont)

    p <- ggplot(cont_data, aes(x = fuel_column, y = pollution_megatons, fill = fuel_column)) +
      geom_bar(stat = "identity", color = "black") +
      geom_text(aes(label = round(pollution_megatons, 1)),
                vjust = -0.5, size = 3.5, color = "black") +  # Add text labels above bars
      scale_fill_manual(values = c("Total" = "black", "OIL" = "darkslategray", "GAS" = "red", "COAL" = "darkred")) +
      labs(title = paste("Pollution by Fuel Type in", cont),
           x = "Fuel Type",
           y = "Pollution (Megatons)") +
      theme_minimal() +
      theme(legend.position = "none")

    msg = paste("[OUTPUT] - Saving emissions histograms for", cont, "continent...")
    logFull(msg)
    png_path = file.path(emis_histo_dir, paste0(cont, "_emissions.png"))
    ggsave(filename = png_path, plot = p,
           width = 2*HEIGHT_720P/resolution_dpi, height = 2*HEIGHT_720P/resolution_dpi,
           dpi = resolution_dpi)
    msg = paste("[OUTPUT] - Done saving emissions histograms for", cont, "continent !")
    logFull(msg)
  }

  msg = "[MAIN] - Done saving continental emissions histograms!"
  logMain(msg)
}

# The first graphs produced in Africa are too enthusiastic about Solar.
# The only way this can be explained is that CSP is indeed too much, and should be
# incorporated in storage and not directly in the Solar timeseries.

# Il y a également d'importants écarts sur le thermique. Peut-être qu'il faut
# bel et bien modéliser les pannes comme décidé.


###############################

# saveContinentalEmissionHistograms <- function(output_dir,
#                                             timestep = "annual"# c'est vrai qu'on pourrait en faire d'autres. est-ce utile ?
#                                             # stack_palette = "productionStackWithBatteryContributions"
#                                             # il n'y a pas de palette mais c'est vrai qu'il faudrait faire un stack "par technologie"
#                                             # chose qui n'est pas représentée dans CO2 EMIS. - ah, il faudra faire des calculs !
# ) {
#   msg = "[MAIN] - Preparing to save continental emission histograms..."
#   logMain(msg)
#
#   continental_data <- getContinentalData(timestep)
#   # peut-être que là ça prend son sens de mettre en argument le fait de diviser par 8736
#   # genre ici je pense qu'on veut les TWh en brut pour le coup.......
#   continental_tbl <- as_tibble(continental_data)
#   print(continental_tbl)
#
#   continental_dir <- file.path(output_dir, "2 - Continental-level graphs")
#
#   emis_histo_dir <- file.path(continental_dir, "Emission histograms")
#
#   continents <- getDistricts(select = CONTINENTS, regexpSelect = FALSE)
#   #print(continents)
#
#   continental_unit = "GWh"
#
#   #for (cont in continents) {
#
#   histo_plot <- plot(continental_data,
#        variable = "CO2 EMIS.",
#        elements = continents,
#        mcYear = "average",
#        type = "barplot",
#        dateRange = NULL, # if NULL, then all data is displayed
#        aggregate = "none",
#        # compare = ,# ah, c'est ptet ça pour les représenter côte à côte
#        interactive = FALSE,
#        colors = "black", # peut être un vecteur, ce qui m'intéresse si on arrive à faire variable par moyen..
#        # mais quel enfer, chaque centrale a son tCO2/MWh différent ?
#        # on pourrait faire pollution (tCO2/MWh), * production du moyen, quitte à faire / EMIS si on veut un pourcentage
#        # mais ça reste assez infernal...
#        # jeter un oeil à CO2_emission dans le PLEXOS et voir comment ça marche,
#        # iirc il y a une valeur par fuel_group donc Europe_Gas par exemple, ça dépend du continent et de la techno
#        # ceci pourrait être stocké quelque part, dans un tibble peut-être, mais ça reste casse-pieds
#        main = "CO2 emissions (tCO2)"
#        )
#
#     # stack_plot <- prodStack(
#     #   x = continental_data,
#     #   stack = stack_palette,
#     #   areas = cont,
#     #   dateRange = c(start_date, end_date),
#     #   timeStep = timestep,
#     #   main = paste(timestep, "production stack for", cont, "in 2015", continental_unit),
#     #   unit = continental_unit,
#     #   interactive = FALSE
#     # )
#     # msg = paste("[OUTPUT] - Saving", timestep, "production stack for", cont, "continent...")
#     # logFull(msg)
#     png_path = file.path(emis_histo_dir, "co2_emis.png")
#     savePlotAsPng(histo_plot, file = png_path,
#                   width = HEIGHT_720P * 2,
#                   height = HEIGHT_720P
#                   #width = WIDTH, #3*WIDTH,
#                   #height = HEIGHT # 2*HEIGHT)
#                   # les valeurs étaient énormes pour les grpahes daily/hourly
#                   # ça aussi le width_height ça peut changer selon le type de graphe..
#                   # peut etre faire des presets genre WIDTH_720P, WIDTH_4K etc
#     )
#     # msg = paste("[OUTPUT] -", timestep, "production stack for", cont, "has been saved!")
#     # logFull(msg)
#   #}
#
#   msg = "[MAIN] - Done saving continental emissions histograms!"
#   logMain(msg)
# }


############################

#nodes = all_deane_nodes_lst
output_dir <- initializeOutputFolder_v2()

# saveContinentalEmissionHistograms(output_dir)
# Ah puis les graphes du Deane il font des histogrammes par techno, un graphe = un continent...
# ok... moi je verrais bien une stack colorée en fait mais on peut faire comme le Deane

# Tiens : est-ce qu'un graphe des plus grands importateurs/exportateurs,
# en histogramme décroissant sur les pays, serait pas intéressant d'ailleurs ?

saveImportExportRanking(output_dir)

saveLoadMonotones(output_dir #,
                  #timestep = "daily"
)
# A faire pour les load monotones : en fait la légende devrait être plus à gauche/droite
# sinon un exempl avec des pics d'hydro exportés couvre le teste. Il faudrait aller carrément dans les
# côté des axes
# avec un texte suffisamment petit pour qu'il mange pas sur la légende non plus

# Franchement attention au fait que le oil ressemble beaucoup au unsupplied energy...

saveContinentalGenerationHistograms(output_dir)

saveContinentalEmissionHistograms(output_dir)

# saveProductionStacks(output_dir,
#                      timestep = "annual",  # On changera probablement plus souvent stack que dates par contre
#                      "2015-01-01",
#                      "2015-12-31",
#                      "productionStackForAnnual"
# )
# ptet que des bar plot serait mieux ? un truc à la mano sur ggplot ?
# là pas si ouf que ça en vrai

saveProductionStacks(output_dir,
                     timestep = "daily"#,
                     #timestep = "daily",
                     #stack_palette = "productionStackWithBatteryContributions"
                     # peut-être aussi sélection de sauvegarder que les continental, world, etc
)

# Marre de commenter décommenter, serait temps de fractionner un peu ce code...

saveProductionStacks(output_dir,
                     "hourly",
                     "2015-01-01",
                     "2015-01-08"
)

saveProductionStacks(output_dir,
                     "hourly",
                     "2015-07-01",
                     "2015-07-08")
# C'est pas intuitif parce que c'est "exclus". Ecrire incl et excl ou alors retirer un jour dans données écrites
# tel que le dossier.
# (Omega chelou parce qu'en vrai de vrai ça fait inclus sur world mais exclus sur continent ????)


# Selon l'ordre dans lequel on a envie d'avoir des trucs, on peut aussi faire genre
# getContinentalGraphs qui fait toutes les continentales (monotones, stacks, etc)

# il serait ptet malin de faire un initializeOutputfolder qui initialize que le output folder et à la rigueur graphs
# puis faire un initializecontinentsfolder fin jsp localement à chaque fois if dir exists etc
# pour éviter l'éventuelle déception d'un dossier qui est créé mais en fait vide si on a pas tout lancé

# l'intégrer aux fonctions ce serait des lignes en plus mais au moins le programme est malin et crée seulement
# ce qu'il y a à créer


# autre truc qui pourrait être malin : intégrer le variables_of_interest comme
# variable dans getContinentalData etc
# ce qui ferait que l'on épuiserait pas de l'espace mémoire utilement, on ferait des
# presets de variables utiles à importer et on n'importerait que celles-ci au moment opportun



# saveCountryProductionStacks(NODES,
#                             output_dir,
#                             "productionStackWithBatteryContributions",
#                             "hourly"
#                             )
# # pareil est-ce que nodes c'est important ? ne veut-on pas juste tout produire ?
# # à voir
# saveCountryProductionMonotones(NODES,
#                                output_dir,
#                                "hourly"#,
#                                #"hourly"
#                                )



#####################################################

# initializeOutputFolder_v2 <- function(nodes) {
#   output_dir = "./output/test"# just for testing
#
#   # output_dir = paste0("./output/results_", study_name, "-sim-",
#   #                     simulation_name
#   # )
#   msg = "[OUTPUT] - Initializing output folder..."
#   print(msg)
#   # logFull(msg)
#   if (!dir.exists(output_dir)) {
#     dir.create(output_dir)
#   }
#
#   graphs_dir <- file.path(output_dir, "graphs")
#   if (!dir.exists(graphs_dir)) {
#     dir.create(graphs_dir)
#   }
#
#   # Est-ce que c'était vraiment très malin de faire une arborescence alors que genre...
#   # on pourrait vouloir tous les graphes d'un coup, non ?
#   # peut-etre que continent_graphs + country_graphs en parallèle c'était bien depuis le début
#   # juste graphs -> dossier continent level, dossier country level, + graphes mondiaux métriques deanes
#   # dans dossier continent level, des stacks et des monotones européens etc
#   # dans dossier country level
#   # en fait juste du unordered quoi merde c'est ptet ça le mieux
#   # du continent_graphs, country_graphs, region_graphs
#   # dedans y a productionStacks et productionMonotones et C'EST TOUT et on mélange les continents
#   # et au moins on a 2 niveaux de hiérarchie et pas genre 7
#   # et au moins on peut les comparer en fait (libre à l'utilisateur de réorganiser après s'il veut)
#   # (ne serait-ce qu'en triant par ordre alphabétique avec le af-... y aura déjà une séparation)
#
#   # Note that graphs aren't the only thing.
#   # It's good practice for open-source to also return raw data, so you can work on that
#   # eg Antares results/output in txt form, or in rds form (txt seems better)
#
#   # world_dir <- file.path(graphs_dir, "[1] - World")
#   # if (!dir.exists(world_dir)) {
#   #   dir.create(world_dir)
#   # }
#
#   # Le plus simple est ptet de faire un répertoire genre regions dans countries etc
#   geography_tbl <- readRDS(".\\src\\objects\\geography_tbl.rds")
#
#   sim_geography_tbl <- geography_tbl %>%
#     filter(node %in% nodes)
#
#   continents <- sim_geography_tbl$continent %>% unique()
#   nb_continents <- length(continents)
#
#   # Step 1: Create "Continents" directory inside "World"
#   # en fait y a un monde où ça c'est mon "main" et jsuis juste obligé de construire
#   # les getProdStack machin etc dedans parce que sinon c'est infernal de re-choper les path après
#   # ou alors repartir de geography_tbl (ouais mais j'ai nommé genre [.] continents, pas malin..)
#   continents_dir <- file.path(graphs_dir, paste0("[", nb_continents,"] Continents"))
#   if (!dir.exists(continents_dir)) {
#     dir.create(continents_dir)
#   }
#
#   for (cont in continents) {
#
#     continent_dir <- file.path(continents_dir, cont)
#     if (!dir.exists(continent_dir)) {
#       dir.create(continent_dir)
#     }
#
#     sim_continent_tbl <- sim_geography_tbl %>%
#       filter(continent == cont)
#
#     countries <- sim_continent_tbl$country %>% unique()
#     nb_countries <- length(countries)
#
#     countries_dir <- file.path(continent_dir, paste0("[", nb_countries,"] Countries"))
#     if (!dir.exists(countries_dir)) {
#       dir.create(countries_dir)
#     }
#
#     for (ctry in countries) {
#
#       country_dir <- file.path(countries_dir, ctry)
#       if (!dir.exists(country_dir)) {
#         dir.create(country_dir)
#       }
#
#       sim_country_tbl <- sim_continent_tbl %>%
#         filter(country == ctry)
#
#       sim_regions_tbl <- sim_country_tbl %>%
#         filter(!is.na(region))
#
#       regions <- sim_regions_tbl$region %>%
#         unique()
#
#       nb_regions <- length(regions)
#       #if (nb_regions > 0) { # pas sûr que ce soit nécessaire (for k in vide) mais ce serait propre
#       for (regn in regions) { # ça fait automatiquement rien si regions est vide
#         regions_dir <- file.path(country_dir, paste0("[", nb_regions,"] Regions"))
#         if (!dir.exists(regions_dir)) {
#           dir.create(regions_dir)
#         }
#         }
#       #}
#
#     }
#   }
#
#   # for (row in 1:nrow(geography_tbl)) {
#   #   node_row = geography_tbl[row]
#   # }
#
#   # # Step 2: Loop through each continent and create folders
#   # sim_geography_tbl %>%
#   #   group_by(continent) %>%
#   #   do({
#   #     continent_name <- unique(.$continent)
#   #
#   #     # Create continent folder
#   #     continent_folder <- file.path(continents_dir, continent_name)
#   #     if (!dir.exists(continent_folder)) {
#   #       dir.create(continent_folder)
#   #     }
#   #
#   #     # Create "Countries" directory within continent folder
#   #     countries_dir <- file.path(continent_folder, "[y] Countries")
#   #     if (!dir.exists(countries_dir)) {
#   #       dir.create(countries_dir)
#   #     }
#   #
#   #     # Step 3: Loop through each country and create folders
#   #     .$country %>%
#   #       unique() %>%
#   #       lapply(function(country_name) {
#   #         country_folder <- file.path(countries_dir, country_name)
#   #
#   #         # Create country folder
#   #         if (!dir.exists(country_folder)) {
#   #           dir.create(country_folder)
#   #         }
#   #
#   #         # Step 4: Create region folders for countries that have regions
#   #         country_data <- filter(sim_geography_tbl, country == country_name)
#   #         if (any(!is.na(country_data$region))) {
#   #           # Loop through regions
#   #           country_data %>%
#   #             filter(!is.na(region)) %>%
#   #             .$region %>%
#   #             unique() %>%
#   #             lapply(function(region_name) {
#   #               region_folder <- file.path(country_folder, paste("[z]", region_name, sep = " "))
#   #
#   #               # Create region folder
#   #               if (!dir.exists(region_folder)) {
#   #                 dir.create(region_folder)
#   #               }
#   #
#   #               # You can create graphs here for each region and save them in this folder
#   #               # Example: save graph for the region
#   #               # plot(some_graph)
#   #               # ggsave(filename = file.path(region_folder, "graph.png"))
#   #             })
#   #         }
#   #       })
#   #   })
#
#     # Possible piste d'amélioration :
#     # faire une arborisation [1] world avec dedans des png des graphes par continent à la deane
#     # puis [6] continents avec dossiers africa, asia etc et ce que j'ai l'habitude de faire
#     # (en fait des graphes de chaque pays)
#     # ET ! dans chaque pays en fait il y a des régions finalement.
#     # dans les graphes pays, prendre en fait les districts as-chn na-usa etc au lieu des régions
#     # mais au sein de chaque continent en fait faire des dossiers genre
#     # [34] as-chn regions, [5] as-ind regions, [24] na-usa regions, etc
#     # et hop architecture monde -> continent -> pays -> région au fur et à mesure qu'on clique
#     # (avec à chaque fois des dossiers prodStack, prodMonotone, etc)
#     # (j'ai tellement envie de faire stack des exports genre dans quels pays ça part etc...)
#
#     # prod_stack_dir <- file.path(continent_dir, "productionStack")
#     # if (!dir.exists(prod_stack_dir)) {
#     #   dir.create(prod_stack_dir)
#     # }
#     #
#     # prod_mono_dir <- file.path(continent_dir, "productionMonotone")
#     # # peut-être en faire des variables globales / paramètres ?
#     # # doublement utile pour la simplification de cette fonction, et des autres
#     # if (!dir.exists(prod_mono_dir)) {
#     #   dir.create(prod_mono_dir)
#     # }
#   return(output_dir)
# }
#
# initializeOutputFolder_v2(all_deane_nodes_lst)