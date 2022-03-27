# Create figure 2: performance by location
#  All model and ensemble performance as boxplot at 2 wk horizon
library(dplyr)
library(ggplot2)
theme_set(theme_bw())

# Set up ------------------------------------------------------------------
# Get evaluation scores if not already present
if (!exists("scores_model")) {source(here("code", "load", "evaluation-scores.R"))}

#  Summarise by location -------------------------------------------------
ensemble_performance_by_location <- function(scores_model) {

  data <- scores_model %>%
    mutate(rel_wis = ifelse(rel_wis == 0, NA, rel_wis))

  # at each wk horizon, for each location, what % model did the ensemble outperform?
  location_performance <- data %>%
    filter(!is_hub) %>%
    group_by(location, target_variable) %>%
    summarise(
      n_models = n(),
      n_rel_wis = sum(!is.na(rel_wis)),
      ensemble_beat = sum(ensemble_rel_wis <= rel_wis, na.rm=TRUE),
      ensemble_beat_p = ensemble_beat / n_rel_wis * 100,
      ensemble_score = min(ensemble_rel_wis),
      median_score = median(rel_wis, na.rm = TRUE))

  # for how many locations did the ensemble outperform x% models?
  ensemble_models <- location_performance %>%
    group_by(target_variable) %>%
    summarise(beat_50 = sum(ensemble_beat_p >= 50),
              beat_75 = sum(ensemble_beat_p >= 75),
              beat_100 = sum(ensemble_beat_p >= 100))

  plot_location <- data %>%
    ggplot(aes(x = location_name, y = rel_wis,
               colour = target_variable,
               fill = target_variable)) +
    geom_boxplot(alpha = 0.8,
                 outlier.alpha = 0.2) +
    geom_hline(aes(yintercept = 1), lty = 2) +
    # overlay ensemble as extra point
    geom_point(aes(y = ensemble_rel_wis),
               size = 2, shape = "asterisk",
               colour = "grey 10",
               position = position_dodge(width = 0.8)) +
    # format
    ylim(c(0,4)) +
    labs(x = NULL, y = "Scaled relative WIS across models") +
    scale_fill_brewer(palette = "Set1") +
    scale_colour_brewer(palette = "Set1") +
    facet_wrap(~ target_variable, scales = "fixed", nrow = 2) +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 30, hjust = 1),
          strip.background = element_blank())

  return(list("location_performance" = location_performance,
              "ensemble_models" = ensemble_models,
              "plot_location" = plot_location,
              "data" = data))
}

# 2 week horizon (text) ---------------------------------------------------
fig2_base <- ensemble_performance_by_location(scores_model %>%
                                                filter(horizon == 2))
fig2_summary <- fig2_base$ensemble_models %>%
  mutate(across(starts_with("beat_"),
                ~ gsub(32, "all", .))) %>%
  split(.$target_variable)

figure_2 <- fig2_base$plot_location
ggsave(filename = here("output", "figures", "figure-2.png"), plot = figure_2)

fig2_cap <- "_Performance of short-term forecasts across models and
median ensemble (asterisk), by country, forecasting cases (top) and deaths (bottom) for two-week ahead forecasts, according to the relative weighted interval score. Boxplots show interquartile ranges, with outliers as faded points, and the ensemble model performance is marked by an asterisk. y-axis is cut-off to an upper bound of 4 for readability._"

# Repeat for all horizons -----------------------------------------------
h1234_base <- ensemble_performance_by_location(scores_model)
h1234_summary <- h1234_base$ensemble_models %>%
  mutate(across(starts_with("beat_"),
                ~ gsub(32, "all", .))) %>%
  split(.$target_variable)
