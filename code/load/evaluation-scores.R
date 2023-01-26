# Get all evaluation scores
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
here::i_am("code/load/evaluation-scores.R")

# Set up ------------------------------------------------------------------
# Set date of evaluation
if (!exists("eval_date")) {eval_date <- as.Date("2022-03-07")}

# Load from local csv -----------------------------------------------------
# Optional skip download steps below and load from locally saved csv
if (!exists("load_from_local")) {load_from_local <- TRUE}

if(load_from_local) {
  scores_model <- read_csv(here("data", "scores-model.csv"))
  scores_ensemble <- read_csv(here("data", "scores-ensemble.csv"))
  message("Scores loaded from csvs saved in 'data/'")
} else {

# Otherwise download from Github repo ------------------------------------
  message("Loading scores from Github")
  source(here("code", "load", "download_latest_eval.R"))

  # Get individual model evaluation ------------------------------------------
  scores_model <- download_latest_eval(eval_date, "main", "",
                                       weeks_included = "All",
                                       target_variables = c("inc case",
                                                            "inc death"))

  # Exclusions - models designated "other"
  source(here("code", "load", "download_metadata.R"))
  metadata_other <- download_model_metadata() %>%
    filter(team_model_designation == "other") %>%
    pull(model_abbr)

  scores_model <- scores_model %>%
    filter(!model %in% metadata_other &
             !grepl("hub-baseline", model) &
             !location == "Overall")

  # separate out ensemble scores into own column
  score_realtime_ensemble <- scores_model %>%
    filter(grepl("hub-ensemble", model)) %>%
    select(weeks_included, target_variable, horizon, location,
           ensemble_rel_wis = rel_wis,
           ensemble_rel_ae = rel_ae)

  # add ensemble to every row; leaves ensemble as row as well as col
  scores_model <- scores_model %>%
    full_join(score_realtime_ensemble,
              by = c("weeks_included", "target_variable", "horizon", "location")) %>%
    mutate(is_hub = grepl("hub-ensemble", model))

  rm(score_realtime_ensemble, metadata_other)

  # Save
  write_csv(scores_model, here("data", "scores-model.csv"))

  # Get separately created retrospective ensemble scores --------------------------
  scores_ensemble <- download_latest_eval(eval_date = eval_date,
                                          branch = "assess-ensembles-update",
                                          subdir = "ensembles",
                                          weeks_included = "All",
                                          target_variables = c("inc case",
                                                               "inc death"))

  # Include only 4 ensemble models
  scores_ensemble <- scores_ensemble %>%
    filter(model %in% c("EuroCOVIDhub-mean",
                        "EuroCOVIDhub-median",
                        "EuroCOVIDhub-All_relative_skill_weighted_mean",
                        "EuroCOVIDhub-All_relative_skill_weighted_median")) %>%
    mutate(model = sub("EuroCOVIDhub-All_relative_skill_weighted_", "Weighted ", model),
           model = sub("EuroCOVIDhub-", "Unweighted ", model)
    )

  # Save
  write_csv(scores_ensemble, here("data", "scores-ensemble.csv"))
}
