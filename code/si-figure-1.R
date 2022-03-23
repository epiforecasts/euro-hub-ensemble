# Plot number of forecasts creating the evaluating scores
library(ggplot2)

source(here("code", "data-summary"))

scores_per_target <- models_per_target %>%
  ggplot(aes(x = horizon, y = location_name, fill = n_scores)) +
  geom_tile() +
  scale_fill_viridis_c(direction = -1) +
  labs(x = "Horizon", y = NULL, fill = "Number of forecasts",
       subtitle = "Total number of forecasts included in evaluation, \n by target location, week ahead horizon, and variable") +
  facet_wrap("target_variable") +
  theme(legend.position = "bottom")

ggsave("output/figures/si-figure-1-scores.png",
       plot = scores_per_target, height = 5, width = 5)
