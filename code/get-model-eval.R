# Get evaluation dataset
library(here)
library(purrr)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(covidHubUtils)
here::i_am("code/get-model-eval.R")

# find evaluation  ------------------------------------------------------
# Find latest evaluation
eval_date <- dir(here("covid19-forecast-hub-europe", "evaluation", "weekly-summary"))
eval_date <- sort(as.Date(gsub("(evaluation-)|(\\.csv)", "", eval_date)))
eval_date <- eval_date[length(eval_date)]
eval_file <- here("covid19-forecast-hub-europe", "evaluation", "weekly-summary",
                  paste0("evaluation-", eval_date, ".csv"))

# clean variable names
clean_variables <- c("inc case" = "Cases", "inc death" = "Deaths")

# get model designations - in order to remove "other"
model_desig <- get_model_designations(source = "local_hub_repo",
                                      hub_repo_path = here("covid19-forecast-hub-europe"))

# clean eval dataset ------------------------------------------------------

# Get evaluation and tidy up
model_eval <- read_csv(eval_file) %>%
  # keep only 1-4 horizons
  filter(horizon <= 4) %>%
  # clean up team-model names
  separate(model, into = c("team_name", "model_name"),
           sep = "-", remove = FALSE) %>%
  mutate(
    # add neat variables useful for plots
    target_variable = recode(target_variable, !!!clean_variables),
    model = factor(model, ordered = TRUE),
    # ensure scores are numeric
    across(c(horizon, rel_ae:n_loc), as.numeric),
    # Set Inf value to NA
    across(rel_ae:bias, ~ na_if(., Inf)))

# Exclude some models and targets from evaluation:
model_eval <- model_eval %>%
  filter(
    # hospitalisations
    target_variable %in% clean_variables &
    # location summary
    location != "Overall" &
    # models designated "other"
    !model %in% filter(model_desig, designation == "other")$model &
    # hub baseline (should already be excluded by "other" designation)
    !grepl("hub-baseline", model) &
    # 10 week evaluations (keep only evaluation based on all history)
    weeks_included == "All")

# separate out ensemble scores into own column
score_ensemble <- model_eval %>%
  filter(grepl("hub-ensemble", model)) %>%
  select(weeks_included, target_variable, horizon, location,
         ensemble_rel_wis = rel_wis,
         ensemble_rel_ae = rel_ae)

# add ensemble to every row; leaves ensemble as row as well as col
model_eval <- model_eval %>%
  full_join(score_ensemble,
            by = c("weeks_included", "target_variable", "horizon", "location")) %>%
  mutate(is_hub = grepl("hub-ensemble", model))

###
rm(model_desig, clean_variables, score_ensemble)
