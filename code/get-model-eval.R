# Get evaluation dataset
library(here)
library(dplyr)
library(tidyr)
here::i_am("code/get-model-eval.R")

# Function to get evaluations
source("code/get_latest_eval.R")

# Get evaluations for each individual model submitted to Hub
branch <- "main"
subdir <- ""
eval_date <- as.Date("2022-03-07")
model_eval <- get_latest_eval(eval_date, branch, subdir)

# Clean data set ------------------------------------------------------
# set variable names
clean_variables <- c("inc case" = "Cases", "inc death" = "Deaths")

# Tidy variables
model_eval <- model_eval %>%
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

# Exclusions --------------------------------------------------------------
# get model designations
source(here("code", "get-model-metadata.R"))

# Exclude some models and targets from evaluation
model_eval <- model_eval %>%
  filter(
    # Targets
    ## - keep only 1-4 horizons
    horizon <= 4 &
    ## - exclude hospitalisations
    target_variable %in% clean_variables &
    # Models
    ## - models designated "other"
    !model %in% filter(metadata, team_model_designation == "other")$model_abbr &
    ## - hub baseline (should already be excluded by "other" designation)
    !grepl("hub-baseline", model) &
    # Evaluation methods
    ## - exclude location summary
    location != "Overall" &
    ## - 10 week evaluations (keep only evaluation based on all history)
    weeks_included == "All")

# Ensemble model scores ---------------------------------------------------
# separate out ensemble scores into own column
ensemble_score <- model_eval %>%
  filter(grepl("hub-ensemble", model)) %>%
  select(weeks_included, target_variable, horizon, location,
         ensemble_rel_wis = rel_wis,
         ensemble_rel_ae = rel_ae)

# add ensemble to every row; leaves ensemble as row as well as col
model_eval <- model_eval %>%
  full_join(ensemble_score,
            by = c("weeks_included", "target_variable", "horizon", "location")) %>%
  mutate(is_hub = grepl("hub-ensemble", model))

###
rm(metadata, clean_variables, ensemble_score)
