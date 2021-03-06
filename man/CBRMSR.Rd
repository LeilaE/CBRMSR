% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CBRMSR.R
\name{CBRMSR}
\alias{CBRMSR}
\title{CBRMSR Class}
\description{
CBRMSR Class

CBRMSR Class
}
\details{
This is a class object to store all of the results performed with the modules of this package
}
\section{Public fields}{
\if{html}{\out{<div class="r6-fields">}}
\describe{
\item{\code{predictor}}{the dataset of predictor variables}

\item{\code{confounding}}{the dataset of confounding variables}

\item{\code{classframe}}{a column of sample names and a column of their class labels}

\item{\code{num}}{num is the number of folds when folding}

\item{\code{training.sets}}{all of the training sets after splitting or folding}

\item{\code{testing.sets}}{all of the testing sets after splitting or folding}

\item{\code{training.labels}}{the classification labels for the training sets}

\item{\code{testing.labels}}{the classification labels for the testing sets}

\item{\code{training.confounding.sets}}{subsetted confounding data for the training sets}

\item{\code{testing.confounding.sets}}{subsetted confounding data for the testing sets}

\item{\code{selected.features}}{which features were selected after feature selected}

\item{\code{feature.weights}}{feature weights after using BIRF}

\item{\code{balanced}}{a boolean value of whether or not class balancing was applied}

\item{\code{balanced.training.labels}}{the classification labels of the training set after balancing}

\item{\code{balanced.training.sets}}{the training datsets after balancing}

\item{\code{training.confounding.distances}}{the distance matrices of the training confounding data}

\item{\code{testing.confounding.distances}}{the distance matrices of the testing confounding data}

\item{\code{training.predictor.distances}}{the distance matrices of the training predictor data}

\item{\code{testing.predictor.distances}}{the distance matrices of the testing predictor data}

\item{\code{training.confusion.matrices}}{confusion matrices for the training sets}

\item{\code{training.predicted.labels}}{predicted classification labels for the training data}

\item{\code{testing.confusion.matrices}}{confusion matrices for the testing sets}

\item{\code{testing.predicted.labels}}{predicted classification labels for the testing data}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-new}{\code{CBRMSR$new()}}
\item \href{#method-clone}{\code{CBRMSR$clone()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-new"></a>}}
\if{latex}{\out{\hypertarget{method-new}{}}}
\subsection{Method \code{new()}}{
Create a new CBRMSR object.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{CBRMSR$new(predictor, confounding, classframe)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{predictor}}{A dataframe of predictor variables}

\item{\code{confounding}}{A dataframe of confounding variables}

\item{\code{classframe}}{A 2 column dataframe of sample names and classification labels}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
A new 'CBRMSR' object.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-clone"></a>}}
\if{latex}{\out{\hypertarget{method-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{CBRMSR$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
