# Code

`get-model-eval.R`
- Data: 
  - data are evaluation results from comparing multiple forecasting models to observed data
  - the evaluation includes relative WIS against a basline, and coverage. Results for each model are taken over the entire history of forecasts submitted for each target. 
  - see also: [more information on evaluation](https://covid19forecasthub.eu/reports.html)
- Script: 
  - finds the evaluation dataset from a given `eval_date` 
  - tidies the dataframe for readable plots
  - no further analysis, as this is integrated directly in the [Rmarkdown](https://github.com/covid19-forecast-hub-europe/euro-hub-ensemble/blob/main/analysis/euro-hub-ensemble-draft.Rmd)

`get-ensemble-eval.R`
- Data: 
  - evaluation results from comparing multiple ensemble methods to observed data
  - these alternative ensemble methods include: mean / median average; weighted / unweighted forecast values
     - weighted methods include: using all available forecasts for evaluation, or only 10 weeks; using a cut-off to exclude models with a relative WIS > 1
- Script: 
  - gets evaluation dataset for ensemble comparison
  - cleans to clarify each ensemble method used
  - creates a function to compute overall differences in scores between each ensemble method

