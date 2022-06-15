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

# SI figure 1: heatmap of participation across targets -----------------------
si_figure_1 <- models_per_target %>%
  mutate(target_variable = paste0("Incident ", target_variable)) %>%
  ggplot(aes(x = horizon, y = location_name, fill = n_scores)) +
  geom_tile() +
  scale_fill_viridis_c(direction = -1, breaks = c(100, 300, 500)) +
  labs(x = "Horizon", y = NULL, fill = "Number of forecasts") +
  facet_wrap("target_variable") +
  theme(legend.position = "bottom")

si_fig1_legend <- "Total number of forecasts included in evaluation, by target location, week ahead horizon, and variable"

# ggsave("output/figures/si-figure-1.png", plot = si_figure_1,
#        height = 7, width = 5)

# SI figure 2: Distribution of non-hub model scores ------------------------
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

si_fig2_legend <- "Comparison of scores between participating model forecasts \n and Hub ensemble of all available forecasts for each target"

# ggsave("output/figures/si-figure-2.png", plot = si_figure_2,
#        height = 3, width = 7)


# Participating teams -----------------------------------------------------

# Note: the below code written by Hugo Gruson and Seb Funk for the Hub website:
#  See https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe-website/blob/main/community.Rmd

github_repo <- "epiforecasts/covid19-forecast-hub-europe"
branch <- "main"

team_df <-
  gh::gh(
    paste0("https://api.github.com/repos/{github_repo}/",
           "git/trees/{branch}?recursive=1"),
    github_repo = github_repo, branch = branch
  ) %>%
  pluck("tree") %>%
  keep(~ .x$type == "blob" &&
         grepl("data-processed/(.*)/metadata-\\1", .x$path)) %>%
  map_chr(~ glue::glue(
    paste0("https://raw.githubusercontent.com/{github_repo}/",
           "{branch}/{.x$path}")
  )) %>%
  set_names() %>%
  imap_dfr(~ c(link = .y, read_yaml(.x))) %>%
  #
  filter(model_abbr %in% scores_model$model &
           team_model_designation != "other") %>%
  #
  select(link, model_abbr, team_name, website_url, methods) %>%
  mutate(
    md_link = glue::glue("[Metadata]({link})"),
    model_abbr = glue::glue("[{model_abbr}]({website_url})"),
    .keep = "unused"
  ) %>%
  arrange(tolower(model_abbr))

team_table <- team_df  %>%
  relocate(
    "Model name" = model_abbr,
    "Affiliation" = team_name,
    "Methods" = methods,
    "Complete metadata" = md_link
  ) %>%
  kable(format = "markdown", caption = "Teams participating in the European Forecast Hub contributing a model between March 2021 - March 2022") %>%
  kable_styling(latex_options = "striped")
