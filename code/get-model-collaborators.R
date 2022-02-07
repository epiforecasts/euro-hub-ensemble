# Get author emails
library(dplyr)
library(tidyr)
library(stringr)

# Get metadata for models used in paper
source(here("code", "get-model-eval.R"))
models <- as.character(unique(model_eval$model))
metadata <- covidHubUtils::get_model_metadata(hub_repo_path = "C:/Users/kaths/GitHub/covid19-forecast-hub-europe") %>%
  filter(model %in% models)

# get emails between <#> tags
emails <- select(metadata, model, model_contributors) %>%
  separate(model_contributors, into = paste0("a", 0:10), sep = "<") %>%
  mutate(across(a0:a10, str_extract, "(.+)\\>"),
         across(a0:a10, str_remove_all, "\\>")) %>%
  select(-a0) %>%
  pivot_longer(a1:a10, names_to = "order", values_to = "email",
               values_drop_na = TRUE) %>%
  # de-duplicate
  group_by(email) %>%
  summarise(n_models = n())

writeLines(emails$email, sep = "; ")
