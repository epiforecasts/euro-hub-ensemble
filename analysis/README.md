Predictive performance of multi-model ensemble forecasts of COVID-19
across European nations
================

*Order tbc;* Katharine Sherratt, Hugo Gruson, *Any co-authors*, *Team
authors*, *Advisory team authors*, *ECDC authors*, Johannes Bracher,
Sebastian Funk

# Abstract

*Background* Short-term forecasts of infectious disease burden can
contribute to situational awareness and aid capacity planning. Based on
best practice in other fields and recent insights in infectious disease
epidemiology, one can maximise the predictive performance of such
forecasts if multiple models are combined into an ensemble. Here we
report on the performance of ensembles in predicting COVID-19 cases and
deaths across Europe between 08 March 2021 and 07 March 2022.

*Methods* We used open-source tools to develop a public European
COVID-19 Forecast Hub. We invited groups globally to contribute weekly
forecasts for COVID-19 cases and deaths over the next one to four weeks.
Forecasts were submitted using standardised quantiles of the predictive
distribution. Each week we created an ensemble forecast, where each
predictive quantile was calculated as the equally-weighted average
(initially the mean and then the median from the 26th of July) of all
individual models’ predictive quantiles. We measured the performance of
each model using the relative Weighted Interval Score (WIS), comparing
models’ forecast accuracy relative to all other models, then scaled
against a baseline model of no change. We retrospectively explored
alternative methods for ensemble forecasts, including weighted averages
based on models’ past predictive performance.

*Results* Over 52 weeks we collected and combined up to 28 forecast
models for 32 countries. We found a weekly ensemble had a strong and
consistently reliable performance across countries over time. Across all
horizons and locations, the ensemble performed better on scaled relative
WIS than 83% of participating models’ forecasts of incident cases (with
a total N=862), and 91% of participating models’ forecasts of deaths
(N=746). Across a one to four week time horizon, ensemble performance
declined with longer forecast periods when forecasting cases, but
remained stable over four weeks for incident death forecasts. In every
forecast across 32 countries, the ensemble outperformed 50% of submitted
models when forecasting either cases or deaths, frequently outperforming
all of its individual component models. Among several choices of
ensemble methods we found that the most influential and best choice was
to use a median average of models instead of using the mean, regardless
of methods of weighting component forecast models.

*Conclusions* Our results support the use of combining forecasts from
individual models into an ensemble in order to improve predictive
performance across epidemiological targets and populations during
infectious disease epidemics. Our findings suggested that for an
emerging pathogen with many individual models, median ensemble methods
may improve predictive performance more than mean ensemble methods. Our
findings also highlight that forecast consumers should place more weight
on incident death forecasts versus incident case forecasts for forecast
horizons greater than two weeks.

*Code and data availability* All data and code are publicly available on
Github: covid19-forecast-hub-europe/euro-hub-ensemble.

*This document was generated on* 2022-03-27

# Background

Epidemiological forecasts make quantitative statements about a disease
outcome in the near future. Forecasting targets can include measures of
prevalent or incident disease and its severity, for some population over
a specified time horizon. Researchers, policy makers, and the general
public have used such forecasts to understand and respond to the global
outbreaks of COVID-19 since early 2020
[\[1\]](#ref-basshuysenThreeWaysWhich2021). Forecasters use a variety of
methods and models for creating and publishing forecasts, varying in
both defining the forecast outcome and in reporting the probability
distribution of outcomes
[\[2\]](#ref-zelnerAccountingUncertaintyPandemic2021),
[\[3\]](#ref-jamesUseMisuseMathematical2021). Such variation between
forecasts makes it difficult to compare predictive performance between
forecast models. These barriers to comparing and evaluating forecasts
make it difficult to derive objective arguments for using one forecast
over another. This hampers the selection of a representative forecast
and hinders finding a reliable basis for decisions.

A “forecast hub” is a centralised effort to improve the transparency and
usefulness of forecasts, by standardising and collating the work of many
independent teams producing forecasts
[\[4\]](#ref-reichCollaborativeMultiyearMultimodel2019). A hub sets a
commonly agreed-upon structure for forecast targets, such as type of
disease event, spatio-temporal units, or the set of quantiles of the
probability distribution to include from probabilistic forecasts. For
instance, a hub may collect predictions of the total number of cases
reported in a given country for each day in the next two weeks.
Forecasters can adopt this format and contribute forecasts for
centralised storage in the public domain. This shared infrastructure
allows forecasts produced from diverse teams and methods to be
visualised and quantitatively compared on a like-for-like basis, which
can strengthen public and policy use of disease forecasts
[\[5\]](#ref-cdcCoronavirusDisease20192020). The underlying approach to
creating a forecast hub was pioneered for forecasting influenza in the
USA and adapted for forecasts of short-term COVID-19 cases and deaths in
the US [\[6\]](#ref-rayEnsembleForecastsCoronavirus2020e)
`#ADD ZOTERO cite US data descriptor paper`, with similar efforts
elsewhere
[\[7\]](#ref-bracherPreregisteredShorttermForecasting2021)–[\[9\]](#ref-bicherSupportingCOVID19PolicyMaking2021).
Standardising forecasts allows for combining multiple forecasts into a
single ensemble with the potential for an improved predictive
performance. Evidence from previous efforts in multi-model infectious
disease forecasting suggests that forecasts from an ensemble of models
can be consistently high performing compared to any one of the component
models
[\[10\]](#ref-reichAccuracyRealtimeMultimodel2019)–[\[12\]](#ref-viboudRAPIDDEbolaForecasting2018).
Elsewhere, weather forecasting has a long-standing use of building
ensembles of models using diverse methods with standardised data and
formatting in order to improve performance
[\[13\]](#ref-buizzaIntroductionSpecialIssue2019),
[\[14\]](#ref-moranEpidemicForecastingMessier2016). The European
COVID-19 Forecast Hub
[\[15\]](#ref-europeancovid-19forecasthubEuropeanCOVID19Forecast2021) is
a project to collate short term forecasts of COVID-19 across 32
countries in the European region. The Hub is funded and supported by the
European Centre for Disease Prevention and Control (ECDC), with the
primary aim to provide reliable information about the near-term
epidemiology of the COVID-19 pandemic to the research and policy
communities and the general public. Second, the Hub aims to create
infrastructure for storing and analysing epidemiological forecasts made
in real time by diverse research teams and methods across Europe. Third,
the Hub aims to maintain a community of infectious disease modellers
underpinned by open science principles. We started formally collating
and combining contributions to the European Forecast Hub in March 2021.
Here, we investigate the predictive performance of an ensemble of all
forecasts contributed to the Hub in real time each week, as well as the
performance of variations of ensemble methods created retrospectively.

# Methods

We developed infrastructure to host and analyse forecasts, focussing on
compatibility with the US
[\[16\]](#ref-cramerReichlabCovid19forecasthubRelease2021),
[\[17\]](#ref-wangReichlabCovidHubUtilsRepository2021) and the German
and Polish COVID-19 [\[18\]](#ref-bracherGermanPolishCOVID192020)
forecast hubs.

### Forecast targets and standardisation

We sought forecasts for two measures of COVID-19 incidence: the total
reported number of cases and deaths per week. We considered forecasts
for 32 countries in Europe, including all countries of the European
Union and European Free Trade Area, and the United Kingdom. We compared
forecasts against observed data reported by Johns Hopkins University
(JHU, [\[19\]](#ref-dongInteractiveWebbasedDashboard2020)). JHU data
included a mix of national and aggregated subnational data for the 32
countries in the Hub. Incidence was aggregated over the Morbidity and
Mortality Weekly Report (MMWR) epidemiological week definition of Sunday
through Saturday. When predicting any single forecast target, teams
could express uncertainty by submitting predictions across a range of a
pre-specified set of 23 quantiles in the probability distribution. Teams
could also submit a single point forecast without uncertainty. At the
first submission we asked teams to add a single set of metadata briefly
describing the forecasting team and methods. No restrictions were placed
on who could submit forecasts, and to increase participation we actively
contacted known forecasting teams across Europe and the US and
advertised among the ECDC network. Teams submitted a broad spectrum of
model types, ranging from mechanistic to empirical models, agent-based
and statistical models, and ensembles of multiple quantitative or
qualitative models (described at
<https://covid19forecasthub.eu/community.html>). We maintain a full
project specification with a detailed submissions protocol
[\[20\]](#ref-europeancovid-19forecasthubCovid19forecasthubeuropeWiki).
With the complete dataset for the latest forecasting week available each
Sunday, teams typically submitted forecasts to the hub on Monday. We
implemented an automated validation programme to check that each new
forecast conformed to standardised formatting. The validation step
ensured a monotonic increase of predictions with each increasing
quantile, integer-valued counts of predicted cases, as well as
consistent date and location definitions. Each week we built an ensemble
of all forecasts updated after all forecasts had been validated. From
the first week of forecasting from 8 March 2021, the ensemble method for
summarising across forecasts was the arithmetic mean of all models at
each predictive quantile for a given location, target, and horizon. From
26 July 2021 onwards the ensemble instead used a median of all
predictive quantiles, in order to mitigate the wide uncertainty produced
by some highly anomalous forecasts. We created an open and publicly
accessible interface to the forecasts and ensemble, including an online
visualisation tool allowing viewers to see past data and interact with
one or multiple forecasts for each country and target for up to four
weeks’
horizon[\[21\]](#ref-europeancovid-19forecasthubEuropeanCovid19Forecast).
All forecast and meta data are freely available and held on Zoltar, a
platform for hosting epidemiological forecasts
[\[22\]](#ref-epiforecastsProjectECDCEuropean2021),
[\[23\]](#ref-reichZoltarForecastArchive2021).

### Forecast evaluation

We evaluated all previous forecasts against actual observed values for
each model, stratified by the forecast horizon, location, and target. We
calculated scores using the scoringutils R package
[\[24\]](#ref-nikosibosseScoringutilsUtilitiesScoring2020). We removed
any forecast surrounding (in the week of the first week after) a
strongly anomalous data point. We defined anomalous as where any
subsequent data release revised that data point by over 5%.

For each model, we established its overall predictive performance using
the weighted interval score (WIS) and the accuracy of its prediction
boundaries as the coverage of the predictive intervals. We calculated
coverage at a given interval level k, where
![k\\in\[0,1\]](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;k%5Cin%5B0%2C1%5D "k\in[0,1]"),
as the proportion
![p](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;p "p")
of observations that fell within the corresponding central predictive
intervals across locations and forecast dates. A perfectly calibrated
model would have
![p=k](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;p%3Dk "p=k")
at all 11 levels (corresponding to 22 quantiles excluding the median).
An under confident model at level
![k](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;k "k")
would have
![p>k](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;p%3Ek "p>k"),
i.e. more observations fall within a given interval than expected. In
contrast, an overconfident model at level
![k](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;k "k")
would have
![p\<k](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;p%3Ck "p<k"),
i.e. fewer observations fall within a given interval than expected. We
here focus on coverage at the
![k=0.5](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;k%3D0.5 "k=0.5")
and
![k=0.95](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;k%3D0.95 "k=0.95")
level.

We assessed weekly forecasts using the WIS, across all quantiles that
were being gathered
[\[25\]](#ref-bracherEvaluatingEpidemicForecasts2021). The WIS is a
strictly proper scoring rule, that is, it is optimised for predictions
that come from the data-generating model. As a consequence, the WIS
encourages forecasters to report predictions representing their true
belief about the future
[\[26\]](#ref-gneitingStrictlyProperScoring2007). The WIS represents an
approach to scoring forecasts based on uncertainty represented as
forecast values across a set of quantiles
[\[25\]](#ref-bracherEvaluatingEpidemicForecasts2021). The WIS
represents a parsimonious approach to scoring forecasts when only
quantiles are available. Each forecast for a given location and date is
scored based on an observed count of weekly incidence, the median of the
predictive distribution and the width of the predictive upper and lower
quantiles corresponding to the central predictive interval level (see
[\[25\]](#ref-bracherEvaluatingEpidemicForecasts2021)). As not all
models provided forecasts for all locations and dates, to compare
predictive performance in the face of various levels of missingness, we
calculated a relative WIS. This is a measure of forecast performance
which takes into account that different teams may not cover the same set
of forecast targets (i.e., weeks and locations). Loosely speaking, a
relative WIS of x means that averaged over the targets a given team
addressed, its WIS was x times higher or lower than the performance of
the baseline model. Smaller values in the relative WIS are thus better
and a value below one means that the model has above average
performance. The relative WIS is computed using a *pairwise comparison
tournament* where for each pair of models a mean score ratio is computed
based on the set of shared targets. The relative WIS of a model with
respect to another model is then the ratio of their respective geometric
mean of the mean score ratios. We then took the relative WIS of each
model and scaled this against the relative WIS of a baseline model, for
each forecast target, location, date, and horizon. The baseline model
assumes case or death counts stay the same as the latest data point over
all future horizons, with expanding uncertainty, described previously in
[\[27\]](#ref-cramerEvaluationIndividualEnsemble2021). Here we report
the relative WIS of each model with respect to the baseline model.

#### Ensemble methods

We retrospectively explored alternative methods for combining forecasts
for each target at each week. A natural way to combine probability
distributions available in a quantile format, such as the ones collated
in the European COVID-19 Forecast Hub, is
[\[28\]](#ref-genestVincentizationRevisited1992)

![F^{-1}(\\alpha) = \\sum\_{i=1}^{n}w_i F_i^{-1}(\\alpha)](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;F%5E%7B-1%7D%28%5Calpha%29%20%3D%20%5Csum_%7Bi%3D1%7D%5E%7Bn%7Dw_i%20F_i%5E%7B-1%7D%28%5Calpha%29 "F^{-1}(\alpha) = \sum_{i=1}^{n}w_i F_i^{-1}(\alpha)")

Where
![F\_{1} \\ldots F\_{n}](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;F_%7B1%7D%20%5Cldots%20F_%7Bn%7D "F_{1} \ldots F_{n}")
are the cumulative distribution functions of the individual probability
distributions (in our case, the predictive distributions of each
forecast model
![i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;i "i")
contributed to the hub),
![w_i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;w_i "w_i")
are a set of weights in
![\[0,1\]](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5B0%2C1%5D "[0,1]");
and
![\\alpha](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5Calpha "\alpha")
are the quantile levels such that

![F^{-1}(\\alpha) = \\mathrm{inf} \\{t : F_i(t) \\geq \\alpha \\}](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;F%5E%7B-1%7D%28%5Calpha%29%20%3D%20%5Cmathrm%7Binf%7D%20%5C%7Bt%20%3A%20F_i%28t%29%20%5Cgeq%20%5Calpha%20%5C%7D "F^{-1}(\alpha) = \mathrm{inf} \{t : F_i(t) \geq \alpha \}")

Different ensemble choices then mainly translate to the choice of
weights
![w_i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;w_i "w_i").
The simplest choice of weights
![w_i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;w_i "w_i")
is to set them all equal so that they sum up to 1,
![w_i=1/n](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;w_i%3D1%2Fn "w_i=1/n"),
resulting in an arithmetic mean ensemble. However, with this method a
single outlier can have a very strong effect on the ensemble forecast.
To avoid this overrepresentation, we can choose a set of weights to
apply to forecasts before they are combined at each quantile level.
Numerous options exist for choosing these weights with the aim to
maximise predictive performance, including choosing weights to reflect
each forecast’s past performance (thereby moving from an untrained to a
trained ensemble). A straightforward choice is so-called inverse score
weighting, which was recently found in the US to outperform unweighted
scores during some time periods
[\[29\]](#ref-taylorCombiningProbabilisticForecasts2021) but not
confirmed in a similar study in Germany and Poland Poland
[\[7\]](#ref-bracherPreregisteredShorttermForecasting2021). In this
case, the weights are calculated as

![w_i = \\frac{1}{S_i}](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;w_i%20%3D%20%5Cfrac%7B1%7D%7BS_i%7D "w_i = \frac{1}{S_i}")

where
![S_i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;S_i "S_i")
reflects the forecast skill of forecaster
![i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;i "i"),
normalised so that weights sum to 1.

Alternatively, previous research has found that an unweighted median
ensemble, where the arithmetic mean of each quantile is replaced by a
median, yields very competitive performance while maintaining robustness
to outlying forecasts `# cite https://arxiv.org/abs/2201.12387`.
Building on this, it is possible to use the same weights described above
to create a weighted median. This uses the Harrel-Davis quantile
estimator with a beta function to approximate the weighted percentiles
`#ADD ZOTERO cite Harrell, F.E. & Davis, C.E. (1982). A new distribution-free quantile estimator. Biometrika, 69(3), 635-640`
;
`# ADD ZOTERO cite https://www.rdocumentation.org/packages/cNORM/versions/2.0.3/topics/weighted.quantile`
. Here we considered unweighted and inverse relative WIS weighted mean
and median ensembles.

# Results

We collected forecasts submitted weekly in real time over the 52 week
period from 08 March 2021 to 07 March 2022. Each week we used all
available forecasts to create a weekly real-time ensemble model
(referred to as “the ensemble” from here on) for each of the 256
possible forecast targets: incident cases and deaths in 32 locations
over the following one through four weeks. The ensemble model was an
unweighted average from March through July 2021 and then an unweighted
median (figure 0).

![*Ensemble forecasts of weekly incident cases in Germany over periods
of increasing SARS-CoV-2 variants Delta (B.1.617.2, left) and Omicron
(B.1.1.529, right). Black indicates observed data. Coloured ribbons
represent each weekly forecast of 1-4 weeks ahead (showing median, 50%,
and 90% probability). For each variant, forecasts are shown over an
x-axis bounded by the earliest dates at which 5% and 99% of sequenced
cases were identified as the respective variant of concern, while
vertical dotted lines indicate the approximate date that the variant
reached dominance (>50% sequenced
cases).*](abstract-results_files/figure-gfm/figure-0-1.png)

The number of models contributing to each ensemble forecast varied over
time and by forecasting target (SI figure 1). Over the whole study
period 26 independently participating forecasting teams contributed
results from 28 unique forecasting models. While not all modellers
created forecasts for all locations, horizons, or variables, no ensemble
forecast was composed of less than 3 independent models. At most, 15
models contributed forecasts for cases in Germany at the 1 week horizon,
with an accumulated 592 forecasts for that single target over the study
period (with the ensemble of all models in Germany shown in figure 0).
In contrast, deaths in Finland at the 2 week horizon saw the smallest
number of forecasts, with only 6 independent models contributing a total
24 forecasts. Similarly, not all teams forecast across all quantiles of
the predictive distribution for each target, with only 23 models
providing the full set of 23 quantiles.

Using all models and the ensemble, we created 2106 forecasting scores
where each score summarises a unique combination of forecasting model,
variable, country, and week ahead horizon (SI figure 2). The ensemble of
all models performed well compared to both its component models and the
baseline. By relative WIS scaled against a baseline of 1 (where a score
\<1 indicates outperforming the baseline), the median score for
participating models across all submitted forecasts was 1.04, while the
median score of forecasts from the ensemble model was 0.71. Across all
horizons and locations, the ensemble performed better on scaled relative
WIS than 83% of participating model scores when forecasting cases (with
a total N=862), and 91% of participating model scores for forecasts of
incident deaths (N=746).

![*Performance of short-term forecasts aggregated across all
individually submitted models and the Hub ensemble, by horizon,
forecasting cases (left) and deaths (right). Performance measured by
relative weighted interval score scaled against a baseline (dotted line,
1), and coverage of uncertainty at the 50% and 95% levels. Boxplot, with
width proportional to number of observations, show interquartile ranges
with outlying scores as faded points. The target range for each set of
scores is shaded in
yellow.*](abstract-results_files/figure-gfm/figure-1-1.png)

The performance of individual and ensemble forecasts varied by length of
the forecast horizon (Figure 1). At each horizon, the typical
performance of the ensemble outperformed both the baseline model and the
aggregated scores of all its component models, although we saw wide
variation between individual models in performance across horizons.

Both individual models and the ensemble saw a trend of worsening
performance at longer horizons when forecasting cases, while performance
remained more stable when estimating deaths. By scaled relative WIS, the
median performance of the ensemble across locations worsened from 0.62
for one-week ahead forecasts to 0.9 when forecasting four weeks ahead.
Performance for forecasts of deaths was more stable over one through
four weeks, with median ensemble performance moving from 0.685 to 0.76
across the four week horizons.

We observed similar trends in performance across horizon when
considering how well the ensemble was calibrated with respect to the
observed data. At one week ahead the case ensemble was well calibrated
(ca. 50% and 95% nominal coverage at the 50% and 95% levels
respectively). This did not hold at longer forecast horizons as the case
forecasts became increasingly over-confident. Meanwhile, the ensemble of
death forecasts was well calibrated at the 95% level across all
horizons, and the calibration of death forecasts at the 50% level
increased in accuracy with lengthening horizons.

![*Performance of short-term forecasts across models and median ensemble
(asterisk), by country, forecasting cases (top) and deaths (bottom) for
two-week ahead forecasts, according to the relative weighted interval
score. Boxplots show interquartile ranges, with outliers as faded
points, and the ensemble model performance is marked by an asterisk.
y-axis is cut-off to an upper bound of 4 for
readability.*](abstract-results_files/figure-gfm/figure-2-1.png)

The ensemble also performed consistently well in comparison to
individual models when forecasting across countries (figure 2). Across
32 countries, on aggregate forecasting for one through four weeks, when
forecasting cases the ensemble oupterformed 75% of component models in
21 countries, and outperformed all available models in 3 countries. When
forecasting deaths, the ensemble outperformed 75% and 100% of models in
30 and 9 countries respectively. Considering only the the two-week
horizon shown in figure 2, the ensemble of case forecasts outperformed
75% models in 24 countries and all models in only 12 countries. At the
two-week horizon for forecasts of deaths, the ensemble outperformed 75%
and 100% of its component models in 30 and 26 countries respectively.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>
Predictive performance of main ensembles, as measured by the scaled
relative WIS.
</caption>
<thead>
<tr>
<th style="text-align:left;">
Horizon
</th>
<th style="text-align:right;">
Weighted mean
</th>
<th style="text-align:right;">
Weighted median
</th>
<th style="text-align:right;">
Unweighted mean
</th>
<th style="text-align:right;">
Unweighted median
</th>
</tr>
</thead>
<tbody>
<tr grouplength="4">
<td colspan="5" style="border-bottom: 1px solid;">
<strong>Cases</strong>
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
1 week
</td>
<td style="text-align:right;">
0.59
</td>
<td style="text-align:right;">
0.62
</td>
<td style="text-align:right;">
0.59
</td>
<td style="text-align:right;">
0.61
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
2 weeks
</td>
<td style="text-align:right;">
0.67
</td>
<td style="text-align:right;">
0.67
</td>
<td style="text-align:right;">
0.67
</td>
<td style="text-align:right;">
0.67
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
3 weeks
</td>
<td style="text-align:right;">
0.79
</td>
<td style="text-align:right;">
0.70
</td>
<td style="text-align:right;">
0.81
</td>
<td style="text-align:right;">
0.71
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
4 weeks
</td>
<td style="text-align:right;">
1.06
</td>
<td style="text-align:right;">
0.75
</td>
<td style="text-align:right;">
1.09
</td>
<td style="text-align:right;">
0.79
</td>
</tr>
<tr grouplength="4">
<td colspan="5" style="border-bottom: 1px solid;">
<strong>Deaths</strong>
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
1 week
</td>
<td style="text-align:right;">
0.63
</td>
<td style="text-align:right;">
0.59
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
0.59
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
2 weeks
</td>
<td style="text-align:right;">
0.57
</td>
<td style="text-align:right;">
0.54
</td>
<td style="text-align:right;">
0.81
</td>
<td style="text-align:right;">
0.53
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
3 weeks
</td>
<td style="text-align:right;">
0.64
</td>
<td style="text-align:right;">
0.56
</td>
<td style="text-align:right;">
0.83
</td>
<td style="text-align:right;">
0.54
</td>
</tr>
<tr>
<td style="text-align:left;padding-left: 2em;" indentlevel="1">
4 weeks
</td>
<td style="text-align:right;">
0.83
</td>
<td style="text-align:right;">
0.64
</td>
<td style="text-align:right;">
0.82
</td>
<td style="text-align:right;">
0.62
</td>
</tr>
</tbody>
</table>

We considered alternative methods for creating ensembles from the
participating forecasts, using either a mean or median to combine either
weighted or unweighted forecasts (table 1). Across locations we observed
that the median outperformed the mean across all one through four week
horizons and both cases and death targets, for all but cases at the 1
week horizon. This held regardless of whether the component forecasts
were weighted or unweighted by their individual past performance.
Between methods of combination, weighting made little difference to the
performance of the median ensemble, but slightly improved performance of
the mean ensemble.

<div id="refs" class="references csl-bib-body">

<div id="ref-basshuysenThreeWaysWhich2021" class="csl-entry">

<span class="csl-left-margin">\[1\] </span><span
class="csl-right-inline">P. van Basshuysen, L. White, D. Khosrowi, and
M. Frisch, “Three Ways in Which Pandemic Models May Perform a Pandemic,”
*Erasmus Journal for Philosophy and Economics*, vol. 14, no. 1, pp.
110-127-110-127, 2021, doi:
[10.23941/ejpe.v14i1.582](https://doi.org/10.23941/ejpe.v14i1.582).</span>

</div>

<div id="ref-zelnerAccountingUncertaintyPandemic2021" class="csl-entry">

<span class="csl-left-margin">\[2\] </span><span
class="csl-right-inline">J. Zelner, J. Riou, R. Etzioni, and A. Gelman,
“Accounting for uncertainty during a pandemic,” *Patterns*, vol. 2, no.
8, 2021, doi:
[10.1016/j.patter.2021.100310](https://doi.org/10.1016/j.patter.2021.100310).</span>

</div>

<div id="ref-jamesUseMisuseMathematical2021" class="csl-entry">

<span class="csl-left-margin">\[3\] </span><span
class="csl-right-inline">L. P. James, J. A. Salomon, C. O. Buckee, and
N. A. Menzies, “The Use and Misuse of Mathematical Modeling for
Infectious Disease Policymaking: Lessons for the COVID-19 Pandemic,”
*Medical Decision Making*, vol. 41, no. 4, pp. 379–385, 2021, doi:
[10.1177/0272989X21990391](https://doi.org/10.1177/0272989X21990391).</span>

</div>

<div id="ref-reichCollaborativeMultiyearMultimodel2019"
class="csl-entry">

<span class="csl-left-margin">\[4\] </span><span
class="csl-right-inline">N. G. Reich *et al.*, “A collaborative
multiyear, multimodel assessment of seasonal influenza forecasting in
the United States,” *Proceedings of the National Academy of Sciences*,
vol. 116, no. 8, pp. 3146–3154, 2019, doi:
[10.1073/pnas.1812594116](https://doi.org/10.1073/pnas.1812594116).</span>

</div>

<div id="ref-cdcCoronavirusDisease20192020" class="csl-entry">

<span class="csl-left-margin">\[5\] </span><span
class="csl-right-inline">CDC, “Coronavirus Disease 2019 (COVID-19),”
*Centers for Disease Control and Prevention*. 2020. Accessed: Jan. 09,
2022. \[Online\]. Available:
<https://www.cdc.gov/coronavirus/2019-ncov/science/forecasting/forecasting.html></span>

</div>

<div id="ref-rayEnsembleForecastsCoronavirus2020e" class="csl-entry">

<span class="csl-left-margin">\[6\] </span><span
class="csl-right-inline">E. L. Ray *et al.*, “Ensemble Forecasts of
Coronavirus Disease 2019 (COVID-19) in the U.S.” Cold Spring Harbor
Laboratory Press, p. 2020.08.19.20177493, 2020. doi:
[10.1101/2020.08.19.20177493](https://doi.org/10.1101/2020.08.19.20177493).</span>

</div>

<div id="ref-bracherPreregisteredShorttermForecasting2021"
class="csl-entry">

<span class="csl-left-margin">\[7\] </span><span
class="csl-right-inline">J. Bracher *et al.*, “A pre-registered
short-term forecasting study of COVID-19 in Germany and Poland during
the second wave,” *Nature Communications*, vol. 12, no. 1, p. 5173,
2021, doi:
[10.1038/s41467-021-25207-0](https://doi.org/10.1038/s41467-021-25207-0).</span>

</div>

<div id="ref-funkShorttermForecastsInform2020" class="csl-entry">

<span class="csl-left-margin">\[8\] </span><span
class="csl-right-inline">S. Funk *et al.*, “Short-term forecasts to
inform the response to the Covid-19 epidemic in the UK,” *medRxiv*, p.
2020.11.11.20220962, 2020, doi:
[10.1101/2020.11.11.20220962](https://doi.org/10.1101/2020.11.11.20220962).</span>

</div>

<div id="ref-bicherSupportingCOVID19PolicyMaking2021" class="csl-entry">

<span class="csl-left-margin">\[9\] </span><span
class="csl-right-inline">M. Bicher *et al.*, “Supporting COVID-19
Policy-Making with a Predictive Epidemiological Multi-Model Warning
System,” *medRxiv*, p. 2020.10.18.20214767, 2021, doi:
[10.1101/2020.10.18.20214767](https://doi.org/10.1101/2020.10.18.20214767).</span>

</div>

<div id="ref-reichAccuracyRealtimeMultimodel2019" class="csl-entry">

<span class="csl-left-margin">\[10\] </span><span
class="csl-right-inline">N. G. Reich *et al.*, “Accuracy of real-time
multi-model ensemble forecasts for seasonal influenza in the U.S,” *PLoS
computational biology*, vol. 15, no. 11, p. e1007486, 2019, doi:
[10.1371/journal.pcbi.1007486](https://doi.org/10.1371/journal.pcbi.1007486).</span>

</div>

<div id="ref-johanssonOpenChallengeAdvance2019" class="csl-entry">

<span class="csl-left-margin">\[11\] </span><span
class="csl-right-inline">M. A. Johansson *et al.*, “An open challenge to
advance probabilistic forecasting for dengue epidemics,” *Proceedings of
the National Academy of Sciences*, vol. 116, no. 48, pp. 24268–24274,
2019, doi:
[10.1073/pnas.1909865116](https://doi.org/10.1073/pnas.1909865116).</span>

</div>

<div id="ref-viboudRAPIDDEbolaForecasting2018" class="csl-entry">

<span class="csl-left-margin">\[12\] </span><span
class="csl-right-inline">C. Viboud *et al.*, “The RAPIDD ebola
forecasting challenge: Synthesis and lessons learnt,” *Epidemics*, vol.
22, pp. 13–21, 2018, doi:
[10.1016/j.epidem.2017.08.002](https://doi.org/10.1016/j.epidem.2017.08.002).</span>

</div>

<div id="ref-buizzaIntroductionSpecialIssue2019" class="csl-entry">

<span class="csl-left-margin">\[13\] </span><span
class="csl-right-inline">R. Buizza, “Introduction to the special issue
on ‘25 years of ensemble forecasting’,” *Quarterly Journal of the Royal
Meteorological Society*, vol. 145, no. S1, pp. 1–11, 2019, doi:
[10.1002/qj.3370](https://doi.org/10.1002/qj.3370).</span>

</div>

<div id="ref-moranEpidemicForecastingMessier2016" class="csl-entry">

<span class="csl-left-margin">\[14\] </span><span
class="csl-right-inline">K. R. Moran *et al.*, “Epidemic Forecasting is
Messier Than Weather Forecasting: The Role of Human Behavior and
Internet Data Streams in Epidemic Forecast,” *The Journal of Infectious
Diseases*, vol. 214, no. suppl_4, pp. S404–S408, 2016, doi:
[10.1093/infdis/jiw375](https://doi.org/10.1093/infdis/jiw375).</span>

</div>

<div id="ref-europeancovid-19forecasthubEuropeanCOVID19Forecast2021"
class="csl-entry">

<span class="csl-left-margin">\[15\] </span><span
class="csl-right-inline">European Covid-19 Forecast Hub, “European
COVID-19 Forecast Hub.” covid19-forecast-hub-europe, 2021.Available:
<https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe></span>

</div>

<div id="ref-cramerReichlabCovid19forecasthubRelease2021"
class="csl-entry">

<span class="csl-left-margin">\[16\] </span><span
class="csl-right-inline">E. Cramer *et al.*,
“Reichlab/Covid19-forecast-hub: Release for Zenodo, 20210816,” 2021,
doi:
[10.5281/zenodo.5208210](https://doi.org/10.5281/zenodo.5208210).</span>

</div>

<div id="ref-wangReichlabCovidHubUtilsRepository2021" class="csl-entry">

<span class="csl-left-margin">\[17\] </span><span
class="csl-right-inline">S. Y. Wang *et al.*, “Reichlab/<span
class="nocase">covidHubUtils</span>: Repository release for Zenodo,”
2021, doi:
[10.5281/zenodo.5207940](https://doi.org/10.5281/zenodo.5207940).</span>

</div>

<div id="ref-bracherGermanPolishCOVID192020" class="csl-entry">

<span class="csl-left-margin">\[18\] </span><span
class="csl-right-inline">J. Bracher *et al.*, “The German and Polish
COVID-19 Forecast Hub.” 2020.Available:
<https://github.com/KITmetricslab/covid19-forecast-hub-de></span>

</div>

<div id="ref-dongInteractiveWebbasedDashboard2020" class="csl-entry">

<span class="csl-left-margin">\[19\] </span><span
class="csl-right-inline">E. Dong, H. Du, and L. Gardner, “An interactive
web-based dashboard to track COVID-19 in real time,” *The Lancet
Infectious Diseases*, vol. 20, no. 5, pp. 533–534, 2020, doi:
[10.1016/S1473-3099(20)30120-1](https://doi.org/10.1016/S1473-3099(20)30120-1).</span>

</div>

<div id="ref-europeancovid-19forecasthubCovid19forecasthubeuropeWiki"
class="csl-entry">

<span class="csl-left-margin">\[20\] </span><span
class="csl-right-inline">European Covid-19 Forecast Hub,
“Covid19-forecast-hub-europe: Wiki,” *GitHub*. Available:
<https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe></span>

</div>

<div id="ref-europeancovid-19forecasthubEuropeanCovid19Forecast"
class="csl-entry">

<span class="csl-left-margin">\[21\] </span><span
class="csl-right-inline">European Covid-19 Forecast Hub, “European
Covid-19 Forecast Hub.” Available:
<https://covid19forecasthub.eu/index.html></span>

</div>

<div id="ref-epiforecastsProjectECDCEuropean2021" class="csl-entry">

<span class="csl-left-margin">\[22\] </span><span
class="csl-right-inline">EpiForecasts, “Project: ECDC European COVID-19
Forecast Hub - Zoltar.” 2021.Available:
<https://www.zoltardata.com/project/238></span>

</div>

<div id="ref-reichZoltarForecastArchive2021" class="csl-entry">

<span class="csl-left-margin">\[23\] </span><span
class="csl-right-inline">N. G. Reich, M. Cornell, E. L. Ray, K. House,
and K. Le, “The Zoltar forecast archive, a tool to standardize and store
interdisciplinary prediction research,” *Scientific Data*, vol. 8, no.
1, p. 59, 2021, doi:
[10.1038/s41597-021-00839-5](https://doi.org/10.1038/s41597-021-00839-5).</span>

</div>

<div id="ref-nikosibosseScoringutilsUtilitiesScoring2020"
class="csl-entry">

<span class="csl-left-margin">\[24\] </span><span
class="csl-right-inline">Nikos I Bosse, Sam Abbott, EpiForecasts, and
Sebastian Funk, “Scoringutils: Utilities for Scoring and Assessing
Predictions.” 2020.Available:
<https://github.com/epiforecasts/scoringutils></span>

</div>

<div id="ref-bracherEvaluatingEpidemicForecasts2021" class="csl-entry">

<span class="csl-left-margin">\[25\] </span><span
class="csl-right-inline">J. Bracher, E. L. Ray, T. Gneiting, and N. G.
Reich, “Evaluating epidemic forecasts in an interval format,” *PLOS
Computational Biology*, vol. 17, no. 2, p. e1008618, 2021, doi:
[10.1371/journal.pcbi.1008618](https://doi.org/10.1371/journal.pcbi.1008618).</span>

</div>

<div id="ref-gneitingStrictlyProperScoring2007" class="csl-entry">

<span class="csl-left-margin">\[26\] </span><span
class="csl-right-inline">T. Gneiting and A. E. Raftery, “Strictly Proper
Scoring Rules, Prediction, and Estimation,” *Journal of the American
Statistical Association*, vol. 102, no. 477, pp. 359–378, 2007, doi:
[10.1198/016214506000001437](https://doi.org/10.1198/016214506000001437).</span>

</div>

<div id="ref-cramerEvaluationIndividualEnsemble2021" class="csl-entry">

<span class="csl-left-margin">\[27\] </span><span
class="csl-right-inline">E. Y. Cramer *et al.*, “Evaluation of
individual and ensemble probabilistic forecasts of COVID-19 mortality in
the US,” *medRxiv*, p. 2021.02.03.21250974, 2021, doi:
[10.1101/2021.02.03.21250974](https://doi.org/10.1101/2021.02.03.21250974).</span>

</div>

<div id="ref-genestVincentizationRevisited1992" class="csl-entry">

<span class="csl-left-margin">\[28\] </span><span
class="csl-right-inline">C. Genest, “Vincentization Revisited,” *The
Annals of Statistics*, vol. 20, no. 2, pp. 1137–1142, 1992, Accessed:
Jan. 09, 2022. \[Online\]. Available:
<https://www.jstor.org/stable/2242003></span>

</div>

<div id="ref-taylorCombiningProbabilisticForecasts2021"
class="csl-entry">

<span class="csl-left-margin">\[29\] </span><span
class="csl-right-inline">J. W. Taylor and K. S. Taylor, “Combining
Probabilistic Forecasts of COVID-19 Mortality in the United States,”
*European Journal of Operational Research*, 2021, doi:
[10.1016/j.ejor.2021.06.044](https://doi.org/10.1016/j.ejor.2021.06.044).</span>

</div>

</div>
