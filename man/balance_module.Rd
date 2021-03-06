% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/balance_module.R
\name{balance_module}
\alias{balance_module}
\title{Class Balancing Module}
\usage{
balance_module(CBRMSR, method = c("smote", "ADASYN"), ratio = 0.8)
}
\arguments{
\item{CBRMSR}{A CBRMSR object}

\item{method}{The balancing method. Currently smote, and ADASYN are supported}

\item{ratio}{Number between 0 and 1 that indicates the desired ratio between minority samples and majority samples}
}
\description{
This module allows for the balancing of an unbalanced dataset through either SMOTE or ADASYN.
}
\examples{
\dontrun{
# Balancing with SMOTE
CBRMSR <- balance_module(CBRMSR, method = "smote", ratio = 0.8)
# Balancing with ADASYN
CBRMSR <- balance_module(CBRMSR, method = "ADASYN")
}
}
