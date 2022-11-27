# Get all evaluation scores
library(here)
library(readr)
here::i_am("code/load/evaluation-scores.R")

# By default, load from locally saved csv
if (!exists("load_from_local")) {load_from_local <- FALSE}

# Load from local csv -----------------------------------------------------
if(load_from_local) {
  scores_model <- read_csv(here("data", "scores-model.csv"))
  scores_ensemble <- read_csv(here("data", "scores-ensemble.csv"))
  message("Scores loaded from csvs saved in 'data/'")

} else {

# Download and clean evaluation csvs from github ----------------------------
  source(here("code", "load", "get-scores.R"))
  # if (!exists("eval_date")) {eval_date <- as.Date("2022-03-07")}
  scores_model <- get_model_scores(eval_date, save = FALSE)
  scores_ensemble <- get_ensemble_scores(save = FALSE)
}

