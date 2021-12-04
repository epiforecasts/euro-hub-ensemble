# Get all forecasts
subproj_dir <- "research/intro-paper"
here::i_am(paste0(subproj_dir, "/R/get-model-forecasts.R"))

library(covidHubUtils)
library(scoringutils)
library(dplyr)
library(lubridate)
library(tidyr)
library(EuroForecastHub)

# set up 
report_date <- Sys.Date()

# all models
raw_forecasts <- load_forecasts(source = "local_hub_repo", 
                                hub_repo_path = here("covid19-forecast-hub-europe"), 
                                hub = "ECDC") %>%
  # set forecast date to corresponding submission date
  mutate(forecast_date = ceiling_date(forecast_date, "week", week_start = 2) - 1) %>%
  filter(between(forecast_date, ymd("2021-03-08"), ymd(report_date)) &
           horizon <= 4) %>%
  rename(prediction = value) %>%
  separate(model,
           into = c("team_name", "model_name"), 
           sep = "-", 
           remove = FALSE)

# Remove "other" designated models, except baseline
model_desig_other <- get_model_designations(source = "local_hub_repo",
                                            hub_repo_path = here("covid19-forecast-hub-europe")) %>%
  filter(designation == "other" & model != "EuroCOVIDhub-baseline") %>%
  pull(model)

# Remove horizons > 4 weeks
forecasts <- raw_forecasts %>%
  filter(!model %in% model_desig_other &
           horizon <= 4) %>%
  mutate(target_variable = recode(target_variable,
                                  "inc case" = "Cases",
                                  "inc death" = "Deaths")) %>%
  filter(target_variable != "inc hosp")

# Remove hub forecasts
forecasts_ex_hub <- forecasts %>%
  filter(!grepl("EuroCOVIDhub", model))

rm(model_desig_other)

