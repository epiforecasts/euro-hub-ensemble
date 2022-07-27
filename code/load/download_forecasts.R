library(here)
library(readr)
library(dplyr)
library(vroom)
library(purrr)
library(tidyr)
library(covidHubUtils)
library(gh)
library(arrow) # for fast csv loading
source(here("code", "load", "download_metadata.R"))
here::i_am("code/load/download_forecasts.R")

# Get forecasts from a single model at specified forecast dates --------------
## example: get all forecasts made by one model
# one_model <- download_model_forecasts(model_name = "EuroCOVIDhub-ensemble")

download_model_forecasts <- function(model_name, forecast_dates = NULL) {

  # If forecast dates are not specified, get all available forecast dates
  if (is.null(forecast_dates)) {
    model_files <- gh(paste0("/repos/covid19-forecast-hub-europe/covid19-forecast-hub-europe/contents/data-processed/", model_name, "?recursive=1"))
    model_files <- purrr::transpose(model_files)
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
  # safely_read_csv <- safely(~ vroom::vroom(., guess_max = 50,
  #                                   progress = TRUE,
  #                                   show_col_types = FALSE))
  safely_read_csv <- safely(~ arrow::read_csv_arrow(.))

  #
  forecasts <- purrr::map(forecast_paths, ~ safely_read_csv(.x)) %>%
    purrr::transpose(.l = .)
  closeAllConnections()
  gc()

  forecasts <- bind_rows(forecasts$result) %>%
    mutate(model = model_name)
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


# Process forecasts -------------------------------------------------------
# Add observed data and remove anomalies
process_forecasts <- function(forecasts, exclude_anomalies = TRUE) {
  # tidy variables
  forecasts <- forecasts %>%
    separate(target, into = c("horizon", "target_variable"), sep = " wk ahead ") %>%
    mutate(horizon = as.numeric(horizon)) %>%
    rename(prediction = value)

  if (exclude_anomalies) {
    # get anomalies
    anomalies <- download_anomalies()
    # add forecast date in the following week after anomalous target
    anomalies <- anomalies |>
      mutate(following_forecast_date = target_end_date + 5)

    exclude_by_target_end_date <- select(anomalies,
                                         target_variable,
                                         location, location_name,
                                         target_end_date)
    exclude_by_forecast_date <- select(anomalies,
                                       target_variable, location, location_name,
                                       forecast_date = following_forecast_date)
    forecasts <- forecasts %>%
      anti_join(exclude_by_target_end_date) %>%
      anti_join(exclude_by_forecast_date)
  }

  # Download observed data and join to forecasts
  # TODO get truth data directly from hub and aggregate to weekly
  obs <- covidHubUtils::load_truth(truth_source = "JHU",
                                   temporal_resolution = "weekly",
                                   hub = "ECDC") %>%
    select(location, target_variable, target_end_date,
           observed = value)
  forecasts <- left_join(forecasts, obs, by = c("location",
                                                "target_variable",
                                                "target_end_date"))

  # add location names
  hub_locations <- read_csv("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-locations/locations_eu.csv",
                            progress = FALSE, show_col_types = FALSE) %>%
    select(location_name, location)
  forecasts <- left_join(forecasts, hub_locations, by = "location")

  return(forecasts)
}

