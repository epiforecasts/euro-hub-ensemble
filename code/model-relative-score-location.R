# Plot scores averaged by location
# Set up ------------------------------------------------------------------
subproj_dir <- "research/intro-paper"
here::i_am(paste0(subproj_dir, "/R/model-relative-score-location.R"))
library(forcats)
library(ggplot2)

# Get latest evaluation scores
source(here(subproj_dir, "R", "get-model-eval.R"))

# All model relative WIS scores by location -----------------------------------
location_rwis <- model_eval_wide %>%
  # Use 1 week horizon
  filter(horizon == 2 &
           location != "Overall" &
           !grepl("hub-ensemble", model)) %>%
  # plot structure: boxplot rel wis by location and horizon
  ggplot(aes(x = location_name, y = rel_wis,
             colour = target_variable,
             fill = target_variable)) +
  geom_boxplot(alpha = 0.8, 
               outlier.alpha = 0.2) +
  geom_hline(aes(yintercept = 1), lty = 2) +
  # add ensemble as extra point
  geom_point(aes(y = ensemble_rel_wis),
              size = 2, shape = "asterisk",
             colour = "grey 10",
             position = position_dodge(width = 0.8)) +
  # format
  ylim(c(0,4)) +
  labs(x = NULL, y = "Scaled relative WIS across models",
       caption = paste("Showing performance at 2 week horizon", 
                       fig_date, sep = "\n")) +
  scale_fill_brewer(palette = "Set1") +
  scale_colour_brewer(palette = "Set1") +
  facet_grid(rows = vars(target_variable), scales = "free") +
  theme_bw() +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 30, hjust = 1))

location_rwis

ggsave(filename = paste0(subproj_dir, "/figures/", 
                         "model-location-relative-wis.ong"),
       height = 5, width = 9,
       plot = location_rwis)

# Relative WIS by country and horizon, showing boxplot of model scores,
# ensemble (asterisk), and outliers (faded), relative to baseline (1, dashed line),
# y-axis limited to exclude outliers > 4 x baseline

