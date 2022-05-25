# Author list
library(here)
library(dplyr)
library(stringr)
library(tidyr)

library(googlesheets4)
gs4_deauth()
authors <- read_sheet("https://docs.google.com/spreadsheets/d/19hS7r7y126J3BPBhJa20rHApFu3Hx1DQEWe7av7fX68/edit#gid=1316950565",
                      sheet = "medrxiv-template")
names(authors) <- tolower(names(authors))
names(authors) <- gsub(" ", "", names(authors))

author_list <- authors %>%
  mutate(
    init_1 = substr(firstname, 1, 1),
    init_2 = substr(`middlename(s)/initial(s)`, 1, 1),
    init_first = ifelse(!is.na(`middlename(s)/initial(s)`),
                        paste0(init_1, init_2),
                        init_1),
    author_name = paste0(lastname, ", ", init_first, "."))

authors <- paste(author_list$author_name, collapse = ", ")
writeLines(authors, con = here::here("output", "authors.txt"))


# checks ------------------------------------------------------------------
author_model <- read_sheet("https://docs.google.com/spreadsheets/d/19hS7r7y126J3BPBhJa20rHApFu3Hx1DQEWe7av7fX68/",
                      sheet = "Authorship details") %>%
  janitor::clean_names()

authors_with_info <- author_model %>%
  filter(type == "model") %>%
  distinct(abbreviated_team_name) %>%
  mutate(info = TRUE)

# source(here("code", "load", "ensemble-criteria.R"))
models <- ensemble_criteria %>%
  filter(!target_variable == "inc hosp" &
           included_in_ensemble) %>%
  group_by(model) %>%
  tally() %>%
  left_join(authors_with_info, by = c("model" = "abbreviated_team_name"))
