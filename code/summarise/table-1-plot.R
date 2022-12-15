library(here); library(dplyr); library(ggplot2)
source(here("code", "load", "evaluation-scores.R"))
old <- scores_ensemble %>%
  filter(location == "Overall") %>%
  mutate(horizon = paste(horizon, if_else(horizon == 1, "week", "weeks"))) %>%
  select(model, target_variable, Horizon = horizon, rel_wis) %>%
  pivot_wider(names_from = "model", values_from = "rel_wis") %>%
  arrange(target_variable)
rm(scores_ensemble, scores_model)


tab <- bind_rows(old, new, .id = "type") |>
  mutate(type = ifelse(type == 1, "old_score", "new_score")) |>
  pivot_longer(cols = -c(type, target_variable, Horizon)) |>
  mutate(name = as.factor(name)) |>
  pivot_wider(names_from = type)

tab |>
  ggplot(aes(x = old_score, y = new_score,
             col = name)) +
  geom_point() +
  geom_abline() +
  facet_wrap(~target_variable) +
  theme_bw() +
  theme(legend.position = "bottom")

# -------------------------------------------------------------------------

comp <- new |>
  pivot_longer(cols = -c(target_variable, Horizon)) |>
  separate(name, into = c("weights", "average"), sep = " ") |>
  pivot_wider(names_from = weights) |>
  mutate(average = as.factor(average))

comp |>
  ggplot(aes(x = Unweighted, y = Weighted,
             col = average,
             shape = Horizon)) +
  geom_point() +
  geom_abline() +
  facet_wrap(~target_variable,
             scales = "free") +
  theme_bw() +
  theme(legend.position = "bottom")


