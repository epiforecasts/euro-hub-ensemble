# Guide to code

`load` provides functions to access different types of European Forecast Hub data, with example scripts for using those functions to create a dataset of forecasts or evaluations. `summarise` creates the summary numbers and figures used in the main study.

## `load`

### Complete scripts
  - `load-and-process-forecasts.R` - script to download forecasts and remove anomalies
  - `evaluation-scores.R` - script to load and save evaluation scores

### Functions
Scripts containing only functions (package-style), including the type of output they return in (brackets):

- Functions to access forecasts
  - `download_forecasts.R`    
    - `download_model_forecasts()` - get forecasts from a single model at specified forecast dates (dataframe)
    - `download_forecasts()` - get forecasts from optionally specified models at optionally specified dates (dataframe)
    - `process_forecasts()` - add observed data and remove anomalies (dataframe)
  - `download_variant_forecasts.R`
    - `download_variant_forecasts()` - gets Hub ensemble forecast at timing of variant introductions (dataframe)

- Functions to access metadata
  - `download_metadata.R` - collection of helper functions to access metadata about the Forecast Hub, including:
    - `download_hub_metadata()` - get information about the Hub configuration, such as start date, targets (dataframe)
    - `get_forecast_dates()` - get all possible weekly dates on which forecasts were made (vector)
    - `download_model_names()` - get names of all forecasting models in the Hub (vector)
    - `download_model_metadata()` - get metadata associated with all models in the Hub (dataframe)
    - `download_anomalies()` - download dataset of anomalies found by the Forecast hub (dataframe)
  - `download_variant_introduction.R`
    - `download_variant_introduction()` - gets variants of concern dataset from ECDC; for each variant/country finds the first period with variant % of cases greater than 5% and up to 50%,  before the first peak for that variant (dataframe)

- Functions to access evaluation
  - `download_latest_eval.R`
    - `download_latest_eval()` - downloads latest evaluation from the European Forecast Hub github repository ([read more about Hub evaluation](https://covid19forecasthub.eu/reports.html)), and lightly cleans. (dataframe)          

## `summarise`

These scripts create numbers, figures, and tables used in the text and SI of the `analysis`.
