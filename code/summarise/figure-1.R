# Figure 3: ensemble forecasts over 2020-2021
#   over periods of increasing variants of concern - delta and omicron
library(here)
library(dplyr)
library(ggplot2)
source(here("code", "load", "forecast-variants.R"))
theme_set(theme_bw())

# targets
variant_names <- c("B.1.617.2" = "Delta",
                   "B.1.1.529" = "Omicron")

# Get ensemble forecasts of cases in Germany at dates of variant introductions
forecast_variants <- load_forecast_variants(load_from_local = TRUE)

# alternatively download fresh (allows any country/variant combination)
# forecast_variants <- load_forecast_variants(load_from_local = FALSE,
#                                             country_names = "Germany",
#                                             variant_codes = names(variant_names))

# figure 0 plot ----------------------------------------------
fig1_data <- forecast_variants %>%
  filter(location == "DE" & target_variable == "inc case") %>%
  mutate(forecast_date = factor(forecast_date),
         variant = recode(variant, !!!variant_names)) %>%
  filter(quantile %in% c(0.1,0.25,0.5,0.75,0.9)) %>%
  pivot_wider(names_from = quantile, names_prefix = "q",
              values_from = prediction)

figure_1 <- fig1_data %>%
  mutate(variant = paste("Increasing %", variant)) %>%
  ggplot(aes(x = target_end_date)) +
  geom_point(aes(y = observed)) +
  geom_line(aes(y = observed)) +
  geom_line(aes(y = q0.5, col = forecast_date), alpha = 0.6) +
  geom_ribbon(aes(ymin = q0.25, ymax = q0.75,
                  fill = forecast_date), alpha = 0.4) +
  geom_ribbon(aes(ymin = q0.1, ymax = q0.9,
                  fill = forecast_date), alpha = 0.2) +
  geom_vline(aes(xintercept = date_dominant), lty = 3) +
  scale_x_date(date_labels = "%b %Y") +
  scale_y_continuous(labels = scales::label_comma()) +
  labs(x = NULL, y = "Weekly incident cases in Germany") +
  facet_wrap(~ variant, scales = "free") +
  theme(legend.position = "none",
        strip.background = element_blank())

ggsave(here("output", "figures", "figure-1.png"), width = 7, height = 3)

fig1_cap <- "_Ensemble forecasts of weekly incident cases in Germany over periods of increasing SARS-CoV-2 variants Delta (B.1.617.2, left) and Omicron (B.1.1.529, right). Black indicates observed data. Coloured ribbons represent each weekly forecast of 1-4 weeks ahead (showing median, 50%, and 90% probability). For each variant, forecasts are shown over an x-axis bounded by the earliest dates at which 5% and 99% of sequenced cases were identified as the respective variant of concern, while vertical dotted lines indicate the approximate date that the variant reached dominance (>50% sequenced cases)._"
