
models_ensemble_cols <- c("#9ebcda", "#8856a7")

# Ensemble performance in 32 locations plotted at each horizon
horizon <- model_eval %>%
  mutate(horizon = factor(horizon),
         Model = factor(is_hub, levels = c(FALSE, TRUE),
                        labels = c("All other models", "Hub ensemble")))

# Rel wis
rel_wis <- horizon %>%
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
rel_wis


# 50% coverage
cov_50 <- horizon %>%
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
  theme(strip.background = element_blank(),
        legend.position = "none",
        axis.text.x = element_blank())
cov_50


# 95% coverage
cov_95 <- horizon %>%
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
       col = NULL,
       caption = "Boxplot width proportional to observations;
       Yellow indicates target range") +
  facet_wrap(~ target_variable, ncol = 2) +
  scale_colour_manual(values = models_ensemble_cols) +
  theme(strip.background = element_blank(),
        legend.position = "bottom")
cov_95

horizon_plot <-
  rel_wis +
  cov_50 +
  cov_95 +
  plot_layout(ncol = 1)

ggsave(filename = here("output", "figures", "horizon.png"), plot = horizon_plot, width = 5, height = 7)

