# Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations

--- **Now online as a [pre-print](https://www.medrxiv.org/content/10.1101/2022.06.16.22276024)** ---

This repository provides code and data for the paper: *Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations*, analysing a year of COVID-19 forecasts from the [European COVID-19 Forecast Hub](https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe).

A quick guide to this repository:

- [output](output): The [latest draft](output/latest.pdf) as a complete text generated from a rendered `rmarkdown` file, plus dated previous versions of the text 

- [analysis](analysis): raw `rmarkdown` files containing blended text and code

- [code](code): data loading and cleaning code used to support the main [analysis](analysis/latest.Rmd)

   - [load](code/load): functions to download forecasts and evaluation scores from the Forecast Hub Github repository
   
   - [summarise](code/summarise): create figures and summary statistics
   
- [data](data): evaluation scores for ensemble and individual models, downloaded from the [European COVID-19 Forecast Hub repository](https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe)

Please open an [Issue](https://github.com/covid19-forecast-hub-europe/euro-hub-ensemble/issues) to comment or discuss code.
