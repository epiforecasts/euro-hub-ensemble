# Identify all possible targets
library(dplyr)
library(EuroForecastHub)
here::i_am("code/get-target-matrix.R")

# Set report dates
if (!exists("eval_date")) {eval_date <- as.Date("2022-03-07")}
start_date <- as.Date(get_hub_config("launch_date",
                                     config_file = "https://raw.githubusercontent.com/epiforecasts/covid19-forecast-hub-europe/main/project-config.json"))

# Matrix of all possible targets
target_matrix <- tibble("date" = seq(start_date, eval_date, by = "week")) %>%
  left_join(tibble("target_variable" = c("inc case", "inc death")), by = character()) %>%
  left_join(tibble("location" = hub_locations_ecdc$location), by = character())
