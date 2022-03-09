# Get evaluation dataset
library(here)
library(purrr)
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
here::i_am("code/get-model-eval.R")

# Function to get a single weekly evaluation file
get_eval_file <- function(branch, eval_date) {
  filepath <- paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/", branch, "/evaluation/weekly-summary/evaluation-", eval_date, ".csv")
  eval <- read_csv(filepath)
  return(eval)
}

# Repository settings
eval_date <- as.Date("2022-03-07")
branch <- "main"

# Get most recent evaluation file --------------------------------
latest_eval <- get_eval_file(branch = branch, eval_date = eval_date)

# check for recent missing target evaluations due to anomalies
anomalies <- read_csv(paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/", branch, "/data-truth/anomalies/anomalies.csv")) %>%
  filter(target_variable != "inc hosp") %>%
  # Get most recent evaluation date for each missing target
  mutate(most_recent_eval = target_end_date - 5, # Monday before Sunday target date
         anomaly_id = row_number()) %>%
  filter((target_end_date + weeks(4)) > eval_date) %>% # missing in latest_eval
  group_by(target_variable, location) %>%
  filter(most_recent_eval == max(most_recent_eval)) %>%
  select(anomaly_id, most_recent_eval, target_variable, location)

# Loop through evaluation data-sets to get missing evaluation targets
missing_eval <- split(anomalies, anomalies$anomaly_id)
missing_eval <- map_dfr(missing_eval,
                        ~ get_eval_file(branch = branch,
                                        eval_date = .x$most_recent_eval) %>%
                          filter(target_variable == .x$target_variable &
                                   location == .x$location))

# Join latest evaluation for all targets
model_eval <- bind_rows(latest_eval, missing_eval)

# Check this definitely includes all targets (32 locations * 2 variables)
if (!64 == nrow(
  distinct(model_eval, target_variable, location) %>%
    filter(location != "Overall" &
             target_variable %in% c("inc case", "inc death")))) {
  warning("Evaluation data missing some targets")}

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
