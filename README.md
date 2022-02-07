This repository provides code and data for the paper: *Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations*, in draft from the European COVID-19 Forecast Hub. 
- **Collaborators:** please provide comments on text using the shared [Google doc](https://docs.google.com/document/d/1AdlfV3KcyMI3oTqzGRmK1e3jj288IOzl/edit#). Please open an [Issue](https://github.com/covid19-forecast-hub-europe/euro-hub-ensemble/issues) to comment or discuss code.

A quick guide to this repository:
- [output](output): pdf and word versions of rendered `rmarkdown` file, including the [latest draft pdf](output/euro-hub-ensemble-draft.pdf)
- [analysis](analysis): raw `rmarkdown` file containing blended text and code. The full manuscript can be produced by rendering [euro-hub-ensemble-draft.Rmd](analysis/euro-hub-ensemble-draft.Rmd). See that file for instructions on rendering to different output formats.
- [code](code): data loading and cleaning code used only to support the main [Rmarkdown](analysis/euro-hub-ensemble-draft.Rmd) file
- [covid19-forecast-hub-europe](covid19-forecast-hub-europe): submodule, the version of the European Covid-19 Forecast Hub used in this analysis. This submodule tracks the `assess-ensembles` branch

---

# Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations

_Order tbc;_ Katharine Sherratt, Hugo Gruson, _Any co-authors_, _Team authors_, _Advisory team authors_, _ECDC authors_, Johannes Bracher, Sebastian Funk

### Abstract

_Background_ Short-term forecasts of infectious disease burden can contribute to situational awareness and aid capacity planning. Based on best practice in other fields and recent insights in infectious disease epidemiology, one can maximise the predictive performance of such forecasts if multiple models are combined into an ensemble. Here we report on the performance of ensembles created from over 40 models in predicting COVID-19 cases and deaths across Europe between 08 March and 15 November 2021.

_Methods_ We used open-source tools to develop a public European COVID-19 Forecast Hub. We invited groups globally to contribute weekly forecasts for COVID-19 cases and deaths over the next one to four weeks. Forecasts included quantiles across the predictive distribution. Each week we created an ensemble forecast, where each predictive quantile was calculated as the equally-weighted average of all individual models’ predictive quantiles. We retrospectively explored alternative methods for ensemble forecasts, including weighted averages based on models’ past predictive performance. The performance of the ensembles was compared to individual models and a baseline model of no change using pairwise comparison with the Weighted Interval Score (WIS).

_Results_ Over 36 weeks we collected and combined 43 forecast models for 32 countries. We found a weekly ensemble had among the most reliable performances across countries over time, with more accurate predictions for reported cases and deaths than a simple baseline for 67% and 91% of possible forecast targets respectively. Ensemble performance declined with increasing forecast time horizon when forecasting cases but remained stable for 4 weeks for incident death forecasts. Among several choices of ensemble methods, we found that the calculation of the average was the most influential choice for performance. Almost any forecast created using a median average performed better than using a mean, regardless of methods for weighting component forecasts.

_Conclusions_ Our results support the use of an ensemble as a reliable way to make real-time forecasts across many populations and epidemiological targets during infectious disease epidemics. We recommend the use of median ensemble methods across many forecasting models in general, and specifically that current policy relevant work using COVID-19 surveillance data across Europe should place more confidence in forecasts of incident death than case counts at longer (more than 2 week) periods into the future.

[Continue reading...](output/euro-hub-ensemble-draft.pdf)
