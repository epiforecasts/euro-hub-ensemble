# Supplementary information
library(here)
library(dplyr)
library(ggplot2)
library(patchwork)
library(yaml)
library(purrr)
library(fs)
library(knitr)
library(kableExtra)
theme_set(theme_bw())

# Get summary data to make plots
source(here("code", "summarise", "data.R"))

# Figure 1: heatmap of participation across targets -----------------------
figure_scores_by_target <- models_per_target %>%
  mutate(target_variable = paste0("Incident ", target_variable)) %>%
  ggplot(aes(x = horizon, y = location_name, fill = n_scores)) +
  geom_tile() +
  scale_fill_viridis_c(direction = -1, breaks = c(100, 300, 500)) +
  labs(x = "Horizon", y = NULL, fill = "Number of forecast scores") +
  facet_wrap("target_variable") +
  theme(legend.position = "bottom",
        strip.background = element_blank())

figure_scores_by_target_cap <- "Total number of forecasts included in evaluation, by target location, week ahead horizon, and variable"

ggsave(here("output", "figures", "figure-scores-by-target.png"),
       width = 4, height = 6)
