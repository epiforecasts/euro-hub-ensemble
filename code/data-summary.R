# Create values to describe data in text
library(dplyr)

# Get evaluation scores if not already present
if (!exists("scores_model")) {source(here("code", "load-evaluation-scores.R"))}

# Note - All model descriptions include the hub ensemble model
metadata <- list(
  # Evaluation period
  "n_weeks" = max(scores_model$n),
  "start_date" = format.Date(eval_date - weeks(max(scores_model$n)), "%d %B %Y"),
  "end_date" = format.Date(eval_date, "%d %B %Y"),
  # Number of forecasters
  "n_model" = length(unique(scores_model$model)),
  "n_team" = length(unique(scores_model$team_name)),
  "n_model_wis" = filter(scores_model, !is.na(rel_wis)) %>%
    distinct(model) %>% nrow()
)

targets <- scores_model %>%
  group_by(target_variable) %>%
  summarise(n = n())



# How often did the ensemble beat any score from all model scores?
n_ensemble <- filter(scores_model, !is_hub) %>%
  group_by(target_variable) %>%
  summarise(n = n(),
            ensemble_beat = sum(ensemble_rel_wis < rel_wis, na.rm = TRUE),
            p_ensemble_beat = ensemble_beat / n * 100)
n_model_scores <- map(split(n_ensemble, n_ensemble$target_variable),
                      ~ .x %>% pull(n))
p_ensemble_beat <- map(split(n_ensemble, n_ensemble$target_variable),
                       ~ .x %>% pull(p_ensemble_beat) %>% round(0))

# -------------------------------------------------------------------------
# How often did the ensemble beat the baseline across locations?
n_ensemble_loc <- scores_model %>%
  filter(is_hub) %>%
  group_by(target_variable) %>%
  summarise(n = n(), # n = 32 countries for each target
            p_ensemble_beat_loc = sum(rel_wis <= 1, na.rm = TRUE) / n * 100)
p_ensemble_beat_loc <- map(split(n_ensemble_loc, n_ensemble_loc$target_variable),
                           ~ .x %>% pull(p_ensemble_beat_loc) %>% round(0))

# best individual model performance
n_model_loc <- scores_model %>%
  filter(!is_hub) %>%
  group_by(model, target_variable) %>%
  summarise(n = n(), # n = 32 countries for each target
            p_model_beat_loc = sum(rel_wis <= 1, na.rm = TRUE) / n * 100,
            .groups = "drop") %>%
  filter(n == unique(n_ensemble_loc$n)) %>%
  arrange(desc(p_model_beat_loc)) %>%
  group_by(target_variable) %>%
  slice_max(p_model_beat_loc, n = 1)

p_model_beat_loc <- map(split(n_model_loc, n_model_loc$target_variable),
                        ~ .x %>%
                          mutate(p_model_beat_loc = round(p_model_beat_loc, 0)))
