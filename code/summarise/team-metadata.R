# Supplementary information: team metadata
library(here)
library(dplyr)
library(ggplot2)
library(patchwork)
library(yaml)
library(purrr)
library(fs)
source(here("code", "load", "evaluation-scores.R"))

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
         grepl("metadata/", .x$path)) %>%
  map_chr(~ glue::glue(
    paste0("https://raw.githubusercontent.com/{github_repo}/",
           "{branch}/{.x$path}")
  )) %>%
  set_names() %>%
  map(read_yaml) %>%
  imap_dfr(~ list(
    Team = .x$team_name,
    Model = .x$model_abbr,
    Authors = glue::glue_collapse(purrr::map(.x$model_contributors, "name"), sep = ", "),
    Methods = .x$methods,
    Website = .x$website_url,
    Metadata = .y,
    team_model_designation = .x$team_model_designation)) %>%
  filter(Model %in% scores_model$model &
           !grepl("other", team_model_designation)) %>%
  arrange(tolower(Model)) %>%
  select(-team_model_designation)

# Replace a team name on their request
team_df <- team_df |>
  mutate(Team = gsub("UNIPG_UNIMIB_USI_UNINSUBRIA",
                     "University of Perugia / University of Milano-Bicocca / Università della Svizzera Italiana",
                     Team))

readr::write_excel_csv(team_df, here("output", "metadata", "team-metadata.csv"))
