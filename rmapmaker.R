# Load necessary libraries
library(zip)
library(sf)
library(rgdal)

# Define the raw_data and processed_data directories
raw_data_dir <- "raw_data"
processed_data_dir <- "processed_data"

# Create processed_data directory if it doesn't exist
if (!dir.exists(processed_data_dir)) {
  dir.create(processed_data_dir)
}

# List all zip files in the raw_data directory
zip_files <- list.files(path = raw_data_dir, pattern = "\\.zip$", full.names = TRUE)

# Function to extract files and move shapefiles and kml/kmz files
extract_and_move_files <- function(zip_file, target_dir) {
  unzip(zip_file, exdir = target_dir)
  extracted_files <- list.files(target_dir, recursive = TRUE, full.names = TRUE)
  
  # Move shapefiles and kml/kmz files to the target directory
  shapefiles <- grep("\\.shp$", extracted_files, value = TRUE)
  kml_files <- grep("\\.kml$", extracted_files, value = TRUE)
  kmz_files <- grep("\\.kmz$", extracted_files, value = TRUE)
  
  files_to_move <- c(shapefiles, kml_files, kmz_files)
  
  for (file in files_to_move) {
    file.rename(file, file.path(target_dir, basename(file)))
  }
  
  # Remove extracted directories
  extracted_dirs <- list.dirs(target_dir, recursive = FALSE)
  for (dir in extracted_dirs) {
    unlink(dir, recursive = TRUE)
  }
}

# Process each zip file
for (zip_file in zip_files) {
  extract_and_move_files(zip_file, raw_data_dir)
  # Remove the zip file after extraction
  file.remove(zip_file)
}

# Remove any remaining directories in raw_data
remaining_dirs <- list.dirs(raw_data_dir, recursive = FALSE)
for (dir in remaining_dirs) {
  unlink(dir, recursive = TRUE)
}

# Function to prompt user for dataset name
prompt_for_name <- function() {
  cat("Choose a name for the dataset:\n")
  cat("1. Top holes\n2. Bottom holes\n3. Laterals\n4. Twn\n5. Rng\n6. Sections\n7. Parcels\n8. Mineral Tracts\n9. Clipper\n10. Something else\n")
  choice <- as.integer(readLines(n = 1))
  names <- c("Top holes", "Bottom holes", "Laterals", "Twn", "Rng", "Sections", "Parcels", "Mineral Tracts", "Clipper", "Something else")
  if (choice == 10) {
    cat("Enter a custom name:\n")
    custom_name <- readLines(n = 1)
    return(custom_name)
  } else {
    return(names[choice])
  }
}

# List all shapefiles and kml/kmz files in the raw_data directory
data_files <- list.files(path = raw_data_dir, pattern = "\\.(shp|kml|kmz)$", full.names = TRUE)

# Process each data file
for (data_file in data_files) {
  dataset_name <- prompt_for_name()
  
  # Read the data file
  if (grepl("\\.shp$", data_file)) {
    data <- st_read(data_file)
  } else if (grepl("\\.kml$", data_file)) {
    data <- st_read(data_file)
  } else if (grepl("\\.kmz$", data_file)) {
    unzip(data_file, exdir = raw_data_dir)
    kml_file <- list.files(path = raw_data_dir, pattern = "\\.kml$", full.names = TRUE)
    data <- st_read(kml_file)
    file.remove(kml_file)
  }
  
  # Project to the most appropriate STATE PLANE US FEET coordinate system
  # Assuming the location of the clipper is known and stored in a variable `clipper_location`
  # Replace `clipper_location` with the actual coordinates or logic to determine the appropriate CRS
  clipper_location <- c(-97.7431, 30.2672) # Example coordinates for Austin, TX
  state_plane_crs <- CRS("+init=epsg:2277") # Example EPSG code for Texas Central (US Feet)
  data <- st_transform(data, crs = state_plane_crs)
  
  # Export the projected dataset to the processed_data directory
  output_file <- file.path(processed_data_dir, paste0(dataset_name, ".shp"))
  st_write(data, output_file)
}

cat("All datasets have been processed and saved in the processed_data directory.\n")
