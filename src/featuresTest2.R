deane_nodes_csv = ".\\input\\list_of_nodes_utf8_2.txt"

deane_txt_df <- read.csv(
  deane_nodes_csv,
  header = TRUE,
  sep = ";"
)

#print(deane_txt_df)

deane_ntc_csv = ".\\input\\cross_border_transmission_capacities.txt"

deane_ntc_df <- read.csv(
  deane_ntc_csv,
  header = TRUE,
  sep = ";",
  encoding = "UTF-8"
)



