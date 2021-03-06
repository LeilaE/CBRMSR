% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_CBRMSR.R
\name{create_CBRMSR}
\alias{create_CBRMSR}
\title{Create a CBRMSR object}
\usage{
create_CBRMSR(predictor, confounding, classframe)
}
\arguments{
\item{predictor}{A dataset of predictor values}

\item{confounding}{An optional dataset of confounding variables (such as clinical data) to draw samples
from first.}

\item{classframe}{A two column dataframe of sample names and their classification label}
}
\description{
CHANGE
}
\examples{
\dontrun{
data(microarray)
data(clinical)
data(classframe)
CBRMSR <- create_CBRMSR(microarray, clinical, classframe)
}
}
