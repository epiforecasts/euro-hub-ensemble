# Supplementary information
library(here)
library(dplyr)
library(ggplot2)
library(patchwork)
theme_set(theme_bw())

# Get summary data to make plots
source(here("code", "summarise", "data.R"))

# SI figure 1: heatmap of participation across targets -----------------------
si_figure_1 <- models_per_target %>%
  mutate(target_variable = paste0("Incident ", target_variable)) %>%
  ggplot(aes(x = horizon, y = location_name, fill = n_scores)) +
  geom_tile() +
  scale_fill_viridis_c(direction = -1, breaks = c(100, 300, 500)) +
  labs(x = "Horizon", y = NULL, fill = "Number of forecasts") +
  facet_wrap("target_variable") +
  theme(legend.position = "bottom")

si_fig1_legend <- "Figure SI1. Total number of forecasts included in evaluation, by target location, week ahead horizon, and variable"

# ggsave("output/figures/si-figure-1.png", plot = si_figure_1,
#        height = 7, width = 5)

# SI figure 2: Distribution of non-hub model scores --------------
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

si_figure_2 <- si_fig2a +
  si_fig2b +
  plot_layout(nrow = 1) +
  plot_annotation(
    caption = paste("N =", modeller_scores$n_rel_wis - modeller_scores$score_3, "excluding", modeller_scores$score_3, "scores with scaled relative WIS > 3"))

si_fig2_legend <- "Figure SI2. Comparison of scores between participating model forecasts \n and Hub ensemble of all available forecasts for each target"

# ggsave("output/figures/si-figure-2.png", plot = si_figure_2,
#        height = 3, width = 7)
