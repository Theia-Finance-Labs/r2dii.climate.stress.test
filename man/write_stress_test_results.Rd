% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_results.R
\name{write_stress_test_results}
\alias{write_stress_test_results}
\title{Write stress test reports to output dir}
\usage{
write_stress_test_results(
  results_list,
  iter_var,
  shock_scenario,
  scenario_geography,
  carbon_price_model,
  risk_type,
  financial_stimulus,
  output_path
)
}
\arguments{
\item{results_list}{A list of st results.}

\item{iter_var}{String holding name of iteration variable.}

\item{shock_scenario}{String holding shock scenario name.}

\item{scenario_geography}{String holding scenario geography name.}

\item{carbon_price_model}{String holding carbon price model for trisk.}

\item{risk_type}{String holding the risk type.}

\item{financial_stimulus}{Numeric value additional support for low carbon technologies.}

\item{output_path}{String holding path to output dir.}
}
\description{
Stress test results are  exported to the output dir.
}
