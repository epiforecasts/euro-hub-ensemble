# Boxplot: spread of each model's relative performance

# Set up ------------------------------------------------------------------
subproj_dir <- "research/intro-paper"
here::i_am(paste0(subproj_dir, "/R/model-relative-score.R"))
# packages
library(dplyr)
library(forcats)
library(ggplot2)
# latest evaluation scores
source(here::here(subproj_dir, "R", "get-model-eval.R"))

# Organise plot data ------------------------------------------------------
rel_score <- model_eval %>%
  filter(
    # only 2 week horizon
    horizon == 2 & 
      # Individual country scores
      !location %in% "Overall" & 
      # Remove baseline
      !grepl("baseline", model)) %>%
  group_by(target_variable, model, horizon) %>%
  mutate(n_locs = length(unique(location))) %>%
  ungroup() %>%
  mutate(rel_wis_point = ifelse(n_locs == 1, rel_wis, NA),
         rel_wis_multi = ifelse(n_locs > 1, rel_wis, NA)) %>%
  group_by(model) %>%
  mutate(rel_wis_na = sum(is.na(rel_wis)),
         rel_wis_n = n()) %>%
  ungroup() %>%
  mutate(hub = grepl("hub-ensemble", model)) %>% 
  filter(rel_wis_na < rel_wis_n)

# Average relative WIS ------------------------------------------
rwis_plot <- rel_score %>%
  mutate(horizon = factor(horizon, ordered = TRUE)) %>%
  ggplot(aes(y = model, 
             colour = target_variable,
             fill = target_variable)) +
  geom_boxplot(aes(x = rel_wis_multi),
               alpha = 0.8,
               outlier.shape = NA) +
  geom_jitter(aes(x = rel_wis_multi),
              alpha = 0.2) +
  geom_point(aes(x = rel_wis_point), alpha = 0.9,
             position = position_dodge(width = 0.1)) +
  xlim(c(0, 3)) +
  geom_vline(aes(xintercept = 1), lty = 2) +
  geom_hline(aes(yintercept = "EuroCOVIDhub-ensemble"), 
             lty = 2, alpha = 0.4) +
  labs(y = NULL, x = "Scaled relative WIS across locations",
       caption = paste("Showing performance at 2 week horizon", 
                       fig_date, sep = "\n")) +
  scale_fill_brewer(palette = "Set1") +
  scale_colour_brewer(palette = "Set1") +
  coord_flip() +
  facet_grid(rows = vars(target_variable), 
             scales = "free") +
  theme_bw() +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 30, hjust = 1),
        plot.margin = unit(x = c(0.2,0.2,0.2,2), units = "cm"))
        
rwis_plot

ggsave(filename = paste0(subproj_dir, "/figures/", "model-relative-wis.png"),
       height = 5, width = 9,
       plot = rwis_plot)

# 
# # Rel AE ------------------------------------------------------------------
# rae_plot <- rel_score %>%
#   mutate(horizon = factor(horizon, ordered = TRUE)) %>%
#   ggplot(aes(y = model, 
#              colour = horizon,
#              fill = horizon)) +
#   geom_boxplot(aes(x = rel_ae_multi),
#                alpha = 0.8,
#                outlier.shape = NA) +
#   geom_jitter(aes(x = rel_ae_multi),
#               alpha = 0.2) +
#   geom_point(aes(x = rel_ae_point), alpha = 0.9,
#              position = position_dodge(width = 0.1)) +
#   xlim(c(0, 3)) +
#   geom_vline(aes(xintercept = 1), lty = 2) +
#   labs(y = NULL, x = "Scaled relative AE per location",
#        colour = "Weeks ahead", fill = "Weeks ahead") +
#   scale_fill_brewer(palette = "Set1") +
#   scale_colour_brewer(palette = "Set1") +
#   coord_flip() +
#   facet_grid(rows = vars(target_variable), scales = "free_x") +
#   theme_bw() +
#   theme(legend.position = "bottom",
#         legend.justification = "right",
#         axis.text.x = element_text(angle = 30, hjust = 1),
#         plot.margin = unit(x = c(0.2,0.2,0.2,2), units = "cm"))
# 
# ggsave(filename = paste0(file_path, "/figures/", "model-relative-ae.png"),
#        height = 5, width = 9,
#        plot = rae_plot)
# 
# ###
# rae_n_pairs_cases <- sum(rae$target_variable == "Cases")
# rae_n_pairs_deaths <- sum(rae$target_variable == "Deaths")
# rae_n_outliers <- nrow(filter(rae, rel_ae > 3))
# 
# 
# # Rel AE description ------------------------------------------------------
# # by model
# rae_summary <- rae %>%
#   group_by(model, target_variable, horizon) %>%
#   summarise(mean_scale_score = mean(rel_ae, na.rm = TRUE),
#             outperform = sum(rel_ae < 1, na.rm = TRUE),
#             underperform = sum(rel_ae >= 1, na.rm = TRUE),
#             n_locations = n(),
#             out_p = round(outperform / n_locations, 2),
#             under_p = round(underperform / n_locations, 2),
#             min_scaled_score = min(rel_ae, na.rm = TRUE),
#             max_scaled_score = max(rel_ae, na.rm = TRUE),
#             scaled_range = max_scaled_score - min_scaled_score)
#   
# # by location
# rae_summary_location <- rae %>%
#   group_by(location, target_variable, horizon) %>%
#   summarise(mean_scale_score = mean(rel_ae, na.rm = TRUE),
#             outperform = sum(rel_ae < 1, na.rm = TRUE),
#             underperform = sum(rel_ae >= 1, na.rm = TRUE),
#             n_locations = n(),
#             out_p = round(outperform / n_locations, 2),
#             under_p = round(underperform / n_locations, 2),
#             min_scaled_score = min(rel_ae, na.rm = TRUE),
#             max_scaled_score = max(rel_ae, na.rm = TRUE),
#             scaled_range = max_scaled_score - min_scaled_score)
# 
