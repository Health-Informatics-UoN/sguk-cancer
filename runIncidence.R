# Currently, this pulls database credentials from the environment.
# If you'd rather supply them directly to the script, here's where to do it

con <- DBI::dbConnect(
  drv = RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME"),
  host = Sys.getenv("DB_HOST"),
  port = Sys.getenv("DB_PORT"),
  password = Sys.getenv("DB_PASSWORD"),
  user = Sys.getenv("DB_USER"),
  bigint = "numeric"
)

# I imagine you will want to use a different set of schemata here.
# The scripts write to the schema named in writeSchema.
# If possible, I would give the researchers their own schema to write to.

cdm <- CDMConnector::cdmFromCon(
    con = con,
    cdmSchema = "public",
    writeSchema = "public",
    cdmName = "delphi_synthetic",
    # It's also possible to specify a prefix for the cohort tables.
    # If that's helpful, e.g. for dropping the tables after, supply one here.
    writePrefix = NULL
  )

# Generating the outcome cohort
# -----------------------------
# This creates an outcome cohort from a set of concept ids

# You can rename this without knockon effects to the later analysis, just make sure it has no caps, no spaces
outcomeCohortTableName <- "breast_cancer"

cdm <- CDMConnector::generateConceptCohortSet(
  cdm = cdm,
  name = outcomeCohortTableName,
  # Using the code specified
  conceptSet = list(breastCancer = 81251)
  # If you want to either look at multiple outcomes, or have multiple concept_ids for one outcome, follow this example
  # conceptSet = list(diabetes = c(201254, 201826), breastCancer = 81251)
)

# Generating a denominator cohort
# -------------------------------
# This creates a denominator cohort of both sexes, all ages (unless you have anyone over 150).
# If you want to change who is a candidate for getting your condition, or create different sub-populations, this is where to do it.

denominatorCohortTableName <- "bc_denom"

cdm <- IncidencePrevalence::generateDenominatorCohortSet(
  cdm = cdm,
  # The name isn't important, except that you need to use it later when estimating incidence
  name = denominatorCohortTableName,
  # You can specify one or more of "Both", "Male", "Female" to break it down by sex
  sex="Both",
  # sex = c("Both", "Male", "Female")
  # You can also break down the analysis by age
  ageGroup = list(c(0, 150)),
  # ageGroup = list(c(0,17), c(18,34), c(35,60))
  cohortDateRange = c(as.Date("2009-1-1"), as.Date("2025-1-1"))
)

inc <- IncidencePrevalence::estimateIncidence(
  cdm = cdm,
  denominatorTable = denominatorCohortTableName,
  outcomeTable = outcomeCohortTableName
  # Here, you can specify lots of options, including:
  # interval = "years", # Time intervals over which incidence is estimated
  # outcomeWashout = 0 # The number of days used for a 'washout' period between the end of one outcome and an individual starting to contribute time at risk.
) |> # This pipes the results into saving a csv for later analysis.
  omopgenerics::exportSummarisedResult(
    # minCellCount = 0, # by default, any result covering fewer than five people is omitted, substituting NA. You can specify your own threshold here
    fileName = "output/incidence.csv"
  )

CDMConnector::cdmDisconnect(cdm) # If you specified a writePrefix above, you can add `dropPrefixTables = TRUE` and these tables will be dropped from your database. If not, they will persist.