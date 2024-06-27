## Script principal regroupant le coeur du processus ##
## Les objets sont typiquement déjà définis dans les fichiers auxilliaires

# Charger les packages
library(antaresRead)
library(antaresEditObject)

# Importer des fonctions et variables auxilliaires créées dans d'autres scripts
# Clairement set le path une bonne fois pour toute parce que ça bug
# et qqfois passe de Documents, à Documents/RStudio/AntaresDeane2015...
# Edit : en fait il faut préciser (dans le README ptet) d'ouvrir le .rproj
# et c'est bon
#source(".\\src\\featuresTest.R")
source(".\\src\\antaresFunctions.R")
#source("parameters.R")


## Création d'une nouvelle étude
study_name <- generateName(study_basename)
# study_path <- file.path(base_path, study_name)

createStudy(
  path = base_path,
  study_name = study_name,
  antares_version = antares_version
  )

updateAllSettings()

deane_nodes_path = ".\\input\\geo_list_of_nodes.txt"
deane_nodes_df <- read.csv(
  file = deane_nodes_path,
  header = TRUE,
  sep = ";",
  encoding = "UTF-8",
  )
# De manière générale, les .txt en utf-8 c'est bien pour pas avoir d'erreur.

#print(deane_nodes_df)
#print(colnames(deane_nodes_df))

zones = deane_nodes_df$Node
#print(zones)
#print(deane_nodes_df$Node[1])
#print(deane_nodes_df[1])
#print(deane_nodes_df$lat)
#print(deane_nodes_df$lon)

scaling_factor = 20


for (row in 1:nrow(deane_nodes_df)) {
  # Il faudrait mettre ce truc dans le try, sinon ça met "adding" meme avant un fail, non ?
  # eh en vrai si isok
  zone = zones[row]
  #print(zone)
  x = deane_nodes_df$lon[row] * scaling_factor
  #print(x)
  y = deane_nodes_df$lat[row] * scaling_factor
  #print(y)
  
  cat(paste("Adding", zone, "node...\n"))
  #country_code = getISOfromDeane(zone)
  #print(country_code)
  # Use tryCatch to handle exceptions
  tryCatch({
    # Function that may throw an error
    # get_country_coordinates(country_code)
    #coords = 
    #x <- getAntaresCoordsFromCountry(country_code)$x
    #y <- getAntaresCoordsFromCountry(country_code)$y
    createArea(
      name = zone,
      color = getColor(zone),
      localization = c(x, y)
    )
  }, error = function(e) {
    #cat("Error in get_country_coordinates(", country_code, ") :\n")
    #cat("  ", conditionMessage(e), "\n")
    cat("Error : skipping creation of node ", zone, " and continuing...\n")
  })
  
  # Continue parsing data or performing other operations
  # after successful execution of get_country_coordinates()
  # For example:
  # parse_data_for_country(country_code)
  
}

cat("Done adding nodes !\n")

####################################################

# Définir le chemin menant aux données 2015
data_path <- ".\\input\\dataverse_files"

load_csv = "All Demand UTC 2015.csv"
load_path <- file.path(data_path, load_csv)

# Read data with check.names = FALSE
load_data_matrix <- read.table(
  load_path,
  header = TRUE,
  sep = ",",
  row.names = 1,
  stringsAsFactors = FALSE,
  check.names = FALSE)

# Iterate over the column names
for (zone in colnames(load_data_matrix)) {
  # Extract the time series for the current column
  load_ts <- load_data_matrix[[zone]]
  cat(paste("Adding", zone, "load data...\n"))
  tryCatch({
    writeInputTS(
      data = load_ts,
      type = "load",
      area = zone
    )
  }, error = function(e) {
    cat("Error : node ", zone, "not found, skipping...\n")
  }
  )
}

cat("Done adding load data!\n")

#Adding AS-SGP load data...
#Erreur : 'NA-CAN' is not a valid area name, possible names are: af-ago, af-bdi, af-ben, af-bfa, af-bwa, af-caf, af-civ, af-cmr, af-cod, af-cog, af-cpv, af-dji, af-dza, af-egy, af-eri, af-esh, af-eth, af-gab, af-gha, af-gin, af-gmb, af-gnb, af-gnq, af-ken, af-lbr, af-lby, af-lso, af-mar, af-mdg, af-mli, af-moz, af-mrt, af-mus, af-mwi, af-nam, af-ner, af-nga, af-rwa, af-sdn, af-sen, af-sle, af-swz, af-tgo, af-tun, af-tza, af-uga, af-zaf, af-zmb, af-zwe, as-afg, as-are, as-bgd, as-bhr, as-brn, as-btn, as-chn-an, as-chn-be, as-chn-ch, as-chn-em, as-chn-fu, as-chn-ga, as-chn-gd, as-chn-gu, as-chn-gx, as-chn-ha, as-chn-hb, as-chn-he, as-chn-hj, as-chn-hk, as-chn-hn, as-chn-hu, as-chn-ji, as-chn-js, as-chn-jx, as-chn-li, as-chn-ma, as-chn-ni, as-chn-qi, as-chn-sc, as-chn-sd, as-chn-sh, as-chn-si, as-chn-sx, as-chn-ti, as-chn-tj, as-chn-wm, as-chn-xi, as-chn-yu, as-chn-zh, as-idn, as-ind-ea, as-ind-ne, as-ind-no, as-ind-so, as-ind-we, as-irn, as-irq, as-isr, as-jor, as-jpn-ce, as-jpn-ho, as-j
#> 
#  > cat("Done adding load data!\n")

# Exception moment (on s'en fout de NA-CAN c'est un agrégat)

# NB : en faisant ce petit travail, on remarque qu'il y a des agrégats qui buggent oui,
# mais pas que.
# Dans les nodes qu'il faudra possiblement rajouter à la main :
# AF-SOM, AF-TCD, AS-TLS, EU-MLT, NA-BLZ, NA-HTI, SA-SUR
# (heureusement que j'ai pas fait un for zone in zones !!)

####################################################


deane_ntc_csv = ".\\input\\cross_border_transmission_capacities.txt"

ntc_df <- read.csv(
  deane_ntc_csv,
  header = TRUE,
  sep = ";",
  encoding = "UTF-8"
)

#print(ntc_df)
#print(colnames(ntc_df))
#print(ntc_df$From[10])

for (row in 1:nrow(ntc_df)) {
  from_node = ntc_df$From[row]
  to_node = ntc_df$To[row]
  ntc_direct = ntc_df$Max.Flow..MW.[row]
  ntc_indirect = -ntc_df$Min.Flow..MW.[row]
  if (ntc_direct == 0 & ntc_indirect == 0){
    # Peut etre jouer avec l'évaluation paresseuse ?
    cat(paste("Skipping ", from_node, " to ", to_node, " link (zero capacity)\n"))
    # nb : c'est bad long ces prints
  } else {
    ts_link <- data.frame(rep(ntc_direct, 8760), rep(ntc_indirect, 8760))
    tryCatch({
      # Function that may throw an error
      createLink(
        from = from_node,
        to = to_node,
        #tsLink = ts_link
      )
      # Point d'attention qu'il faudra vérifier : est-ce que si mauvais ordre
      # (eg from EU-AUT to AS-CHN, pas alphabétique), les capacités directe/indirecte
      # sont bien dans le bon ordre ? Surtout si différentes
      cat(paste("Linking ", from_node, " to ", to_node, "...\n"))
    }, 
    error = function(e) {
      # What happens if an error is thrown
      cat(paste("Skipping ", from_node, " to ", to_node, " link (one of the nodes may not exist)\n"))
    }
    )
    
  # TODO : faire un paramètre "include Deane null links" TRUE ou FALSE
  }
}

cat("Done adding links !")

# A ajouter : fonction qui chronometrent et l'affichent