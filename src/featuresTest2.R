deane_nodes_csv = ".\\input\\list_of_nodes_utf8.csv"

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