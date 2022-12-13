# Citations
library(here)
library(yaml)
library(purrr)
github_repo <- "epiforecasts/covid19-forecast-hub-europe"
branch <- "metadata-citations"
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
  map(read_yaml)

citation <- team_df |>
  imap_dfr(~ list(
    model_abbr = .x$model_abbr,
    link = purrr::map(.x$citation, "link"),
    doi = purrr::map(.x$citation, "DOI")))
