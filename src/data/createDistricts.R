library(antaresRead)
library(antaresEditObject)

source(".\\src\\data\\addNodes.R")

DEANE_ALL_NODES <- getAllNodes()

nodes_tbl <- getNodesTable(DEANE_ALL_NODES)

print(nodes_tbl)

# tout ça pourrait aller dans utils mais pour l'instant flemme
isRegionalNode <- function(node) {
  regional_check <- (nchar(node) == 9)
  return(regional_check)
}

isRegionalNode("AS-CHN-FU")
isRegionalNode("EU-FRA")

getCountryFromRegionalNode <- function(regional_node) {
  country_node <- substring(regional_node, 1, 6)
  return(country_node)
}

test_tbl <- nodes_tbl %>%
  mutate(name_length = nchar(node))

print(test_tbl, n = 200)

regional_nodes_tbl <- nodes_tbl %>%
  filter(isRegionalNode(node)) %>%
  mutate(district = getCountryFromRegionalNode(node))

print(regional_nodes_tbl, n = 100)