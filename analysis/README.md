### [Predictive performance of multi-model ensemble forecasts of Covid-19 across European nations](https://www.medrxiv.org/content/10.1101/2022.06.16.22276024)

#### Paper text, figures, and code
The Rmarkdown document [latest.Rmd](analysis/latest.Rmd) contains all paper text integrated with code to generate in-line numbers and figures. The paper was collaborated on with trackdown in google drive: https://docs.google.com/document/d/1XT7xwljCfaQ1_CpKxyJySqiPsIZ2bWNWFJE_v_U6EHc/edit

This draws on a modular [codebase](code) for loading and summarising raw data from the European Forecast Hub, covered in a separate [guide](code/readme.md).

#### Generate the complete paper

Generate the [latest version of the paper]([analysis/latest.Rmd](https://github.com/epiforecasts/euro-hub-ensemble/blob/main/analysis/latest.Rmd)) with:

```
rmarkdown::render(here::here("analysis/latest.Rmd"),
                 rmarkdown::html_document(fig_caption = TRUE),
                 output_dir = "output")
```

This includes the title page with author information, abstract, and references (available as a [bib file](references.bib)).

Generate the [Supplementary Information](analysis/supplementary.Rmd) with:
```
rmarkdown::render(here::here("analysis/supplementary.Rmd"),
                 rmarkdown::html_document(fig_caption = TRUE),
                 output_dir = "output")
```

All files (figures and PDFs) are then saved to [output](output).
