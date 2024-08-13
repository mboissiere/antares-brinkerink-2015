# Chargement des packages nécessaires
# library(antaresRead)
library(antaresProcessing)
library(antaresViz)

source("parameters.R")
source(".\\src\\logging.R")

# Ouais faut vraiment rendre ça plus propre

# Pour faire du transfert de simulations plus simplement en format compressé :
# https://rdrr.io/cran/antaresRead/f/vignettes/antaresH5.Rmd


if (!CREATE_STUDY) {
  study_name = IMPORT_STUDY_NAME
  study_path = file.path("input", "antares_presets", study_name,
                         fsep = .Platform$file.sep)
  msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
  # jsp pourquoi mais ça le print genre 3 fois
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
  # ça aussi
  logMain(msg)
  } else {
    msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
    logMain(msg)
  }

# Error in readAntares(areas = "all", links = "all", clusters = "all", mcYears = "all",  : 
#                        You want to load more than 10Go of data,
#                      if you want you can modify antaresRead rules of RAM control with setRam()
#Set maximum ram to used to 50 Go
setRam(16)
# If there's a way to read RAM on PC thatd be goated



# if (!LAUNCH_SIMULATION) { # hm, même si on a launch la simulation il faut bien faire ça non ??
#   study_name = IMPORT_STUDY_NAME
#   study_path = file.path("input", "antares_presets", study_name,
#                      fsep = .Platform$file.sep)
#   msg = paste("[MAIN] - Reading simulations of pre-existing", study_name, "study...")
#   logMain(msg)
#   
#   simulation_name = IMPORT_SIMULATION_NAME
#   setSimulationPath(study_path, simulation_name)
#   if (simulation_name == -1) {
#     msg = "[MAIN] - Opening latest simulation..."
#     logMain(msg)
#   } else {
#     msg = paste("[MAIN] - Opening", simulation_name, "simulation...")
#     logMain(msg)
#   }
# }
# A cleaner thing to do would be to pass the study name as argument of a function
# and to do the LAUNCH_SIMULATION check in main.

# Définir le chemin vers le dossier de l'étude Antares
# chemin_etude <- file.path("antares", "examples", "studies", study_name,
#                           fsep = .Platform$file.sep)
# 
# simulation <- -1
# 
# setSimulationPath(chemin_etude, simulation)

# Définir la plage de dates
start_date <- "2015-01-01"
end_date <- "2015-12-31"

########################
# # Charger les données de production au pas horaire pour toutes les zones
# prodData <- readAntares(areas = "all",
#                       # clusters = "all", # pretty long, make an "import clusters" function.
#                       # a good thing would also be to make districts for deane world
#                       mcYears = "all",
#                       # timeStep = c("hourly", "daily", "weekly", "monthly", "annual"), J'ARRIVE PAS A AVOIR REGLAGE
#                       select = c("SOLAR", "WIND", 
#                                  "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "OIL", 
#                                  "LOAD", 
#                                  "H. STOR", 
#                                  "BALANCE", 
#                                  "MISC. DTG", "MISC. DTG 2", "MISC. DTG 3", "MISC. DTG 4"),
#                       timeStep = PLOT_TIMESTEP # ça c'est un paramètre qui serait bien dans parameters ça
#                       # Ah euh, les imports et les exports quand même !!
# )

source(".\\src\\antaresReadResults_support\\productionStacksPresets.R")
# il existe : productionStack, productionStackColorblindSafe
# encore une fois, ce serait bien un Excel pour pouvoir faire défiler
# une liste avec ce qui existe, voire avoir des commentaires qui s'affichent
# pour expliquer à l'utilisateur ce que c'est.
# un par défaut, "standard RTE eCO2Mix color palette",
# et si on prend le colorblind "colorblind-friendly palette according to ..."


# Comme graphes au total je pense qu'il faudrait faire :
# - stack de production
# - injection/soutirage des différentes formes de stockage
# - défaillances/spillage
# - émissions de CO2
# - échanges

# Un truc intéressant c'est que la défaillance ca colle bien aux scénarios genre.
# Le scénarios S1 pourrait dire "ok pour de la défaillance"
# Pour le scénario S4 ce serait inacceptable (le "ce que je veux, rapidement" etc)

# Un truc que j'me dis aussi : ce serait bien d'avoir ces données par pays non ?
# Parce que le Deane il sort ça par continent ok mais si ça se trouve
# ça allume des centrales thermiques carrément dans les mauvais pays
# (bon... en soi c'est ptet pas le but de l'étude, de modéliser de façon micro)

########################
# prodStack(
#   x = prodData,
#   stack = "productionStack",
#   areas = "all",
#   #links = "all",
#   dateRange = c(start_date, end_date),
#   #timeStep = c("hourly", "daily", "weekly", "monthly", "annual"),
#   #timestep = "weekly",
#   #main = "Production horaire par mode de production",
#   unit = "MWh"
# )

# CONTINENTS = c("Europe", "Africa", "Asia", "North America", "South America", "Oceania")
# # r_object mayb
# Maybe make an R object of the Nodes tbl with like node-continent association

source(".\\src\\data\\addNodes.R")
# nodes_tbl <- getNodesTable(c("EU-FRA", "AF-MAR", "EU-ESP", "EU-DEU"))
# print(nodes_tbl)
# print(nodes_tbl$continent %>% unique())
# ça pourrait se transformer en listContinentsInNodes jsp

initializeOutputFolder <- function(nodes) {
  output_dir = paste0("./output/results_", study_name, "-sim-", 
                      simulation_name # peut-être faire en sorte que ça soit vrmt simulationName si jamais c'est -1
                      # et peut-être aussi le raccourcir psk wow ça fait des dossiers DEBILEMENT LONGS
                      ) 
  # folder_dir <- paste0("./logs/logs_", format(Sys.time(), "%Y-%m-%d"))
  if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  }
  
  continents_dir <- file.path(output_dir, "continent_graphs")
  if (!dir.exists(continents_dir)) {
    dir.create(continents_dir)
  }
  
  countries_dir <- file.path(output_dir, "country_graphs")
  if (!dir.exists(countries_dir)) {
    dir.create(countries_dir)
  }
  
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  # print(continents)
  for (continent in continents) {
    # print(continent)
    continent_dir <- file.path(countries_dir, tolower(continent))
    # print(continent_dir)
    if (!dir.exists(continent_dir)) {
      dir.create(continent_dir)
    }
  }
  return(output_dir)
}


# Question se pose de comment on organise folder.
# peut-être des "country_graphs" avec une séparation AS/EU/etc via un tibble
# nodes/continents ?
# puis également, un continent_graphs avec juste bam les trucs par continent.

# Possiblement que pour contrôler production je ferai des paramètres
# "plot production stack", "plot co2" etc etc
# et peut-être ça implique soit un parameters.R en plus, soit un long parameters.R

WIDTH = 1920
HEIGHT = 1080
TIMESTEPS = c("hourly", "daily", "weekly", "monthly", "annual")
# webshot::install_phantomjs()
# c'était important de le faire, garedr en tête si besoin de debug
# ça marche enfin !!!!

saveCountryProductionStacks <- function(nodes, 
                                        output_folder,
                                        stack_palette,
                                        timestep # could actually just make folders for all of them by default ?
                                        # or do something like. days at hourly. weeks at daily. idk.
                                        # all timescales are interesting, but hourly is hard to read at a year start/end date
                                        # and some weeks are different in the year.........
                                        
                                        # sinon genre monthly sur l'année, weekly sur le mois, daily sur la semaine, hourly sur le jour
                                        # en créeant un dossier pour chaque jour ptdr ou comment détruire son ordinateur
                                        ) {
  # if (is.null(nodes)) {
  #   areas = "all"
  #   }
  # else {
  areas = getAreas(nodes) # les areas c lowercase, eu-aut eu-fra etc
  variables_of_interest <- c("SOLAR", "WIND", # Ici l'ordre compte pas jcrois,
                             # c'est dans setStackAlias machin qu'on le détermine
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
                             "Other3_injection", "Other3_withdrawal", "Other3_level" # Rappel : CAE
                             #Enft jsuis un peu débile les injections de batteries en pratique on les fait avant de lancer le thermique...
                             # mais en même temps ça permet de voir en pointe à quel point ça a aidé
                             # vs que ça se fasse écraser tout en bas
                             # et également mettre d'un côté et de l'autre ce qui sort de la courbe rose de production totale
                             # dans laquelle on peut pas trop mettre les batteries pour risque de double comptage
                             )
  # } # c'est si schlag bordel
  prod_data <- readAntares(areas = areas,
                           mcYears = "all",
                           # En vrai, il faudrait trouver un moyen d'assurer cohérence que genre,
                           # les nodes sont bien dans l'étude qu'on extraits, via un filter par exemple
                           # sinon on peut causer des bugs trop facilement
                          select = variables_of_interest,
                          # Attention si on s'amuse à séparer les palettes dans un autre fichier,
                          # il faut penser à également tout bien importer...
                          timeStep = timestep
  )
  # en fait plus simple d'importer séparément jpense
  #print(prod_data)
  ## Test : obtain only nuclear in countries
  # areas <- getAreas(prod_data)
  # print(areas)
  
  # variables = c("NUCLEAR", "MIX. FUEL")
  # for (area in areas) {
  #   for (variable in variables) {
  #     var_in_area_df <- readAntares(areas = area,
  #                               select = variable
  #     )[[variable]]
  #     df_is_null <- all(var_in_area_df == 0)
  #     print(paste(variable, "in", area, ":", !df_is_null))
  #   }
  # }
  # 
  # 
  # print(prod_data)
  ## Fin test
  # le importing areas est long à chaque fois, envisager d'en faire un Robject
  
  
  country_graphs_dir = file.path(output_folder, "country_graphs")
                             #"productionStack")
  nodes_tbl <- getNodesTable(nodes)
  #print(nodes_tbl)
  continents <- nodes_tbl$continent %>% unique()
  for (cnt in continents) {
    
    # ici serait un bon endroit pour faire un prodStack par continent
    # mais j'ai pas l'info hélas
    # ok, en fait pour prodstack ça aggregate automatiquement
    # pour des tsplot il y a un argument "aggregate" qui peut d'ailleurs faire des means, des sums...
    
    # oh, une fois qu'on fait ça, et si jamais on fait juste un prodStack d'une vContinents
    # avec 6 points agrégés, ça peut faire un test d'à quel point la descente d'échelle est ok !
    
    nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt) #%>% tolower() # les areas c lowercase
    # print(nodes_in_continent_tbl)
    nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
    # print(nodes_in_continent)
    prod_stack_dir <- file.path(country_graphs_dir, tolower(cnt), "productionStack")
    if (!dir.exists(prod_stack_dir)) {
      dir.create(prod_stack_dir)
    }
    unit = "GWh"
    for (country in nodes_in_continent) {
      # print(paste("Null variables in", country, ":"))
      # print(null_variables)
      # prod_data <- readAntares(areas = country,
      #                          mcYears = "all",
      #                          select = non_null_variables,
      #                          timeStep = timestep
      # )
      # fuck it, why not all timesteps ?
      # mayb later i want to do graphes de défaillance là
      # print(country)
      # print(prod_data)
      
      # En fait si on crée des trucs custom, l'argument stack_palette est ici rendu inutile.
      # Attention donc avec cette ligne on retire (provisoirement) la customisation.
      # Ou alors...
      if (stack_palette == "dynamic") {
        null_variables = list()
        for (variable in variables_of_interest) {
          var_in_area_df <- readAntares(areas = country,
                                        mcYears = "all",
                                        timeStep = timestep,
                                        select = variable
          )[[variable]]
          df_is_null <- all(var_in_area_df == 0)
          if (df_is_null) {
            null_variables <- c(null_variables, variable)
          }
        }
        createFilteredStack(stack_palette, null_variables)
      }
      
      stack_plot <- prodStack(
        x = prod_data,
        stack = stack_palette, # ah mais là ça bloque parce que palette prend éléments autres..
        # en fait il faudrait tout import, mais trouver "hidden" avec au contraire les null
        # # hidden	
        # logical Names of input to hide. Defaut to NULL
        # ET EN FAIT NON
        # Error in .validHidden(listParamsCheck$hidden, listParamsCheck$valHidden) : 
        # Invalid arguments for 'hidden' : 'SOLAR', 'WIND', 'GAS', 'COAL', 'NUCLEAR', 
        # 'MIX. FUEL', 'OIL', 'MISC. DTG', 'MISC. DTG 2', 'MISC. DTG 3', 'UNSP. ENRG', 
        # 'PSP_closed_injection', 'PSP_closed_withdrawal', 'PSP_closed_level', 
        # 'Battery_injection', 'Battery_withdrawal', 'Battery_level', 
        # 'Other1_injection', 'Other1_withdrawal', 'Other1_level', 
        # 'Other2_injection', 'Other2_withdrawal', 'Other2_level', 
        # 'Other3_injection', 'Other3_withdrawal', 'Other3_level'. 
        # Possible values : 'H5request', 'timeSteph5', 'tables', 'mcYearH5', 'mcYear', 
        # 'main', 'dateRange', 'stack', 'unit', 'areas', 'legend', 'stepPlot', 'drawPoints'.
        areas = country,
        dateRange = c(start_date, end_date),
        timeStep = timestep,
        main = paste(timestep, "production stack for", country, "in 2015", unit),
        unit = unit,
        # hidden = null_variables,
        interactive = FALSE
                     # library(tools)
                     # 
                     # # Example usage:
                     # toTitleCase("hello world")
        
      )
      msg = paste("[OUTPUT] - Saving", timestep, "production stack for", country, "node...")
      logFull(msg)
      png_path = file.path(prod_stack_dir, paste0(country, "_", timestep, ".png"))
      #print(png_path)
      savePlotAsPng(stack_plot, file = png_path,
                    width = 3*WIDTH, # faire 2x WIDTH pour horaire ?
                    height = 2*HEIGHT)
      msg = paste("[OUTPUT] - The", timestep, "production stack for", country, "has been saved!")
      logFull(msg)
    }
  }
}

saveUnsuppliedAndSpillage <- function(nodes,
                                      output_folder,
                                      timestep
                                      ) {
  areas = getAreas(nodes) # les areas c lowercase, eu-aut eu-fra etc
  energy_data <- readAntares(areas = areas,
                           mcYears = "all",
                           # En vrai, il faudrait trouver un moyen d'assurer cohérence que genre,
                           # les nodes sont bien dans l'étude qu'on extraits, via un filter par exemple
                           # sinon on peut causer des bugs trop facilement
                           select = c("UNSP. ENRG", "SPIL. ENRG"),
                           timeStep = timestep
  )
  # oh pour les tsplot :
  #   type = c("ts", "barplot", "monotone", "density", "cdf", "heatmap"),
  
  
  country_graphs_dir = file.path(output_folder, "country_graphs")
  nodes_tbl <- getNodesTable(nodes)
  continents <- nodes_tbl$continent %>% unique()
  # ca peut clairement etre mieux mdrr
  for (cnt in continents) {
    nodes_in_continent_tbl <- nodes_tbl %>% filter(continent == cnt)
    nodes_in_continent <- tolower(nodes_in_continent_tbl$node)
    unsp_spil_dir <- file.path(country_graphs_dir, tolower(cnt), "unsuppliedAndSpillage")
    # ça en fait juste faut faire dans initialize outputfolder avec nodes là...
    if (!dir.exists(unsp_spil_dir)) {
      dir.create(unsp_spil_dir)
    }
    unit = "MWh"
    for (country in nodes_in_continent) {
      ts_plot <- plot(
        x = energy_data,
        type = "ts",
        # variable =  c(`UNSP. ENRG`, `SPIL. ENRG`), # mais je le veux en négatif et je le veux en rouge
        # variable =  c(-`UNSP. ENRG`, `SPIL. ENRG`),
        # Error in X[[table]]$plotFun(mcYear, 1, variable, variable2Axe, elements,  :
        #                               objet 'UNSP. ENRG' introuvable
        #                             Called from: X[[table]]$plotFun(mcYear, 1, variable, variable2Axe, elements,
        #                                                             type, typeConfInt, confInt, dateRange, minValue, maxValue,
        #                                                             aggregate, legend, highlight, stepPlot, drawPoints, main)
        ## AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa
        variable =  -`UNSP. ENRG`,
        colors = "red",
        elements = country,
        dateRange = c(start_date, end_date),
        #timeStep = timestep,
        main = paste(timestep, "unsupplied energy for", country, "in 2015 (MWh)"),
        interactive = FALSE
        )
      # fuck it, why not all timesteps ?
      # mayb later i want to do graphes de défaillance là
      # print(country)
      # print(prod_data)
      msg = paste("[OUTPUT] - Saving", timestep, "unsupplied/spilled energy for", country, "node...")
      logFull(msg)
      png_path = file.path(unsp_spil_dir, paste0(country, "_", timestep, ".png"))
      #print(png_path)
      savePlotAsPng(ts_plot, file = png_path,
                    width = WIDTH,
                    height = HEIGHT)
      msg = paste("[OUTPUT] - The", timestep, "unsupplied/spilled energy for", country, "has been saved!")
      logFull(msg)
    }
  }
}

# En fait, bientôt un readResults qui fait juste des appels à ces fonctions comme createStudy
# et donc, au même titre que j'ai un dossier "data" qui va ptet changer de nom, ranger les auxilliaires
# createStudyFunctions ? readResultsFunctions ?

nodes = asia_nodes_lst 
# si je commente en vrai, ça importe bien non ?
output_dir <- initializeOutputFolder(nodes) # ah ptn y a ça aussi aaaaaa
saveCountryProductionStacks(nodes,
                            output_dir,
                            #"productionStackColorblindSafe",
                            # Un peu mal foutu vu comment le titre du graphe change également si on change le stack
                            # En fait absolument tout peut changer mdr :
                            # le titre, l'unité, le timestep....
                            # il faudrait une fonction pour un stack en théorie
                            # "dynamic",
                            "productionStackWithBatteryContributions",
                            "daily") # la conclusion est formelle : faire des dossiers 
  # sinon avoir daily et hourly au mm endroit c insupportable
# NB SUR LES COULEURS DES STACKS : FAIRE UN MODE EASILY ACCESSIBLE POUR COLORBLIND

# saveUnsuppliedAndSpillage(nodes, output_dir, "hourly")
# Pour l'instant hélas ça bugge


  
  # long term, this should probably end up in main/util
# and there should be like a h5 copy of study and simulation
# but so far, we want mostly screenshots soooooo

### let's make a function that saves a bunch of PNGs !
# savePlotAsPng(plot, file = "Rplot.png", width = 600, height = 480, ...)
# 
# plot	
# A plot generated with one of the functions of this package.
# 
# ## Not run: 
# mydata <- readAntares()
# myplot <- plot(mydata, variable = "MRG. PRICE", type = "density")
# savePlotAsPng(myplot, file = "myplot.png")
# 

# # Lire les résultats de la simulation
# sim_results <- readAntares(
#   areas = "all",
#   links = "all",
#   clusters = "all",
#   mcYears = "all"
# )
# 
# # Afficher les résultats
# print(sim_results)

# Todo : AntaresViz

################################################################################

# # Chargement des packages nécessaires
# library(antaresRead)
# library(antaresProcessing)
# library(antaresViz)
# 
# # Définir le chemin vers le dossier de l'étude Antares
# # Dans l'idéal, faire ça dans la foulée dans que base_path et study_name sont encore en mémoire.
# # Ou alors, faire un truc qui les sauvegarde pour pouvoir les revisionner plus tard.
# chemin_etude <- file.path("antares", "examples", "studies", "Etude_sur_R_Monde__2024_07_26_19_22_38")
# # chemin_etude <- file.path("antares", "examples", "internal_studies", "9747b056-32ec-4a3f-a23e-e5c965594eec")
# simulation <- -1
# 
# setSimulationPath(chemin_etude, simulation)
# print(simOptions())
# # Antares project 'Etude_sur_R_Monde__2024_07_26_19_22_38' (C:/Users/boissieremat/Documents/GitHub/antares-brinkerink-2015/antares/examples/studies/Etude_sur_R_Monde__2024_07_26_19_22_38)
# # Simulation 'NA'
# # Mode Economy
# # 
# # Content:
# #   - synthesis: TRUE
# # - year by year: FALSE
# # - MC Scenarios: FALSE
# # - Number of areas: 42
# # - Number of districts: 0
# # - Number of links: 76
# # - Number of Monte-Carlo years: 0
# # si c'est vrai c'est très grave (year by year pas activé, alors qu'aurait du etre lu
# # au moment d'initialiser la simulation !!)
# 
# #  Je me rappelle d'un autre truc aussi. Il a fallu cocher la case manuellemenet
# # pour générer des TS thermiques et dire à antares "j'en ai pas".
# # et... est-ce que ça s'automatise sur R, le déclenchement de ça ? parce que je galère à trouver.
# # ah, en fouillant le generaldata.ini, on dirait que c'est generate = thermal.
# # reste à le mettre dans updateSettings.
# 
# # Définir la plage de dates
# start_date <- "2015-01-01"
# end_date <- "2015-12-31"
# 
# # Charger les données de production au pas horaire pour toutes les zones
# mydata <- readAntares(areas = "all",
#                       # links = "all",
#                       # clusters = "all",
#                       mcYears = "all",
#                       # timeStep = c("hourly", "daily", "weekly", "monthly", "annual"), J'ARRIVE PAS A AVOIR REGLAGE
#                       select = c("SOLAR", "WIND", "GAS", "COAL", "NUCLEAR", "MIX. FUEL", "LOAD"),
#                       timeStep = "weekly"
# )
# #) # timeStep = "hourly",
# 
# # Prochaine étape le graphe avec une carte imo
# 
# #https://rdrr.io/github/rte-antares-rpackage/antaresViz/man/prodStack.html
# 
# # Créer un alias pour la stack de production
# setProdStackAlias(
#   name = "customStack",
#   variables = alist(
#     NUCLEAR = NUCLEAR,
#     WIND = WIND,
#     SOLAR = SOLAR,
#     GAS = GAS,
#     COAL = COAL,
#     `MIX. FUEL` = `MIX. FUEL`
#   ),
#   colors = c("yellow", "turquoise", "orange", "red", "brown", "darkgreen"),
#   lines = alist(
#     LOAD = LOAD,
#     TOTAL_PRODUCTION =  NUCLEAR + WIND + SOLAR + GAS + COAL + `MIX. FUEL` # Curieux : j'ai un screen avec le bleu en bas
#   ),
#   lineColors = c("black", "royalblue")
# )
# # Ce serait bien d'avoir le load par-dessus pour visualiser défaillance,
# # ainsi qu'imports/exports. Mais pas sûr de comment faire.
# 
# # Visualiser les données avec un empilement directement avec antaresViz
# prodStack(
#   x = mydata,
#   stack = "customStack",
#   areas = "all", 
#   dateRange = c(start_date, end_date),
#   #timeStep = c("hourly", "daily", "weekly", "monthly", "annual"),
#   #timestep = "weekly",
#   #main = "Production horaire par mode de production",
#   unit = "MWh"
# )
