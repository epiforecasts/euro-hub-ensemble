# Get all evaluation scores
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
here::i_am("code/load-evaluation-scores.R")

# Settings for all evaluation scores --------------------------------------
source(here("code", "download_latest_eval.R"))
if (!exists("eval_date")) {eval_date <- as.Date("2022-03-07")}

# Individual model evaluation ---------------------------------------------
scores_model <- download_latest_eval(eval_date, "main", "",
                                     weeks_included = "All",
                                     target_variables = c("inc case", "inc death"))

# Exclusions - models designated "other"
source(here("code", "download_model_metadata.R"))
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

rm(score_realtime_ensemble, metadata_other, download_metadata)

# Separately created retrospective ensemble scores --------------------------
scores_ensemble <- download_latest_eval(eval_date = eval_date,
                                 branch = "assess-ensembles", subdir = "ensembles",
                                 weeks_included = "All",
                                 target_variables = c("inc case", "inc death"))

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
