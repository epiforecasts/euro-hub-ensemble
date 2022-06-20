# [Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations](https://www.medrxiv.org/content/10.1101/2022.06.16.22276024)

--- **Now online as a [pre-print](https://www.medrxiv.org/content/10.1101/2022.06.16.22276024)** ---

---

This repository provides code and data for the paper: *Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations*, analysing a year of COVID-19 forecasts from the [European COVID-19 Forecast Hub](https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe).

### Quick start

A brief guide to the workflow of files in this repository:

- [output](output): The [latest manuscript](output/latest.pdf) and [supplement](output/supplementary.pdf), plus previous dated drafts of the text
- [analysis](analysis): raw `rmarkdown` files, containing blended text and code to produce the `output`
- [code](code): data extraction, loading and transformation code used to support the main [analysis](analysis/latest.Rmd)
   - [load](code/load): functions to download forecasts and evaluation scores from the Forecast Hub Github repository
   - [summarise](code/summarise): uses the `load` functions to save key [datasets](data) and create figures and summary statistics used in the [analysis](analysis)
- [data](data): key datasets used in this study, including evaluation scores for ensemble and individual models downloaded from the [European COVID-19 Forecast Hub repository](https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe)

Each folder has a README with a more detailed guide to its contents.

### Feedback

All feedback is very welcome - just open an [Issue](https://github.com/covid19-forecast-hub-europe/euro-hub-ensemble/issues) with your comments. We would  especially appreciate thoughts on:

- Bugs or potential improvements to code or documentation
- Ease of use as an example for extracting, transforming, and loading Forecast Hub data (particularly from the perspective of users who are less/un-familiar with using data stored on Github)
- Further thoughts and priorities for the analysis of COVID-19 individual and ensemble forecasts
