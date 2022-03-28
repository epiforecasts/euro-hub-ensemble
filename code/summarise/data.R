# Create values to summarise data in text
#   and figures for supplementary information (SI)
library(dplyr)
library(lubridate)
library(ggplot2)
library(patchwork)

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

# SI figure 1: heatmap of participation across targets -----------------------
"si_fig1" = models_per_target %>%
  ggplot(aes(x = horizon, y = location_name, fill = n_scores)) +
  geom_tile() +
  scale_fill_viridis_c(direction = -1) +
  labs(x = "Horizon", y = NULL, fill = "Number of forecasts",
       subtitle = "Total number of forecasts included in evaluation, \n by target location, week ahead horizon, and variable") +
  facet_wrap("target_variable") +
  theme(legend.position = "bottom")

# ggsave("output/figures/si-figure-1.png", height = 5, width = 5)

# SI fig 2 ----------------------------------------------------------------
# Distribution of non-hub model scores
si_fig2a <- scores_model_exhub %>%
  filter(rel_wis <= 3) %>%
  ggplot(aes(x = rel_wis)) +
  geom_histogram(binwidth = 0.1) +
  geom_vline(aes(xintercept = 1), lty = 2) +
  labs(x = "Scaled relative WIS", y = "Frequency",
       subtitle = "(a) Contributed forecasts")

# Distance between model score and ensemble score
si_fig2b <- scores_model_exhub %>%
  filter(rel_wis <= 3) %>%
  ggplot(aes(x = rel_wis_distance)) +
  geom_histogram(binwidth = 0.1) + # 10% difference from ensemble score
  geom_vline(aes(xintercept = 0), lty = 2) +
  labs(x = "Difference from ensemble",
       y = NULL,
       subtitle = "(b) Contributed forecasts \n compared to the Hub ensemble model")

si_figure_2 <- si_fig2a + si_fig2b + plot_layout(nrow = 1) +
  plot_annotation(
    subtitle = "Comparison of scores between participating model forecasts \n and Hub ensemble of all available forecasts for each target",
    caption = paste("N =", modeller_scores$n_rel_wis - modeller_scores$score_3, "excluding", modeller_scores$score_3, "scores with scaled relative WIS > 3"))

# ggsave("output/figures/si-figure-2.png", height = 3, width = 7)
