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

#print(deane_ntc_df)
#print(colnames(deane_ntc_df))

# Read the file into a vector of lines
lines <- readLines(deane_nodes_csv, encoding = "UTF-8")

# Remove zero-width space characters
lines <- gsub("\u200B", "", lines)

# Write the cleaned content back to a temporary file
temp_file <- tempfile(fileext = ".csv")
writeLines(lines, temp_file, useBytes = TRUE)

# Read the cleaned CSV file with read.csv and correct separator
deane_nodes_df <- read.csv(
  temp_file,
  sep = ";",
  stringsAsFactors = FALSE,
  encoding = "UTF-8"
)

# Rename the problematic column
colnames(deane_nodes_df)[1] <- "Node"

# Print the dataframe to verify
print(deane_nodes_df)

# Verify the column names
print(colnames(deane_nodes_df))


getISOfromDeane <- function(input_string) {
  substr(input_string, 4, 6)
}