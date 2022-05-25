# Get ensemble metadata
library(dplyr)
library(readr)
library(purrr)

start_date <- as.Date("2021-03-08")
end_date <- as.Date("2022-03-07")
ensemble_dates <- seq.Date(from = start_date, to = end_date, by = 7)

get_ensemble_criteria <- function(ensemble_date) {
  path <- paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/code/ensemble/EuroCOVIDhub/criteria/criteria-", ensemble_date, ".csv")
  read_csv(path, progress = FALSE, show_col_types = FALSE) %>%
    mutate(ensemble_date = ensemble_date)
}

ensemble_criteria <- map_dfr(ensemble_dates, get_ensemble_criteria)

# included <- ensemble_criteria %>%
#   filter(!target_variable == "inc hosp" &
#            included_in_ensemble) %>%
#   group_by(ensemble_date, location, target_variable) %>%
#   tally()

