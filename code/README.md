## Code and data

Data for this project are evaluation results from comparing multiple forecasting models to observed data. [Read more about Hub evaluation](https://covid19forecasthub.eu/reports.html).

The code in this folder gets and cleans these evaluation datasets. This code is used (sourced) within the analysis files, but could also be used separately to get data for new analyses of the evaluation datasets.

### Code

- `load`

  - `download_latest_eval.R`
    - Contains a single function: `download_latest_eval()`
    - Function downloads latest evaluation from the European Forecast Hub github repository and lightly cleans
    - Options to 
      - specify the evaluation date (latest date until when to assess models)
      - how many weeks models should have been evaluated over (only the most recent 10 weeks or over all time)
      - which scores to include from evaluating forecasts of cases, deaths, and/or hospitalisations (default returns only cases and deaths)
      - whether to download evaluations from `main` branch or alternative branch of the Forecast Hub repo

  - `download_model_metadata.R`
    - Function: `download_model_metadata()` - helper to check metadata for all individual models in the Hub, including model designation
  
  - `load-evaluation-scores.R`
    - Loads the latest evaluation scores for all individual models, and the retrospectively run alternative ensembles
  
- `summarise`

  - `data.R`
    - Uses evaluation scores to create a list of named values used in the text of the paper 

  - Remaining files create figures and tables in the text and SI


