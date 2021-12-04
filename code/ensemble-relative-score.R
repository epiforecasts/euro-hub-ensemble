subproj_dir <- "research/intro-paper"
here::i_am(paste0(subproj_dir, "/R/ensemble-relative-score.R"))

library(dplyr)
library(ggplot2)

# get eval
source(here::here(subproj_dir, "R", "get-ensemble-eval.R"))

# Average across time by horizon ------------------------------------------
# Boxplot: spread of each model's relative performance across locations
# facet wrap: allows free y axis on each plot
rwis_plot <- main_ensembles %>%
  ggplot(aes(y = ensemble_name, 
             colour = horizon,
             fill = horizon)) +
  geom_boxplot(aes(x = rel_wis),
               alpha = 0.8,
               outlier.alpha = 0.2,
               varwidth = TRUE
  ) +
  geom_vline(aes(xintercept = 1), lty = 2) +
  labs(y = NULL, x = "Scaled relative WIS per location",
       colour = "Weeks ahead", fill = "Weeks ahead",
       caption = fig_date) +
  scale_colour_viridis_d(direction = 1,
                         aesthetics = c("colour", "fill")) +
  coord_flip() +
  facet_wrap(facets = vars(target_variable, method_average),
             scales = "free", dir = "h",
             labeller = label_wrap_gen(multi_line = FALSE)) +
  theme_bw() +
  theme(legend.position = "bottom",
        legend.justification = "right",
        strip.background = element_blank())
# view
rwis_plot
#
# save
ggsave(filename = paste0(subproj_dir, "/figures/", "ensemble-relative-wis.png"),
       height = 4, width = 10,
       plot = rwis_plot)
