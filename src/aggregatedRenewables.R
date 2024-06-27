library(dplyr)

wind_csv = ".\\input\\dataverse_files\\Renewables.ninja.wind.output.Full.adjusted.csv"

# Lire les données en spécifiant que toutes les colonnes sont numériques
wind_data_matrix <- read.table(wind_csv, 
                               header = TRUE,
                               sep = ",",
                               dec = ".",
                               #row.names = 1,
                               stringsAsFactors = FALSE)
print(wind_data_matrix)
# stringsAsFactors
# logical: should character vectors be converted to factors? Note that this is overridden by as.is and colClasses, both of which allow finer control.
# pacompri, a comprendre


# Create an empty data frame for the aggregated data
aggregated_df <- data.frame(matrix(ncol = 0, nrow = nrow(wind_data_matrix)))

# Loop through each column in the original data frame
for (col_name in colnames(wind_data_matrix)) {
  # Extract the country code (first three letters of the column name)
  country_code <- substr(col_name, 1, 5)
  
  # If the country code does not exist in the aggregated_df, create a new column
  if (!country_code %in% colnames(aggregated_df)) {
    aggregated_df[[country_code]] <- wind_data_matrix[[col_name]]
  } else {
    # If the country code exists, sum the values of the current column to the existing column
    aggregated_df[[country_code]] <- aggregated_df[[country_code]] + wind_data_matrix[[col_name]]
  }
}

# Print the aggregated data frame
print(aggregated_df)
print(colnames(aggregated_df))
print(aggregated_df$FRA)


# Quel enfer, je viens de me rendre compte que dans les TS Renewables.ninja ya
# pas la région... Enfni y a ces fameux capacity scalers mais tout de même...
# Faudra-t-il faire des requêtes OSM à partir des latitudes/longitudes de noeuds WRI
# pour trouver la région dans laquelle ça se situe ?
# ou bien faire un noeud pour chaque centrale (quel enfer...)
# et que sont les capacity scalers au juste ??

