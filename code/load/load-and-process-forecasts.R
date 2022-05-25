# Get all forecasts
library(here)
library(dplyr)
source(here("code", "load", "download_metadata.R"))
source(here("code", "load", "download_forecasts.R"))
source(here("code", "load", "process_forecasts.R"))

## Examples
## Get all forecasts made by one model
# one_model <- download_model_forecasts(model_name = "EuroCOVIDhub-ensemble")
## Get forecasts from specified dates made by all models
# model_names <- download_model_names()
# multiple_models <- download_forecasts(model_names = model_names,
#                                 forecast_dates = c("2021-03-08", "2021-04-26"))
## Process forecasts: add observed data and remove anomalies
# processed_forecasts <- process_forecasts(multiple_models, exclude_anomalies = TRUE)
## Download all forecasts in data-processed
# forecasts_raw <- download_forecasts()

# Download forecasts from specified models over a date range -------------
# Specify date range
eval_date <- as.Date("2022-03-07")
forecast_dates <- get_forecast_dates(max_date = eval_date)

# Specify models - all those not designated "other"
metadata <- download_model_metadata()
## ignore warnings about incomplete final line
model_names <- filter(metadata,
                      team_model_designation != "other") %>%
  pull(model_abbr)

# Get forecasts
forecasts_raw <- download_forecasts(model_names = model_names,
                                    forecast_dates = forecast_dates)
write_csv(forecasts_raw, "raw-forecasts.csv")

# Get any forecasts not yet downloaded
remaining_models <- model_names[!model_names %in% forecasts_raw$model]
remaining_forecasts_raw <- download_forecasts(model_names = remaining_models,
                                    forecast_dates = forecast_dates)
forecasts <- bind_rows(forecasts_raw, remaining_forecasts_raw)
write_csv(forecasts, "raw-forecasts.csv")


# Add observed data and remove anomalies
forecasts_processed <- process_forecasts(forecasts_raw, exclude_anomalies = TRUE)
forecasts <- filter(forecasts_processed, forecast_date <= eval_date)
