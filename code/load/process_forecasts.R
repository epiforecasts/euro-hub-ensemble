# Process forecasts: add observed data and remove anomalies
library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(covidHubUtils)
library(gh)
source(here("code", "load", "download_metadata.R"))
here::i_am("code/load/download_forecasts.R")
## example:
# processed_forecasts <- process_forecasts(forecasts, exclude_anomalous = TRUE)

# Download anomalies --------------------------------------------------------
download_anomalies <- function() {
  anomalies <- read_csv("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-truth/anomalies/anomalies.csv",
                        progress = FALSE, show_col_types = FALSE)
  # Clarify dates to exclude forecasts made the following week
  anomalies <- anomalies %>%
    mutate(following_forecast_date = target_end_date + 2)
  return(anomalies)
}

# Add observed data and remove anomalies -----------------
process_forecasts <- function(forecasts, exclude_anomalies = TRUE) {
  # tidy variables
  forecasts <- forecasts %>%
    separate(target, into = c("horizon", "target_variable"), sep = " wk ahead ") %>%
    mutate(horizon = as.numeric(horizon)) %>%
    rename(prediction = value)

  if (exclude_anomalies) {
    # get anomalies
    anomalies <- download_anomalies()
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
