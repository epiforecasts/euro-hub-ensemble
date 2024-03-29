# Load forecasts around variant introductions
library(here)
library(dplyr)
source(here("code", "load", "download_variant_introduction.R"))
source(here("code", "load", "download_forecasts.R"))

# Example
# variant_names <- c("B.1.617.2" = "Delta", "B.1.1.529" = "Omicron")
# forecast_variants <- download_variant_forecasts(load_from_local = FALSE,
#                                         country_names = "Germany",
#                                         variant_codes = names(variant_names))
# write_csv(forecast_variants, here("data", "ensemble-forecast-variants.csv"))

download_variant_forecasts <- function(load_from_local = TRUE,
                                       country_names = NULL,
                                       variant_codes = NULL) {

  # optionally load from running this code previously
  if(load_from_local) {
    forecast_variants <- read_csv(here("data", "ensemble-forecast-variants.csv"))
  } else {
    if (is.null(country_names)) {stop("Specify country names and variant codes")}

  # Variants ----------------------------------------------------------------
  # Variant timings - when variant increased 5-50-100%
  variant_dates <- download_variant_introduction(country_names = country_names,
                                                 variant_codes = variant_codes,
                                                 introduction_percent = 5)

  # Get forecasts -----------------------------------------------------------
  # Get all forecasts covering the whole period
  #    (rebase to Monday forecast_date)
  forecast_dates <- seq.Date(from = min(variant_dates$date_introduction),
                            to = max(variant_dates$date_peak), by = 7) + 2

  forecasts <- download_forecasts(model_names = "EuroCOVIDhub-ensemble",
                                  forecast_dates = forecast_dates)
  # process forecasts: tidy and join to truth data
  forecasts <- process_forecasts(forecasts)

  # Keep forecasts made with target end date in period of variant introduction for each location
  forecast_variants <- forecasts %>%
    left_join(variant_dates,
              by = c("location_name" = "country")) %>%
    group_by(variant) %>%
    filter(!is.na(variant) &
             target_end_date >= date_introduction &
             target_end_date <= date_peak)
  }

  return(forecast_variants)
}
