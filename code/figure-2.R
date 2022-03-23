# Create figure 2
library(dplyr)
library(ggplot2)
theme_set(theme_bw())

# PLOT: All model and ensemble performance by boxplot by location at 2 wk horizon
figure_2 <- scores_model %>%
  # Use 2 week horizon
  filter(horizon == 2) %>%
  mutate(rel_wis = ifelse(rel_wis == 0, NA, rel_wis)) %>%
  # plot structure: boxplot rel wis by location and horizon
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

ggsave(filename = here("output", "figures", "figure-2.png"), plot = figure_2)
