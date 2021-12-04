subproj_dir <- "research/intro-paper"
here::i_am(paste0(subproj_dir, "/R/ensemble-comparison.R"))

library(readr)
library(dplyr)
library(ggplot2)
library(here)
library(forcats)
library(tidyr)

# get eval
source(here::here(subproj_dir, "R", "get-ensemble-eval.R"))

reference <- c(method_cutoff = "No cutoff",
               method_average = "Mean",
               method_weight = "Unweighted",
               method_history = "All history")

plots <- as.list(reference)

# flavour comparison ------------------------------------------------------
plot_base <- eval_ensemble %>%
  filter(location != "Overall" & 
           horizon == 2 &
           weeks_included == "All" &
           !is.infinite(rel_wis)) %>%
  mutate(model = factor(model),
         model = forcats::fct_rev(model))

tests <- names(eval_ensemble)[grepl("method_", names(eval_ensemble))]

differences <- list()

for (test in tests) {
  plot_table <- plot_base %>%
    select_at(c("target_variable", "horizon", "location_name",
                setdiff(tests, test), test, "rel_wis")) %>%
    unite("matches", 2:(ncol(.)-2)) %>%
    pivot_wider(names_from = all_of(test), values_from = "rel_wis") %>%
    pivot_longer(3:ncol(.)) %>%
    group_by(target_variable, matches) %>%
    mutate(all_there = all(!is.na(value))) %>%
    ungroup() %>%
    filter(all_there) %>%
    select(-all_there)
  
  plots[[test]] <- ggplot(plot_table, aes(x = name, y = value)) +
    geom_line(aes(group = matches), alpha = 0.25) +
    geom_point(aes(colour = name)) +
    scale_colour_brewer(palette = "Set1") +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(x = NULL, y = NULL) +
    theme_minimal() +
    theme(legend.position = "none") +
    facet_wrap(~ target_variable, scales = "free") +
    coord_flip()
  
  ptw <- plot_table %>%
    pivot_wider() %>%
    mutate(across(.cols = c(3,4), as.numeric))
  alternative_columns <- setdiff(colnames(ptw), 
                                 c("target_variable", "matches", reference[[test]]))
  
  for (column in alternative_columns) {
    raw_differences <- ptw[[column]] - ptw[[reference[[test]]]]
    raw_differences <- raw_differences[is.finite(raw_differences)]
    differences[[column]] <- tibble(mean = round(mean(raw_differences), 2),
                                    median = round(median(raw_differences), 2),
                                    low_48 = round(quantile(raw_differences, 0.26), 2),
                                    high_48 = round(quantile(raw_differences, 0.74), 2),
                                    low_96 = round(quantile(raw_differences, 0.02), 2),
                                    high_96 = round(quantile(raw_differences, 0.98), 2))
  }
}

dtb <- bind_rows(differences, .id = "change")

# plot differences summary
plot_diffs <- ggplot(dtb, aes(x = change)) +
  geom_point(aes(y = mean), pch = 2, size = 4) +
  geom_linerange(aes(ymin = low_48, ymax = high_48), lwd = 2) +
  geom_linerange(aes(ymin = low_96, ymax = high_96), lwd = 1) +
  labs(x = NULL,
       y = "Change in relative WIS",
       caption = fig_date) +
  theme_minimal() +
  coord_flip() +
  geom_hline(yintercept = 0, linetype = "dashed")

# save
ggsave(filename = paste0(subproj_dir, "/figures/", "ensemble-comparison-summary.png"),
       height = 4, width = 4,
       plot = plot_diffs)


# plot differences as connected lines
plot_diff_line <- 
  plots$method_weight +
  plots$method_average +
  plots$method_cutoff +
  plots$method_history +
  patchwork::plot_layout(nrow = 4, guides = "collect") +
  labs(y = "Relative WIS",
       caption = fig_date)

# save
ggsave(filename = paste0(subproj_dir, "/figures/", "ensemble-comparison-line.png"),
       height = 8, width = 6,
       plot = plot_diff_line)