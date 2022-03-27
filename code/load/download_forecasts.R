library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(covidHubUtils)

# Download forecasts ------------------------------------------------------
download_forecasts_with_observed <- function(models, forecast_dates) {

  # Get truth data with anomalies removed ------------------------------------
  raw_truth <- covidHubUtils::load_truth(truth_source = "JHU",
                                         temporal_resolution = "weekly",
                                         hub = "ECDC")
  ## get anomalies
  anomalies <- read_csv("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-truth/anomalies/anomalies.csv")

  truth <- anti_join(raw_truth, anomalies) %>%
    select(location, location_name, target_variable, target_end_date,
           observed = value)

  # Get forecasts -----------------------------------------------------------
  forecasts <- map2_dfr(.x = models, .y = forecast_dates,
                        ~ read_csv(paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-processed/",
                                          .x, "/", .y, "-", .x, ".csv")) %>%
                          mutate(model = .x))

  # Clean forecasts ---------------------------------------------------------
  forecasts <- forecasts %>%
    separate(target, into = c("horizon", "target_variable"), sep = " wk ahead ") %>%
    mutate(horizon = as.numeric(horizon)) %>%
    rename(prediction = value) %>%
    left_join(truth, by = c("location", "target_end_date", "target_variable"))

  ## remove forecasts made directly after a data anomaly
  forecasts <- forecasts %>%
    mutate(previous_end_date = forecast_date - 2) %>%
    left_join(anomalies %>%
                rename(previous_end_date = target_end_date),
              by = c("target_variable",
                     "location", "location_name",
                     "previous_end_date")) %>%
    filter(is.na(anomaly)) %>%
    select(-anomaly, -previous_end_date)

  return(forecasts)

}


