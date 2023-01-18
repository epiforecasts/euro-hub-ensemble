# Create figure: models vs. ensemble by horizon
# Ensemble performance in 32 locations plotted at each horizon
library(dplyr)
library(ggplot2)
library(patchwork)

# Set up ------------------------------------------------------------------
# Get evaluation scores if not already present
if (!exists("scores_model")) {
  source(here("code", "load", "evaluation-scores.R"))
}

# plot settings
theme_set(theme_bw())
models_ensemble_cols <- c("#9ebcda", "#8856a7")

# Plot data --------------------------------------------------------------
fig_data_horizon <- scores_model %>%
  mutate(horizon = factor(horizon),
         Model = factor(is_hub, levels = c(FALSE, TRUE),
                        labels = c("All other models", "Hub ensemble")))

# some summary values for describing figure in text
fig_horizon_ensemble <- fig_data_horizon %>%
  filter(is_hub) %>%
  group_by(horizon, target_variable) %>%
  summarise(median_score = median(rel_wis, na.rm = TRUE)) %>%
  arrange(horizon) %>%
  split(.$target_variable)

# Plots -------------------------------------------------------------------
# Rel wis
rel_wis <- fig_data_horizon %>%
  ggplot(aes(y = rel_wis,
             x = horizon,
             col = Model)) +
  geom_boxplot(varwidth = TRUE, outlier.alpha = 0.2) +
  geom_hline(aes(yintercept = 1), lty = 2) +
  annotate("rect", alpha = 0.1, fill = "gold",
           xmin = -Inf, xmax = Inf,
           ymin = -Inf, ymax = 1) +
  coord_cartesian(ylim = c(0, 2)) +
  labs(y = "Scaled relative WIS",
       x = NULL, col = NULL) +
  scale_colour_manual(values = models_ensemble_cols) +
  facet_wrap(~ target_variable, ncol = 2) +
  theme(strip.background = element_blank(),
        legend.position = "none",
        axis.text.x = element_blank())

# 50% coverage
cov_50 <- fig_data_horizon %>%
  ggplot(aes(y = cov_50,
             x = horizon, col = Model)) +
  geom_boxplot(varwidth = TRUE, outlier.alpha = 0.2) +
  geom_hline(aes(yintercept = 0.5), lty = 2) +
  annotate("rect", alpha = 0.1, fill = "gold",
           xmin = -Inf, xmax = Inf,
           ymin = 0.45, ymax = 0.55) +
  coord_cartesian(ylim = c(0, 1)) +
  labs(y = "50% coverage",
       x = NULL, col = NULL) +
  facet_wrap(~ target_variable, ncol = 2) +
  scale_colour_manual(values = models_ensemble_cols) +
  theme(strip.text = element_blank(),
        strip.background = element_blank(),
        legend.position = "none",
        axis.text.x = element_blank())

# 95% coverage
cov_95 <- fig_data_horizon %>%
  ggplot(aes(y = cov_95,
             x = horizon, col = Model)) +
  geom_boxplot(varwidth = TRUE, outlier.alpha = 0.2) +
  geom_hline(aes(yintercept = 0.95), lty = 2) +
  annotate("rect", alpha = 0.1, fill = "gold",
           xmin = -Inf, xmax = Inf,
           ymin = 0.90, ymax = 1) +
  coord_cartesian(ylim = c(0, 1)) +
  labs(y = "95% coverage",
       x = "Weeks ahead horizon",
       col = NULL) +
  facet_wrap(~ target_variable, ncol = 2) +
  scale_colour_manual(values = models_ensemble_cols) +
  theme(strip.text = element_blank(),
        strip.background = element_blank(),
        legend.position = "bottom")


# Figure ------------------------------------------------------------------
figure_horizon <-
  rel_wis +
  cov_50 +
  cov_95 +
  plot_layout(ncol = 1)

ggsave(filename = here("output", "figures", "figure-2.png"),
       plot = figure_horizon, width = 5, height = 7)

# caption
figure_horizon_cap <- "_Performance of short-term forecasts aggregated across all individually submitted models and the Hub ensemble, by horizon, forecasting cases (left) and deaths (right). Performance measured by relative weighted interval score scaled against a baseline (dotted line, 1), and coverage of uncertainty at the 50% and 95% levels. Boxplot, with width proportional to number of observations, show interquartile ranges with outlying scores as faded points. The target range for each set of scores is shaded in yellow._"
