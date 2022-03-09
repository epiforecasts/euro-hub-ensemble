# Anomalies
library(here)
library(readr)
library(dplyr)
library(covidHubUtils)

here::i_am("code/anomalies.R")
# hub_submodule <- here("hub-data", "assess-ensembles") # "updated-evaluations"
# hub_submodule <- here("hub-data", "updated-evaluations")

anomalies <- read_csv(here(hub_submodule, "data-truth", "anomalies", "anomalies.csv")) %>%
  filter(target_variable != "inc hosp")

model_desig <- covidHubUtils::get_model_designations(source = "local_hub_repo",
                                                     hub_repo_path = hub_submodule) |>
  filter(designation != "other")

setdiff(model_desig$model, unique(model_eval$model))
setdiff(hub_locations_ecdc$location_name, unique(model_eval$location_name))
