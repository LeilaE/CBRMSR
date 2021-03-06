% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/knn_combine.R
\name{knn_combine}
\alias{knn_combine}
\title{K-Nearest Neighbor that Combines Results from Two Distance Matrices}
\usage{
knn_combine(data, first_distance, second_distance, training_labels, k)
}
\arguments{
\item{data}{The matrix containing the data to classify}

\item{first_distance}{The first distance matrix}

\item{second_distance}{The second distance matrix}

\item{training_labels}{The classification labels to compare to}

\item{K}{The value of K}
}
\description{
This runs the KNN classification algorithm that accepts 2 distance matrices;
finding the nearest neighbors from both and returning the majority result
}
