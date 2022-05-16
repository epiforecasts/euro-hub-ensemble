# Gets variants of concern dataset from ECDC
# For each variant/country finds the first period
#  with variant % greater than 5% and up to 50%
#  before the first peak for that variant
# Note ECDC data are in weeks, dates are indexed to Saturdays to match target end dates

library(here)
library(dplyr)
library(readr)
library(lubridate)

download_variant_introduction <- function(country_names = NULL,
                                          variant_codes = NULL,
                                          introduction_percent = 5,
                                          dominant_percent = 50,
                                          peak_percent = 99) {
  # date lookup table for ecdc year-weeks
  date_range <- tibble(
    daily_date = seq.Date(from = as.Date("2020-01-04"), to = Sys.Date(), by = 7),
    year = isoyear(daily_date),
    week = isoweek(daily_date)) %>%
    group_by(year, week) %>%
    filter(daily_date == min(daily_date))

  # get data
  variants <- read_csv("https://opendata.ecdc.europa.eu/covid19/virusvariant/csv/data.csv", progress = FALSE, show_col_types = FALSE)
  if (is.null(variant_codes)) {variant_codes <- unique(variants$variant)}
  if (is.null(country_names)) {country_names <- unique(variants$country)}

  # filter as needed and set dates
  variants <- variants %>%
    filter(variant %in% variant_codes &
             country %in% country_names &
             source == "GISAID") %>%
    mutate(year = as.numeric(substr(year_week, 1, 4)),
           week = as.numeric(substr(year_week, 6, 8))) %>%
    left_join(date_range, by = c("year", "week")) %>%
    select(country, daily_date, variant, percent_variant)

  # get the first maxima of the variant
  introduction_period <- variants %>%
    group_by(variant, country) %>%
    arrange(daily_date) %>%
    filter(percent_variant <= peak_percent) %>%
    slice_max(percent_variant, with_ties = FALSE) %>%
    select(variant, country, variant_peak_date = daily_date)

  # get the period before the first maxima where the variant is e.g. >5<50%
  var_data <- variants %>%
    left_join(introduction_period, by = c("variant", "country")) %>%
    filter(daily_date <= variant_peak_date &
             percent_variant >= introduction_percent &
             percent_variant <= dominant_percent) %>%
    group_by(country, variant) %>%
    summarise(date_introduction = min(daily_date),
              date_dominant = max(daily_date),
              date_peak = min(variant_peak_date))

  return(var_data)
}



