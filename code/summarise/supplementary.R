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

# Participating teams -----------------------------------------------------

# Note: the below code written by Hugo Gruson and Seb Funk for the Hub website:
#  See https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe-website/blob/main/community.Rmd

github_repo <- "epiforecasts/covid19-forecast-hub-europe"
branch <- "main"


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
    link = .y,
    authors = glue::glue_collapse(purrr::map(.x$model_contributors, "name"), sep = ", "),
    model_abbr = .x$model_abbr,
    website_url = .x$website_url,
    team_name = .x$team_name,
    methods = .x$methods,
    team_model_designation = .x$team_model_designation)) %>%
  filter(model_abbr %in% scores_model$model &
           !grepl("other", team_model_designation)) %>%
  arrange(tolower(model_abbr)) %>%
  mutate(
    team_name = glue::glue("[{team_name}]({website_url})"),
    metadata = glue::glue("[{model_abbr}]({link})")) %>%
  select(authors, team_name, methods, metadata)

team_table <- team_df  %>%
  relocate(
    "Team" = team_name,
    "Authors" = authors,
    "Methods" = methods,
    "Metadata" =metadata
  )

# Replace a team name on their request
team_table <- team_table |>
  mutate(Team = gsub("UNIPG_UNIMIB_USI_UNINSUBRIA",
                     "University of Perugia / University of Milano-Bicocca / Università della Svizzera Italiana",
                     Team))
