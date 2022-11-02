# [Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations](https://www.medrxiv.org/content/10.1101/2022.06.16.22276024)

MedRxiv: [https://doi.org/10.1101/2022.06.16.22276024](https://www.medrxiv.org/content/10.1101/2022.06.16.22276024)

Code: [![DOI](https://zenodo.org/badge/434779787.svg)](https://zenodo.org/badge/latestdoi/434779787)

---

### This project

This repository provides code and data for analysing a year of COVID-19 forecasts from the [European COVID-19 Forecast Hub](https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe).

 All code is open source and anyone is welcome to freely use and adapt any part of this codebase for any purpose.

You can find here:

- The latest manuscript in [pdf](output/latest.pdf) or [Rmarkdown](analysis/latest.Rmd), now published as a [pre-print](https://doi.org/10.1101/2022.06.16.22276024) and submitted to eLife
- A [modular codebase](code) for downloading and summarising data from the European Forecast Hub

All feedback is very welcome - just open an [Issue](https://github.com/covid19-forecast-hub-europe/euro-hub-ensemble/issues) with your comments. We would  especially appreciate thoughts on:

- Bugs or potential improvements to code or documentation
- Ease of use as an example for extracting, transforming, and loading Forecast Hub data (particularly from the perspective of users who are less/un-familiar with using data stored on Github)
- Further thoughts and priorities for the analysis of COVID-19 individual and ensemble forecasts

### This repository

#### Workflow

A brief guide to the files in this repository:

- [data](data): key datasets used in this study, including evaluation scores for ensemble and individual models downloaded from the [European COVID-19 Forecast Hub repository](https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe)
- [code](code#readme): data extraction, loading and transformation code used to support the main [analysis](analysis/latest.Rmd)
 - [load](code/load): functions to download forecasts and evaluation scores from the Forecast Hub Github repository
 - [summarise](code/summarise): uses the `load` functions to save key [datasets](data) and create figures and summary statistics used in the [analysis](analysis)
- [analysis](analysis#readme): raw `rmarkdown` files, containing blended text and code to produce the `output`
- [output](output#readme): The [latest manuscript](output/latest.pdf) and [supplement](output/supplementary.pdf), plus previous dated drafts of the text

Each folder has a README with a more detailed guide to its contents.

#### Code

All code is in R, tested in version 4.2.1.

The [DESCRIPTION](DESCRIPTION) lists packages used in the project. They are all available on CRAN, except `covidHubUtils`, the package used to load observed data. Install this with:
```
remotes::install_github("reichlab/covidHubUtils")
```

<details><summary>R session info</summary>

```
> sessionInfo()

R version 4.2.1 (2022-06-23 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 22000)

Matrix products: default

locale:
[1] LC_COLLATE=English_United Kingdom.utf8
[2] LC_CTYPE=English_United Kingdom.utf8   
[3] LC_MONETARY=English_United Kingdom.utf8
[4] LC_NUMERIC=C                           
[5] LC_TIME=English_United Kingdom.utf8    

attached base packages:
[1] stats     graphics  grDevices utils     datasets
[6] methods   base     

loaded via a namespace (and not attached):
 [1] bookdown_0.29   digest_0.6.29   jsonlite_1.8.0
 [4] magrittr_2.0.3  evaluate_0.16   rlang_1.0.4    
 [7] cli_3.3.0       renv_0.15.5     rstudioapi_0.13
[10] rmarkdown_2.14  tools_4.2.1     purrr_0.3.4    
[13] xfun_0.32       yaml_2.3.5      fastmap_1.1.0  
[16] compiler_4.2.1  htmltools_0.5.3 knitr_1.39   
```
</details>
