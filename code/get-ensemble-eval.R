# Get evaluation of ensembles
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
here::i_am("code/get-ensemble-eval.R")
# Function to get evaluations
source("code/get_latest_eval.R")

# Get evaluations for each individual model submitted to Hub
branch <- "assess-ensembles"
subdir <- "ensembles"
eval_date <- as.Date("2022-03-07")
ensemble_eval <- get_latest_eval(eval_date = eval_date,
                                 branch = branch, subdir = subdir)

# Get latest evaluation dataset ------------------------------------------------
# eval_date <- dir(here(hub_submodule,
#                       "ensembles", "evaluation", "weekly-summary"))
# eval_date <- sort(as.Date(gsub("(evaluation-)|(\\.csv)", "", eval_date)))
# eval_date <- eval_date[length(eval_date)]
# eval_file <- here(hub_submodule,
#                   "ensembles", "evaluation", "weekly-summary",
#                   paste0("evaluation-", eval_date, ".csv"))

# Prep dataset
# neater factor labels
clean_target_names <- c("inc case" = "Cases", "inc death" = "Deaths")
main_ensembles_names <- c(
  "mean" = "Unweighted mean",
  "All_relative_skill_weighted_mean" = "Weighted mean",
  "median" = "Unweighted median",
  "All_relative_skill_weighted_median" = "Weighted median"
)

# Tidy up
eval_ensemble <- read_csv(eval_file) %>%
  # keep only 1-4 horizons
  filter(horizon <= 4) %>%
  # clean up team-model names
  separate(model, into = c("team_name", "model"),
           sep = "-", remove = FALSE) %>%
  mutate(
    target_variable = recode(target_variable, !!!clean_target_names),
    method_average = case_when(grepl("mean", model) ~ "Mean",
                                 grepl("median", model) ~ "Median"),
    method_weight = case_when(grepl("weighted", model) ~ "Weighted",
                                 TRUE ~ "Unweighted"),
    method_history = case_when(grepl("[0-9]+", model) ~
                               paste(suppressWarnings(
                                 parse_number(gsub("-", "", model))),
                                     "weeks history"),
                               TRUE ~ "All history"),
    method_cutoff = case_when(grepl("cutoff", model) ~ "Cutoff rel. WIS < 1",
                              TRUE ~ "No cutoff"),
    ensemble_name = recode(model, !!!main_ensembles_names),
    main_ensemble = model %in% names(main_ensembles_names),
    # ensure scores are numeric
    across(c(horizon, rel_ae:n_loc), as.numeric),
    # set horizon as ordered factor
    horizon = factor(horizon, ordered = TRUE)) %>%
  select(model, ensemble_name, main_ensemble,
         starts_with("method_"), weeks_included,
         location, location_name, target_variable, horizon,
         n, rel_wis, cov_50, cov_95) %>%
  filter(!location %in% "Overall" &
          !grepl("baseline|horizon", model) &
          target_variable %in% clean_target_names)

# Comparison at 2 week horizon -----------------------------------------------
"
Testing variation over 6 method inputs:
- 32 locations:
  - Location * 32
- 2 targets:
  - Case | Death
- 2 averaging methods
  - Mean | Median
- 2 weighting methods
  - Unweighted | Weighted
    - 2 weighting methods:
      - All history, 10 week history
      - All performance, cutoff performance

  unweighted = 32*2*2 combinations = 256
+ weighted = (32*2*2)*4 = 512
= 768
- 12 scores with infinite WIS values
= 756

We are taking the average difference when changing one input, for each of
four inputs (average, weight, history, cutoff)
"
# calculate difference between scores comparable on all variables except one
compare_ensemble_diffs <- function(at_horizon, eval_ensemble) {

  reference <- c(method_cutoff = "No cutoff",
                 method_average = "Mean",
                 method_weight = "Unweighted",
                 method_history = "All history")

  tests <- names(eval_ensemble)[grepl("method_", names(eval_ensemble))]

  plot_base <- eval_ensemble %>%
    filter(location != "Overall" &
             horizon == at_horizon &
             weeks_included == "All" &
             !is.infinite(rel_wis)
    ) %>%
    mutate(model = factor(model),
           model = forcats::fct_rev(model)) %>%
    select_at(c("target_variable", "horizon", "location_name",
                tests, "rel_wis"))

  differences <- list()
  ensemble_change_n <- list()

  for (test in tests) {
    # Get all variables but one
    plot_table <- plot_base %>%
      select_at(c("target_variable", "horizon", "location_name",
                  setdiff(tests, test), test, "rel_wis")) %>%
      unite("matches", 2:(ncol(.) - 2)) %>%
      pivot_wider(names_from = all_of(test), values_from = "rel_wis") %>%
      pivot_longer(3:ncol(.)) %>%
      group_by(target_variable, matches) %>%
      mutate(all_there = all(!is.na(value))) %>%
      ungroup() %>%
      filter(all_there) %>%
      select(-all_there)

    ptw <- plot_table %>%
      pivot_wider() %>%
      mutate(across(.cols = c(3,4), as.numeric))
    alternative_columns <- setdiff(colnames(ptw),
                                   c("target_variable", "matches", reference[[test]]))

    # Compare difference in scores when one method variable changed
    for (column in alternative_columns) {
      raw_differences <- ptw[[column]] - ptw[[reference[[test]]]]
      raw_differences <- raw_differences[is.finite(raw_differences)]
      differences[[column]] <- tibble(mean = round(mean(raw_differences), 2),
                                      median = round(median(raw_differences), 2),
                                      low_48 = round(quantile(raw_differences, 0.26), 2),
                                      high_48 = round(quantile(raw_differences, 0.74), 2),
                                      low_96 = round(quantile(raw_differences, 0.02), 2),
                                      high_96 = round(quantile(raw_differences, 0.98), 2),
                                      n = length(raw_differences))
      ensemble_change_n[[column]] <- length(raw_differences)
    }
  }
  ensemble_change_dtb <- bind_rows(differences, .id = "change")
  ensemble_change_dtb$horizon <- at_horizon

  return(list("ensemble_change_dtb" = ensemble_change_dtb,
              "ensemble_change_n" = ensemble_change_n))
}

# Clean -------------------------------------------------------------------
rm(eval_file, clean_target_names, main_ensembles_names)
