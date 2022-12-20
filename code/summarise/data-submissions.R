# Summarise our raw dataset - all submissions including those excluded from scoring
library(dplyr)
library(arrow)
library(purrr)
source(here("code", "load", "download_metadata.R"))

# Get all submitted predictions  ----------------------------------------
# The size of the combined csv files is too large to read efficiently
#   instead we can use Apache Arrow parquet file format.
# Parquet file created and saved to data/ file. Source code:
# source("https://gist.githubusercontent.com/kathsherratt/c942c1a5870db243a5c6a9a066de4f6e/raw/1384b81735599a3a4550c1e31197debcac6320c3/create-parquet.R")

# Read in parquet file
submissions <- arrow::read_parquet(here("data", "covid19-forecast-hub-europe.parquet")) |>
  mutate(target_variable = gsub("inc ", "", target_variable))

# Exclusions ------------------------------------------------------------
submissions <- submissions |>
  filter(!grepl("EuroCOVIDhub", model))

# Split all from models designated "other"
metadata_other <- download_model_metadata() |>
  filter(team_model_designation == "other") |>
  pull(model_abbr)
submissions <- submissions |>
  filter(!model %in% metadata_other)

# Summarise all submissions --------------------------------------------------
sum_submissions <- submissions |>
  summarise(n_predictions = n(),
            n_forecasts = n_distinct(model, target_end_date, location, target_variable),
            n_models = n_distinct(model))

# Individual models -------------------------------------------------------
# Summary of participants and models across targets
submitted_per_target <- submissions |>
  group_by(target_variable, horizon, location_name) |>
  summarise(n_prediction = n(),
            n_forecast = n_distinct(model, target_end_date),
            n_model = n_distinct(model)) |>
  ungroup()

submitted_modellers <- list("max" = slice_max(submitted_per_target,
                                            n_model),
                   "min" = slice_min(submitted_per_target,
                                            n_model))

# quantiles ---------------------------------------------------------------
submissions_point <- filter(submissions, type == "point") |>
  pull(model) |>
  unique()

submissions_quantile <- filter(submissions, type == "quantile") |>
  pull(model) |>
  unique()

submissions_quantiles_full <- ungroup(submissions) |>
  filter(type == "quantile") |>
  group_by(model, forecast_date, target_end_date, location, target_variable) |>
  summarise(n = n()) |>
  ungroup() |>
  filter(n == 23) |>
  summarise(models = n_distinct(model))

