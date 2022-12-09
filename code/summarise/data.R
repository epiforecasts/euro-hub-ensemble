# Create values to summarise data in text
#   and figures for supplementary information (SI)
library(here)
library(readr)
library(dplyr)
library(lubridate)

# Get evaluation scores (saved locally) if not already present
if (!exists("scores_model")) {
  scores_model <- read_csv(here("data", "scores-model.csv"))
}
eval_date <- as.Date("2022-03-07")

# Study period -----------------------------------------------------------
hub <- list(
  # Evaluation period
  "n_weeks" = max(scores_model$n),
  "start_date" = format.Date(eval_date - weeks(max(scores_model$n)), "%d %B %Y"),
  "end_date" = format.Date(eval_date, "%d %B %Y")
)

# Submissions (including those excluded from scoring) ---------------------
# The size of the combined csv files is too large to read efficiently
#   instead we can use Apache Arrow parquet file format.
# Parquet file created and saved to data/ file. Source code:
# source("https://gist.githubusercontent.com/kathsherratt/c942c1a5870db243a5c6a9a066de4f6e/raw/1384b81735599a3a4550c1e31197debcac6320c3/create-parquet.R")
#
# read in parquet file
forecasts <- arrow::read_parquet("data/covid19-forecast-hub-europe.parquet")
# number of models and forecasts for each location at each target date
submissions <- forecasts |>
  filter(!grepl("EuroCOVIDhub", model)) |>
  group_by(target_variable, location, horizon) |>
  summarise(n = n(),
            n_models = n_distinct(model)) |>
  ungroup() |>
  mutate(target_variable = gsub("inc ", "", target_variable))

submissions_range <- list(
  "max" = slice_max(submissions, order_by = n_models,
                    n = 1, with_ties = FALSE) |>  as.list(),
  "min" = slice_min(submissions, order_by = n_models,
                    n = 1) |>  slice_max(n = 1, order_by = horizon) |> as.list())

# Individual models -------------------------------------------------------
# scores per target excluding hub ensemble
scores_model_exhub <- scores_model %>%
  filter(!is_hub) %>%
  mutate(rel_wis_distance = ensemble_rel_wis - rel_wis,
         rel_ae_distance = ensemble_rel_ae - rel_ae)

# Summary of participants and models across targets
models_per_target <- scores_model_exhub %>%
  group_by(target_variable, horizon, location_name) %>%
  summarise(n_models = n(),
            n_scores = sum(n)) %>%
  ungroup() %>%
  mutate(target_variable = tolower(target_variable))

target_per_model <- scores_model_exhub %>%
  group_by(target_variable, horizon, model) %>%
  summarise(n_locs = n())

modellers <- list(
  "n_model" = length(unique(scores_model_exhub$model)),
  "n_team" = length(unique(scores_model_exhub$team_name)),
  "n_model_wis" = filter(scores_model_exhub, !is.na(rel_wis)) %>%
    distinct(model) %>% nrow(),
  "targets" = list("max_scores" = slice_max(models_per_target,
                                            n_scores) %>% as.list(),
                   "min_scores" = slice_min(models_per_target,
                                            n_scores) %>% as.list(),
                   "max_models" = max(models_per_target$n_models),
                   "min_models" = min(models_per_target$n_models)))

# Distribution of scores among models
modeller_scores <- list(
  "n_rel_wis" = sum(!is.na(scores_model_exhub$rel_wis)),
  "score_range" = quantile(scores_model_exhub$rel_wis,
                           probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
                           na.rm = TRUE),
  "score_3_n" = sum(scores_model_exhub$rel_wis > 3, na.rm = TRUE),
  "score_3_p" = sum(scores_model_exhub$rel_wis > 3, na.rm = TRUE) / sum(!is.na(scores_model_exhub$rel_wis)) * 100)

# ensemble score summary --------------------------------------------------
hub_scores_summary <- scores_model %>%
  filter(is_hub) %>%
  group_by(horizon) %>%
  summarise(min_score = min(rel_wis, na.rm = TRUE),
            max_score = max(rel_wis, na.rm = TRUE),
            beat_base = sum(rel_wis <= 1, na.rm = TRUE) / n() * 100,
            q75 = quantile(rel_wis, probs = 0.75, na.rm = TRUE),
            median_score = median(rel_wis, na.rm = TRUE)
  )

hub_scores <- list(
  "score_range" = quantile(scores_model |>
                             filter(is_hub) |>
                             pull(rel_wis),
                           probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
                           na.rm = TRUE),
  "wis_vs_models" = scores_model_exhub |>
    filter(!is.na(rel_wis_distance)) |>
    group_by(target_variable) |>
    summarise(n = n(),
              models = n_distinct(model),
              p_better = round(sum(rel_wis_distance <= 0) / n * 100)) %>%
    split(.$target_variable),
  "ae_vs_models" = scores_model_exhub |>
    filter(!is.na(rel_ae_distance)) |>
    group_by(target_variable) |>
    summarise(n = n(),
              models = n_distinct(model),
              p_better = round(sum(rel_ae_distance <= 0) / n * 100)) %>%
    split(.$target_variable)
)
