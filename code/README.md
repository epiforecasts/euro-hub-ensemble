## Code and data

Data for this project are evaluation results from comparing multiple forecasting models to observed data. [Read more about Hub evaluation](https://covid19forecasthub.eu/reports.html).

The code in this folder gets and cleans these evaluation datasets. This code is used (sourced) within the analysis files, but could also be used separately to get data for new analyses of the evaluation datasets.

### Code

- `get_latest_eval.R`
  - Contains a single function: `get_latest_eval()`
  - Function downloads latest evaluation from the European Forecast Hub github repository


- `get-model-eval.R`
  - Gets and cleans evaluation dataset of all individual models contributed to the forecast hub


- `get-ensemble-eval.R`
  - Gets and cleans evaluation dataset for ensemble comparison
  - This includes four ensemble models created retrospectively from forecast hub models. These ensemble methods include: mean / median; using weighted / unweighted forecast values
