# Get model metadata
library(gh)
library(purrr)
library(yaml)
here::i_am("code/load/download_metadata.R")

# Downloading different types of metadata ----------------------------------
# Get hub metadata
download_hub_metadata <- function() {
  hub <- jsonlite::read_json("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/project-config.json")
  return(hub)
}

# Get all possible forecast dates
get_forecast_dates <- function(max_date = NULL) {
  hub <- download_hub_metadata()
  forecast_dates <- seq.Date(from = as.Date(hub[["launch_date"]]),
                             to = Sys.Date(), by = 7)
  if (!is.null(max_date)) {
    forecast_dates <- forecast_dates[forecast_dates <= as.Date(max_date)]
  }
}

# Get all available model names in data-processed
download_model_names <- function() {
  models <- gh("/repos/covid19-forecast-hub-europe/covid19-forecast-hub-europe/contents/data-processed?recursive=true")
  models <- unlist(transpose(models)$name)
  models <- models[!grepl("schema.+yml", models)] # exclude hub schema files
}

# Download all model metadata
download_model_metadata <- function() {
  models <- download_model_names()
  # Get paths for metadata files
  model_metadata_paths <- map_chr(models,
                                  ~ paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-processed/",
                                           .x, "/metadata-", .x, ".txt"))
  # Download metadata into single data frame
  metadata <- map_dfr(model_metadata_paths, ~ read_yaml(.x))
  return(metadata)
}

