library(nominatimlite)
library(sf)

# Define the function to get latitude and longitude from OSM
getLatLonFromOSM <- function(query) {
  result <- geo_lite_sf(query, limit = 1)
  if (nrow(result) > 0) {
    geometry <- st_as_sf(result, wkt = "geometry")
    
    if (inherits(geometry$geometry, "sfc_POINT")) {
      coords <- st_coordinates(geometry)
      longitude <- as.numeric(coords[1, "X"])
      latitude <- as.numeric(coords[1, "Y"])
      return(list(latitude = latitude, longitude = longitude))
    } else if (inherits(geometry$geometry, "sfc_GEOMETRYCOLLECTION")) {
      points <- st_collection_extract(geometry$geometry, "POINT")
      if (length(points) > 0) {
        coords <- st_coordinates(points[1])
        longitude <- as.numeric(coords[1, "X"])
        latitude <- as.numeric(coords[1, "Y"])
        return(list(latitude = latitude, longitude = longitude))
      } else {
        cat("No POINT geometry found in GEOMETRYCOLLECTION for query:", query, "\n")
        return(NULL)
      }
    } else {
      cat("No POINT geometry found for query:", query, "\n")
      return(NULL)
    }
  } else {
    return(NULL)
  }
}

# Define the function to update coordinates
writeCoordinates <- function(countryToUpdate, csv_path) {
  geo_df <- read.csv(
    file = csv_path,
    header = TRUE,
    sep = ";",
    encoding = "UTF-8"
  )
  
  # Check if the dataframe was loaded correctly
  if (is.null(geo_df) || ncol(geo_df) == 0) {
    stop("Failed to load the CSV file or the file is empty.")
  }
  
  # Check if the "Country" column exists
  if (!"Country" %in% colnames(geo_df)) {
    stop("The 'Country' column does not exist in the CSV file.")
  }
  
  # Filter rows where Country is equal to countryToUpdate
  country_rows <- geo_df[geo_df$Country == countryToUpdate, ]
  
  # Diagnostic print statements
  print(paste("Total rows in geo_df:", nrow(geo_df)))
  print(paste("Rows with Country =", countryToUpdate, ":", nrow(country_rows)))
  
  if (nrow(country_rows) > 0) {
    for (i in 1:nrow(country_rows)) {
      geographical_region <- country_rows[i, "Geographical.region"]
      coords <- getLatLonFromOSM(geographical_region)
      if (!is.null(coords)) {
        geo_df[geo_df$Country == countryToUpdate & geo_df$Geographical.region == geographical_region, "lat"] <- coords$latitude
        geo_df[geo_df$Country == countryToUpdate & geo_df$Geographical.region == geographical_region, "lon"] <- coords$longitude
        geo_df[geo_df$Country == countryToUpdate & geo_df$Geographical.region == geographical_region, "coordinates_source"] <- "OSM (Nominatim)"
      }
    }
  } else {
    cat("No rows found for country:", countryToUpdate, "\n")
  }
  
  # Save the updated dataframe back to a CSV file
  write.csv(geo_df, file = csv_path, row.names = FALSE, sep = ";", quote = TRUE)
}

# Example usage
csv_path = ".\\input\\geo_list_of_nodes.txt"
countryToUpdate = "China"
writeCoordinates(countryToUpdate, csv_path)
