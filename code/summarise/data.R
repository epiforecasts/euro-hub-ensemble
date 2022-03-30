# Create values to summarise data in text
#   and figures for supplementary information (SI)
library(dplyr)
library(lubridate)

# Get evaluation scores if not already present
if (!exists("scores_model")) {source(here("code", "load", "evaluation-scores.R"))}

# Study period -----------------------------------------------------------
hub <- list(
  # Evaluation period
  "n_weeks" = max(scores_model$n),
  "start_date" = format.Date(eval_date - weeks(max(scores_model$n)), "%d %B %Y"),
  "end_date" = format.Date(eval_date, "%d %B %Y")
)

# Individual models -------------------------------------------------------
# scores per target excluding hub ensemble
scores_model_exhub <- scores_model %>%
  filter(!is_hub) %>%
  mutate(rel_wis_distance = ensemble_rel_wis - rel_wis)

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
  "median_score" = median(scores_model_exhub$rel_wis, na.rm = TRUE),
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
  "median_score" = median(scores_model %>% filter(is_hub) %>% pull(rel_wis), na.rm = TRUE),
  "vs_models" = scores_model_exhub %>%
    filter(!is.na(rel_wis))  %>%
    group_by(target_variable) %>%
    summarise(n = n(),
              p_better = round(sum(rel_wis_distance <= 0) / n * 100)) %>%
    split(.$target_variable)
)
