# Get evaluation of ensembles
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
here::i_am("code/get-ensemble-eval.R")

# Download evaluation of ensembles from github
source(here("code", "get_latest_eval.R"))
eval_date <- as.Date("2022-03-07")
ensemble_eval <- get_latest_eval(eval_date = eval_date,
                                 branch = "assess-ensembles",
                                 subdir = "ensembles")

# Clean -------------------------------------------------------------------
# neater factor labels
clean_target_names <- c("inc case" = "Cases", "inc death" = "Deaths")
# only keep "main" (weighted/unweighted mean/median) ensembles
ensemble_eval <- ensemble_eval %>%
  filter(model %in% c("EuroCOVIDhub-mean",
                      "EuroCOVIDhub-median",
                      "EuroCOVIDhub-All_relative_skill_weighted_mean",
                      "EuroCOVIDhub-All_relative_skill_weighted_median") &
         horizon <= 4 &
         weeks_included == "All" &
         # !location %in% "Overall" &
         target_variable %in% names(clean_target_names) &
         is.finite(rel_wis)) %>%
  mutate(model = sub("EuroCOVIDhub-All_relative_skill_weighted_", "Weighted ", model),
         model = sub("EuroCOVIDhub-", "Unweighted ", model),
         target_variable = recode(target_variable, !!!clean_target_names),
         # ensure scores are numeric
         across(c(horizon, rel_ae:n_loc), as.numeric),
         # set horizon as ordered factor
         horizon = factor(horizon, ordered = TRUE))

# Clean environment -----------------------------------------------------------
rm(clean_target_names)
