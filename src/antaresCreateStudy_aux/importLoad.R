# Définir le chemin menant aux données 2015
data_path <- ".\\input\\dataverse_files"
load_path <- file.path(data_path, "All Demand UTC 2015.txt")

# source("parameters.R")

# Ah tiens, j'ai pas fait un preprocessLoadData ? J'aurais pu mais boarf.
load_table <- read.table(
  load_path,
  header = TRUE,
  sep = ",",
  encoding = "UTF-8",
  row.names = 1, # what do # fin genre faudrait commenter qu'est-ce que ça fait
  # roxygeeeeen2 aqhh
  stringsAsFactors = FALSE, # what do
  check.names = FALSE
  )

load_tbl <- as_tibble(load_table) %>%
  rename_with(tolower)
# print(load_tbl)

# quid d'avoir un truc plus matriciel qui comme le Wind/Solar maintenant,
# relève des warnings à faire sur "attention node inexistant"
# (en fait non impossible car nature car getAllNodes part des nodes du PLEXOS
# or ces trucs là ne sont mm pas dans le PLEXOS, mais ont de la conso.)

addLoadToNodes <- function(nodes #= DEANE_NODES_ALL
                           ) {
  for (node in nodes) {
    # Ce serait bien de faire depuis Ninja, et de print un warning "not found"
    load_ts <- load_tbl[[node]]
    msg = paste("[LOAD] - Adding", node, "load data...")
    logFull(msg)
    tryCatch({
      writeInputTS(
        data = load_ts,
        type = "load",
        area = node
      )
    }, error = function(e) {
      msg = paste("[WARN] - Could not add load data to", node, "node, skipping...")
      logError(msg)
    }
    )
  }
}