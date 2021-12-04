subproj_dir <- "research/intro-paper"
here::i_am(paste0(subproj_dir, "/R/ensemble-over-time.R"))

library(here)
library(readr)
library(dplyr)
library(tidyr)

# Get latest evaluation dataset ------------------------------------------------
eval_dates <- dir(here("covid19-forecast-hub-europe", "ensembles", 
                      "evaluation", "weekly-summary"))
eval_dates <- as.Date(gsub("(evaluation-)|(\\.csv)", "", eval_dates))
eval_file <- here("covid19-forecast-hub-europe", "ensembles", 
                  "evaluation", "weekly-summary", paste0("evaluation-", eval_dates, ".csv"))
names(eval_dates) <- eval_file

# Prep dataset ------------------------------------------------------------
# neater factor labels
clean_target_names <- c("inc case" = "Cases", "inc death" = "Deaths")
main_ensembles_names <- c(
  "mean" = "Unweighted mean",
  "All_relative_skill_weighted_mean" = "Weighted mean",
  "median" = "Unweighted median",
  "All_relative_skill_weighted_median" = "Weighted median"
)

# Tidy up
eval_ensemble <- read_csv(eval_file, id = "eval_date") %>%
  mutate(eval_date = as.Date(recode(eval_date, !!!eval_dates))) %>%
  # keep only 1-4 horizons
  filter(horizon <= 4) %>%
  # clean up team-model names
  separate(model, into = c("team_name", "model"), 
           sep = "-", remove = FALSE) %>%  
  mutate(
    target_variable = recode(target_variable, !!!clean_target_names),
    method_average = case_when(grepl("mean", model) ~ "Mean",
                               grepl("median", model) ~ "Median"),
    method_weight = case_when(grepl("weighted", model) ~ "Weighted",
                              TRUE ~ "Unweighted"),
    method_history = case_when(grepl("[0-9]+", model) ~
                                 paste(suppressWarnings(
                                   parse_number(gsub("-", "", model))),
                                   "weeks history"),
                               TRUE ~ "All history"),
    method_cutoff = case_when(grepl("cutoff", model) ~ "Cutoff rel. WIS < 1",
                              TRUE ~ "No cutoff"),
    ensemble_name = recode(model, !!!main_ensembles_names),
    main_ensemble = model %in% names(main_ensembles_names),
    # ensure scores are numeric
    across(c(horizon, rel_ae:n_loc), as.numeric),
    # set horizon as ordered factor
    horizon = factor(horizon, ordered = TRUE)) %>%
  select(eval_date,
         model, ensemble_name, main_ensemble,
         starts_with("method_"), weeks_included,
         location, location_name, target_variable, horizon,
         n, rel_wis, cov_50, cov_95) %>%
  filter(!location %in% "Overall" &
           !grepl("baseline|horizon", model) &
           target_variable %in% clean_target_names)

main_ensembles <- eval_ensemble %>%
  filter(main_ensemble &
           weeks_included == "All")


rm(eval_file, clean_target_names, main_ensembles_names, eval_dates)


# Plot over time ----------------------------------------------------------
main_ensembles %>%
  filter(horizon == 2 & !is.infinite(rel_wis)) %>%
  ggplot(aes(x = eval_date, y = rel_wis,
             colour = target_variable,
             fill = target_variable,
             groups = location)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.1) +
  geom_hline(aes(yintercept = 1), lty = 2) +
  labs(y = "Relative WIS by location", x = NULL,
       caption = "Showing performance at 2 week horizon") +
  scale_fill_brewer(palette = "Set1") +
  scale_colour_brewer(palette = "Set1") +
  facet_grid(vars(target_variable), vars(ensemble_name),
             scales = "free") +
  theme_bw() +
  theme(legend.position = "none")

ggsave(here(subproj_dir, "figures", "ensemble-time-method.png"),
       height = 5, width = 10)

       