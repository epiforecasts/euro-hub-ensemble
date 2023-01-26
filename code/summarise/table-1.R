# Create table comparing weighted to unweighted mean and median ensembles
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
library(kableExtra)

scores_ensemble <- read_csv("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/assess-ensembles-update/ensembles/evaluation/weekly-summary/evaluation-2022-03-07.csv")

scores_ensemble <- scores_ensemble |>
  filter(model != "EuroCOVIDhub-baseline" &
           compare_against == "EuroCOVIDhub-baseline" &
           location == "Overall") |>
  mutate(model = sub("EuroCOVIDhub-All_relative_skill_weighted_", "Weighted ", model),
         model = sub("EuroCOVIDhub-", "Unweighted ", model)
  )

ensemble_eval_table <- scores_ensemble |>
  arrange(horizon) |>
  mutate(horizon = paste(horizon, if_else(horizon == 1, "week", "weeks"))) |>
  select(model, target_variable, Horizon = horizon, mean_scores_ratio) |>
  pivot_wider(names_from = "model", values_from = "mean_scores_ratio") |>
  arrange(target_variable) %>%
  select(-target_variable)

ensemble_eval_table <- ensemble_eval_table %>%
  kbl(booktabs = TRUE, caption = "Predictive performance of main ensembles, as measured by the mean ratio of interval scores against the baseline ensemble.") %>%
  kable_styling(latex_options = "striped") %>%
  pack_rows(group_label = "Cases", start_row = 1, end_row = 4) %>%
  pack_rows(group_label = "Deaths", start_row = 5, end_row = 8)

# -------------------------------------------------------------------------

# library(ggplot2)
# plot <- scores_ensemble |>
#   mutate(horizon = fct_inseq(as.character(horizon))) |>
#   select(model, target_variable, horizon, mean_scores_ratio) |>
#   separate(model, into = c("Weight", "Method"), sep = " ", remove = FALSE)
#
# plot |>
#   ggplot(aes(x = Method, col = Weight, shape = horizon)) +
#   geom_point(aes(y = mean_scores_ratio)) +
#   facet_wrap(~ target_variable)


