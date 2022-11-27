# Generic function to get an evaluation dataset on Hub github
# used in:
#    here("code", "load", "get-scores.R")
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

download_latest_eval <- function(eval_date = as.Date("2022-03-07"),
                                 branch = "main", subdir = "",
                                 weeks_included = "All",
                                 target_variables = c("inc case", "inc death"),
                                 all_model = FALSE) {

  # Function to get a single weekly evaluation file
  get_given_date_eval <- function(eval_date, branch, subdir) {
    print(eval_date)
    filepath <- paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/", branch, "/", subdir, "/evaluation/weekly-summary/evaluation-", eval_date, ".csv")
    read_csv(filepath, progress = FALSE, show_col_types = FALSE)
    }

  # Get evaluations up to latest evaluation date
  all_eval_dates = seq.Date(from = as.Date("2021-04-05"), # start of evaluation
                            to = eval_date,
                            by = 7)
  # get last 5 evaluations (assuming all targets represented in last 5)
  all_eval_dates <- all_eval_dates[length(all_eval_dates):(length(all_eval_dates)-4)]
  all_eval <- map_dfr(all_eval_dates,
                      ~ get_given_date_eval(.x, branch, subdir) |>
                        mutate(eval_date = .x))

  # Filter to latest evaluation available for each target
  if(all_model) {
    latest_eval <- all_eval |>
      group_by(location, target_variable, model) |>
      filter(eval_date == max(eval_date))
  } else {
    latest_eval <- all_eval |>
      group_by(location, target_variable) |>
      filter(eval_date == max(eval_date))
  }
# Cleaning steps ----------------------------------------------------------
  clean_variables <- c("inc case" = "Cases",
                       "inc death" = "Deaths",
                       "inc hosp" = "Hospitalisations")

  latest_eval <- latest_eval |>
    ungroup() |>
    filter(
      horizon <= 4 &
        target_variable %in% target_variables &
        weeks_included == !!weeks_included)|>
    separate(model, into = c("team_name", "model_name"),
             sep = "-", remove = FALSE)|>
    mutate(
      target_variable = recode(target_variable, !!!clean_variables),
      model = factor(model, ordered = TRUE),
      horizon = factor(horizon, ordered = TRUE),
      across(c(horizon, rel_ae:n_loc), as.numeric),
      across(rel_ae:bias, ~ na_if(., Inf)))

return(latest_eval)
}
