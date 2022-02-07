# Get author emails
library(here)
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
  select(model, a1)


writeLines(unique(emails$a1), sep = "; ")

# find metadata with no emails
emails_find <- metadata %>%
  filter(model %in% filter(emails, is.na(a1))$model) %>%
  select(model, model_contributors) %>%
  separate(model_contributors, into = c("first", "other"), sep = ",",
           remove = FALSE, extra = "merge")


# MIMUW-StochSEIR = k.gogolewski@mimuw.edu.pl
# MIT_CovidAnalytics-DELPHI = mlli@mit.edu
# MOCOS-agent1 = bodychmarcin@gmail.com
# MUNI_DMS-SEIAR = hajnova@math.muni.cz
# bisop-seirfilter = m@martinsmid.cz

