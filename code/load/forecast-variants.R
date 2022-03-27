# Load forecasts around variant introductions
library(here)
library(dplyr)
source(here("code", "load", "download_variant_introduction.R"))
source(here("code", "load", "download_forecasts.R"))

load_forecast_variants <- function(load_from_local = TRUE,
                                   country_names, variant_codes) {

  # optionally load from running this code previously
  if(load_from_local) {
    forecast_variants <- read_csv(here("data", "ensemble-forecast-variants.csv"))
  } else {

  # Variants ----------------------------------------------------------------
  # Variant timings - when variant increased 5-50-100%
  variant_dates <- download_variant_introduction(country_names = country_names,
                                                 variant_codes = variant_codes,
                                                 introduction_percent = 5)

  # Get forecasts -----------------------------------------------------------
  # Get all forecasts covering the whole period
  #    (rebase to Monday forecast_date)
  forecast_dates = seq.Date(from = min(variant_dates$date_introduction),
                            to = max(variant_dates$date_peak), by = 7) + 2

  forecasts_gh <- download_forecasts_with_observed(models = "EuroCOVIDhub-ensemble",
                                                   forecast_dates = forecast_dates)

  # Keep forecasts made with target end date in period of variant introduction for each location
  forecast_variants <- forecasts_gh %>%
    left_join(variant_dates,
              by = c("location_name" = "country")) %>%
    group_by(variant) %>%
    filter(!is.na(variant) &
             target_end_date >= date_introduction &
             target_end_date <= date_peak)
  }

  return(forecast_variants)
}

# write_csv(forecast_variants, here("data", "ensemble-forecast-variants.csv"))
