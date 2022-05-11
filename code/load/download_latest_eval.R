# Get evaluation dataset
library(here)
library(purrr)
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
here::i_am("code/load/download_latest_eval.R")

# Args:
# eval_date the date of an evaluation (a Monday)
# branch        name of branch in github repo if not main
# subdir        subdirectory within root to find evaluations folder (with "/subdir")
# weeks_included  "All" or "10" - number of weeks included in evaluation score
# target_variables  any of "inc case", "inc death", "inc hosp"

download_latest_eval <- function(eval_date,
                                 branch = "main", subdir = "",
                                 weeks_included = "All",
                                 target_variables = c("inc case", "inc death")) {

  # Function to get a single weekly evaluation file
  get_given_date_eval <- function(eval_date, branch, subdir) {
    filepath <- paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/", branch, "/", subdir, "/evaluation/weekly-summary/evaluation-", eval_date, ".csv")
    read_csv(filepath, progress = FALSE, show_col_types = FALSE)
    }

  # Get evaluation file for a given date
  given_date_eval <- get_given_date_eval(eval_date, branch, subdir)

  # check for missing target evaluations due to anomalies
  anomalies_path <- paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/", branch, "/data-truth/anomalies/anomalies.csv")
  anomalies <- read_csv(anomalies_path,
                        progress = FALSE, show_col_types = FALSE) %>%
    filter(target_variable != "inc hosp") %>%
    # Get most recent evaluation date (Monday) before each target goes missing (Sunday)
    mutate(most_recent_eval = target_end_date - 5,
           anomaly_id = row_number()) %>%
    filter((target_end_date + weeks(4)) > as.Date(eval_date)) %>%
    group_by(target_variable, location) %>%
    filter(most_recent_eval == max(most_recent_eval)) %>%
    select(anomaly_id, most_recent_eval, target_variable, location)

  if (nrow(anomalies) > 0) {
    message(paste0("Evaluation as of ", eval_date, " missing some targets due to data anomalies"))

    # Loop through evaluation data-sets to get missing evaluation targets
    missing_eval <- split(anomalies, anomalies$anomaly_id)
    missing_eval <- map_dfr(missing_eval,
                            ~ get_given_date_eval(eval_date = .x$most_recent_eval,
                                                  branch = branch,
                                                  subdir = subdir) %>%
                              filter(target_variable == .x$target_variable &
                                       location == .x$location))

    # Join latest evaluation for all targets
    latest_eval <- bind_rows(given_date_eval, missing_eval)

    # Check this definitely includes all targets (32 locations * 2 variables)
    if (!64 == nrow(
      distinct(latest_eval, target_variable, location) %>%
      filter(location != "Overall" &
             target_variable %in% c("inc case", "inc death")))) {
      warning("Evaluation data missing some targets")
    } else {
      message("All missing targets replaced with respective latest evaluations")
      print(anomalies)
      }

  } else { latest_eval <- given_date_eval}

# Cleaning steps ----------------------------------------------------------
  clean_variables <- c("inc case" = "Cases",
                       "inc death" = "Deaths",
                       "inc hosp" = "Hospitalisations")

  latest_eval <- latest_eval %>%
    filter(
      horizon <= 4 &
        target_variable %in% target_variables &
        weeks_included == !!weeks_included) %>%
    separate(model, into = c("team_name", "model_name"),
             sep = "-", remove = FALSE) %>%
    mutate(
      target_variable = recode(target_variable, !!!clean_variables),
      model = factor(model, ordered = TRUE),
      horizon = factor(horizon, ordered = TRUE),
      across(c(horizon, rel_ae:n_loc), as.numeric),
      across(rel_ae:bias, ~ na_if(., Inf)))

return(latest_eval)
}
