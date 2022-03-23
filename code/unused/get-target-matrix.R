# Identify all possible targets
library(dplyr)
library(EuroForecastHub)
here::i_am("code/get-target-matrix.R")

if (!exists("eval_date")) {eval_date <- as.Date("2022-03-07")}

# Get evaluation scores if not already present
if (!exists("scores_model")) {source(here("code", "load-evaluation-scores.R"))}

# Set report dates
start_date <- eval_date - weeks(max(scores_model$n))
locations <- unique(scores_model$location)

# Matrix of all possible targets
target_matrix <- tibble("date" = seq.Date(from = start_date,
                                          to = eval_date,
                                          by = "week")) %>%
  left_join(tibble("target_variable" = c("inc case", "inc death")),
            by = character()) %>%
  left_join(tibble("location" = locations),
            by = character())
