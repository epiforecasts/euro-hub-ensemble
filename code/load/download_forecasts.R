library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(covidHubUtils)
library(gh)
source(here("code", "load", "download_metadata.R"))
here::i_am("code/load/download_forecasts.R")

# Get forecasts from a single model at specified forecast dates --------------
## example: get all forecasts made by one model
# one_model <- download_model_forecasts(model_name = "EuroCOVIDhub-ensemble")

download_model_forecasts <- function(model_name, forecast_dates = NULL) {
  # If forecast dates are not specified, get all available forecast dates
  if (is.null(forecast_dates)) {
    model_files <- gh(paste0("/repos/covid19-forecast-hub-europe/covid19-forecast-hub-europe/contents/data-processed/", model_name, "?recursive=1"))
    model_files <- transpose(model_files)
    all_paths <- model_files[["download_url"]]
    forecast_paths <- all_paths[grepl("\\.csv", all_paths)]
  } else {
    # If forecast dates are specified, construct download url directly
    forecast_paths <- map_chr(forecast_dates,
                          ~ paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-processed/",
                                 model_name, "/",
                                 .x, "-",
                                 model_name, ".csv"))
  }
  # Read URLs
  safely_read_csv <- safely(~ read_csv(., progress = FALSE,
                                       show_col_types = FALSE))
  forecasts <- map(forecast_paths, ~ safely_read_csv(.x)) %>%
    transpose()
  forecasts <- bind_rows(forecasts$result) %>%
    mutate(model = model_name)
  closeAllConnections()

  if (nrow(forecasts) > 0) {
    print(paste("Downloaded", model_name))
  }

  return(forecasts)
}

# Get forecasts from multiple models ---------------------------------------
## example: get forecasts from specified dates made by specified models
# multiple_models <- download_forecasts(model_names = c("BIOCOMSC-Gompertz",
#                                                 "EuroCOVIDhub-ensemble"),
#                                 forecast_dates = c("2021-03-08", "2021-04-26"))
download_forecasts <- function(model_names = NULL, forecast_dates = NULL) {
  if (is.null(model_names)) {
    model_names <- download_model_names()
  }
  if (is.null(forecast_dates)) {
    forecast_dates <- get_forecast_dates()
  }
  forecasts <- map_dfr(model_names,
                       ~ download_model_forecasts(model_name = .x,
                                                  forecast_dates = forecast_dates))
  return(forecasts)
}
