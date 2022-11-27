# Get evaluation scores from Github, for individual models and ensemble variations
# get_model_scores()
# get_ensemble_scores()

library(here)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)

# Generic function to download evaluation csv from Github
source(here("code", "load", "download_latest_eval.R"))

# Get individual model evaluation ---------------------------------------------
get_model_scores <- function(eval_date = as.Date("2022-03-07"),
                             save = FALSE) {
  # Get evaluation
  scores_model <- download_latest_eval(eval_date,
                                       branch = "main", subdir = "",
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
              by = c("weeks_included", "target_variable",
                     "horizon", "location")) %>%
    mutate(is_hub = grepl("hub-ensemble", model))

  # Save the downloaded data -----------------------------------------------
  if (save) {
    write_csv(scores_ensemble, here("data", "scores-ensemble.csv"))
  }

  return(scores_model)
  }

# Get separately created retrospective ensemble scores -----------------------
get_ensemble_scores <- function(# eval_date = # not updated,
                                save = FALSE) {
  scores_ensemble <- download_latest_eval(eval_date = as.Date("2022-03-07"),
                                          branch = "assess-ensembles",
                                          subdir = "ensembles",
                                          weeks_included = "All",
                                          target_variables = c("inc case",
                                                               "inc death"))

  # Include only 4 ensemble models
  scores_ensemble <- scores_ensemble %>%
    filter(model %in% c("EuroCOVIDhub-mean",
                        "EuroCOVIDhub-median",
                        "EuroCOVIDhub-All_relative_skill_weighted_mean",
                        "EuroCOVIDhub-All_relative_skill_weighted_median") &
             is.finite(rel_wis)) %>%
    mutate(model = sub("EuroCOVIDhub-All_relative_skill_weighted_", "Weighted ", model),
           model = sub("EuroCOVIDhub-", "Unweighted ", model)
    )

  # Save the downloaded data -----------------------------------------------
  if (save) {
    write_csv(scores_ensemble, here("data", "scores-ensemble.csv"))
  }
  return(scores_ensemble)
}
