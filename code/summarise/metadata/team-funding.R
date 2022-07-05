library(dplyr)
library(stringr)
library(tidyr)
library(janitor)
library(googlesheets4)

# set up ------------------------------------------------------------------
gs4_deauth()

# Get funding details
authors_raw <- read_sheet("https://docs.google.com/spreadsheets/d/19hS7r7y126J3BPBhJa20rHApFu3Hx1DQEWe7av7fX68/edit#gid=1316950565",
                          sheet = "Authorship details")

# create unique author initial abbreviations
initials <- authors_raw %>%
  clean_names() %>%
  mutate(init_1 = substr(first_name, 1, 1),
         init_2 = substr(middle_name_s_initial_s, 1, 1),
         init_first = ifelse(!is.na(init_2), paste0(init_1, init_2), init_1),
         init_last1 = substr(last_name, 1, 1),
         init_last2 = substr(last_name, 2, 2),
         init_firstlast = paste0(init_first, init_last1),
         initials = ifelse((duplicated(init_firstlast) |
                              lead(duplicated(init_firstlast), 1)),
                           paste0(init_firstlast, init_last2),
                           init_firstlast),
         initials = ifelse(is.na(initials), init_firstlast, initials),
         funding = str_remove_all(funding, "\\.$")) %>%
  select(initials, funding, funding_individual)

# parse funding statements ------------------------------------------------
funding_split <- split(initials, initials$funding)

paste_funding <- function(team_funding) {
  team_funding <- arrange(team_funding, initials)
  paste(paste(unlist(team_funding["initials"]),
              collapse = ", "),
        paste("funded by",
              team_funding[["funding"]][1]))
}

funding_statements <- purrr::map(funding_split, ~ paste_funding(.x))

# unique individual funding
individual <- filter(initials, !is.na(funding_individual))

# virginia
virginia_funding <- "University of Virginia"
virginia_text <- "Virginia Dept of Health Grant "
virginia_individual <- individual %>%
  filter(grepl(virginia_funding, funding)) %>%
  mutate(funding_individual = str_remove_all(funding_individual,
                                             virginia_text))
virginia_individual_split <- split(virginia_individual,
                                   virginia_individual$funding)
virginia_team_statement <- purrr::map(virginia_individual_split,
                                      ~ paste_funding(.x))
virginia <- paste0(", and respectively ", virginia_text, paste(virginia_individual$funding_individual, collapse = ", "))
virginia_final <- paste0(virginia_team_statement, virginia)

funding_statements[[which(grepl(virginia_funding, names(funding_statements)))]] <- virginia_final

# MUNI
muni_funding <- "MUNI"
muni <- individual %>%
  filter(grepl(muni_funding, funding))
muni_ve <- paste(muni$initials, "also supported by", muni$funding_individual,
      sep = " ")
muni_final <- paste0(funding_statements[[which(grepl(muni_funding, names(funding_statements)))]], "; ", muni_ve)

funding_statements[[which(grepl(muni_funding, names(funding_statements)))]] <- muni_final


# all together
funding_text <- paste0(paste(sort(unlist(funding_statements)), collapse = ". "),
                      ". The funders had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript.")

writeLines(funding_text,
           con = here::here("output", "metadata", "funding-statements.txt"))
