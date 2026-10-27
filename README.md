# Singapore and UK cancer federated analysis
For the federated analysis between the UK and Singapore, the Singapore TRE requires a standalone R script that will produce the same result on the same data as a 5s-TES analysis in the UK TRE(s?).

The R script `runIncidence.R` will run an incidence analysis.
There are comments throughout giving hints on how the analysis can be modified, though this is not complete.
The full set of parameters is best described in the documentation for [generateConceptCohortSet](https://darwin-eu.github.io/CDMConnector/reference/generateConceptCohortSet.html), [generateDenominatorCohortSet](https://darwin-eu.github.io/IncidencePrevalence/reference/generateDenominatorCohortSet.html), and [estimateIncidence](https://darwin-eu.github.io/IncidencePrevalence/reference/estimateIncidence.html), and the vignettes on the relevant packages.

## Outcome cohort
The outcome cohort is anyone with a diagnosis of breast cancer (concept_id 81251).
This can be expanded to multiple cohorts, or a cohort with more than one code.

## Denominator cohort
This describes the cohort of people who could develop breast cancer.
Currently, it's people assigned either sex at birth, with any age from 0 to 150.
There are lots of options to stratify this cohort.
People are included in this cohort if observed between 2009 and 2025.

## Estimating incidence
The script uses the outcome and denominator cohort definitions to estimate the incidence of the outcome in the denominator cohort.
This uses the defaults from [estimateIncidence](https://darwin-eu.github.io/IncidencePrevalence/reference/estimateIncidence.html), estimating incidence per 100,000 person years for each year, with an infinite washout period.
This is then written as a summarisedResult to a file, currently `output/incidence.csv`.