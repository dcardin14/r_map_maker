# Load necessary libraries
library(sf)
library(dplyr)
library(DBI)
library(odbc)
library(ggplot2)

# Load the shapefile into a dataframe
shapefile_path <- "counties"
counties_df <- st_read(shapefile_path)

# Connect to the MSSQL database
con <- dbConnect(odbc::odbc(),
                 Driver = "SQL Server",
                 Server = "dbrepprod.awscloud.twdb\\rep17",
                 Database = "LGTS",
                 Trusted_Connection = "True")

# Run the SQL query and put the results in a dataframe
sql_query <- readLines("Payments_By_County.sql", warn = FALSE)
sql_query <- paste(sql_query, collapse = " ")
tryCatch({
  con <- dbConnect(odbc::odbc(),
                   Driver = "SQL Server",
                   Server = "dbrepprod.awscloud.twdb\\rep17",
                   Database = "LGTS",
                   Trusted_Connection = "True")
  dbGetQuery(con, "SELECT 1 AS test")
  message("Connection successful")
}, error = function(e) {
  message("Error: ", e)
})
payments_df <- dbGetQuery(con, paste(sql_query, collapse = " "))

# Ensure the CoCo_County_Code field is character to handle leading zeros
#payments_df$CoCo_County_Code <- as.character(payments_df$CoCo_County_Code)

# Join the two dataframes on the specified fields
payments_per_county <- counties_df %>%
  mutate(CNTY_NBR = as.character(CNTY_NBR)) %>%
  inner_join(payments_df, by = c(CMPTRL_NBR = "CountyCode"))

# Plot the data with symbology driven by the 'AMT_PAID' field
ggplot(data = payments_per_county) +
  geom_sf(aes(fill = AMT_PAID), color = NA) +
  scale_fill_gradient(low = "lightgrey", high = "darkred", na.value = "transparent") +
  theme_minimal() +
  labs(title = "Payments Per County", fill = "Amount Paid")