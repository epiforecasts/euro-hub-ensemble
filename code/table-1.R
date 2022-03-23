# Create table comparing weighted to unweighted mean and median ensembles
library(dplyr)
library(tidyr)
library(kableExtra)

ensemble_eval_table <- eval_ensemble %>%
  filter(location == "Overall") %>%
  mutate(horizon = paste(horizon, if_else(horizon == 1, "week", "weeks"))) %>%
  select(model, target_variable, Horizon = horizon, rel_wis) %>%
  pivot_wider(names_from = "model", values_from = "rel_wis") %>%
  arrange(target_variable) %>%
  select(-target_variable)

ensemble_eval_table <- ensemble_eval_table %>%
  kbl(booktabs = TRUE, caption = "Predictive performance of main ensembles, as measured by the scaled relative WIS.") %>%
  kable_styling(latex_options = "striped") %>%
  pack_rows(group_label = "Cases", start_row = 1, end_row = 4) %>%
  pack_rows(group_label = "Deaths", start_row = 5, end_row = 8)
