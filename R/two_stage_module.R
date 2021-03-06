#' Two Stage Module
#'
#' This module runs a two-stage process. First, it retrieves samples from similar confounding factors before reducing the pool of
#' retrieved samples through using similarity among the predictor variables. This is done automatically using a confidence metric. Each
#' training sample is assigned a confidence value which is the average distance to samples of a different class minus the average distance to samples
#' of the same class. This value is normalized between 0 and 1. This is the last module that should be run.
#' @param CBRMSR A CBRMSR object
#' @import caret data.table
#' @examples
#' \dontrun{
#' CBRMSR <- two_stage_module(CBRMSR)
#' }
#' @export

two_stage_module <- function(CBRMSR) {
  tic("Classify Module Duration")
  # We'll create some empty lists to store the results in
  training_results <- list()
  testing_results <- list()
  F_Results <- list()
  KappaResults <- list()
  neighbor.list <- list()
  classframe <- CBRMSR$classframe
  retrieved_samples <- list()

  for(i in 1:CBRMSR$num) {
    training <- CBRMSR$training.sets[[i]]
    training_clinical_distance <- CBRMSR$training.clinical.distances[[i]]
    training_microarray_distance <- CBRMSR$training.microarray.distances[[i]]
    training_labels <- CBRMSR$training.labels[[i]]

    # Confidence matrices are explained below
    clinical_confidence_matrix <- get_confidence(training_clinical_distance, classframe)
    microarray_confidence_matrix <- get_confidence(training_microarray_distance, classframe)
    training_predictions <- rep(0, nrow(training))
    indices <- integer()
    for(k in 1:nrow(training)) {
      # query case is the sample we're currently interested in finding other cases for
      query_case <- rownames(training)[k]
      # get_clin gets the nearest clinical samples until it reaches the set confidence threshold
      clin_samples <- get_clin(k, training, training_clinical_distance, training_microarray_distance, clinical_confidence_matrix)
      # we create a temp distance matrix that's filled with only the retained clinical samples
      temp_distance_matrix <- data.frame(matrix(ncol = length(clin_samples), nrow = 1))
      colnames(temp_distance_matrix) <- clin_samples
      rownames(temp_distance_matrix) <- query_case
      row_index <- which(rownames(training_microarray_distance) == query_case)
      for(j in 1:length(clin_samples)) {
        col_index <- which(colnames(training_microarray_distance) == clin_samples[j])
        temp_distance_matrix[,j] <- training_microarray_distance[row_index, col_index]
      }
      # Sending the retained samples to knn and retrieving by microarray similarity
      indices <- knn_temp(temp_distance_matrix, classframe, microarray_confidence_matrix)
      label_table <- table(training_labels[indices])
      training_predictions[k] <- sample(names(which(label_table == max(label_table))), size = 1)
    }
    # the results of training
    training_result <- factor(training_predictions)
    training_confusion_matrix <- confusionMatrix(training_result, reference = training_labels)
    training_bacc <- (training_confusion_matrix[["byClass"]][["Balanced Accuracy"]]*100)
    training_results[i] <- training_bacc

    CBRMSR$training.confusion.matrices[[i]] <- training_confusion_matrix
    CBRMSR$training.predicted.labels[[i]] <- training_result


    # Testing
    # Testing is performed in a similar fashion to training, although samples are derived from the training set
    # Functions operate similar but are distinct for testing, mostly so I could troubleshoot but also to allow for
    # parameter manipulation

    testing <- CBRMSR$testing.sets[[i]]


    testing_clinical_distance <- CBRMSR$testing.clinical.distances[[i]]
    testing_microarray_distance <- CBRMSR$testing.microarray.distances[[i]]
    testing_labels <- CBRMSR$testing.labels[[i]]
    testing_clinical_confidence_matrix <- get_confidence_test(testing_clinical_distance, classframe)
    testing_microarray_confidence_matrix <- get_confidence_test(testing_microarray_distance, classframe)
    neighbor_matrix <- data.frame(matrix(ncol = ncol(testing_microarray_distance), nrow = nrow(testing_microarray_distance)))
    testing_predictions <- rep(0, nrow(testing))
    indices <- integer()
    for(t in 1:nrow(testing)) {
      query_case <- rownames(testing)[t]
      clin_samples <- get_clin_test(t, testing, testing_clinical_distance, testing_microarray_distance, clinical_confidence_matrix)
      temp_distance_matrix <- data.frame(matrix(ncol = length(clin_samples), nrow = 1))
      colnames(temp_distance_matrix) <- clin_samples
      rownames(temp_distance_matrix) <- query_case
      rownames(neighbor_matrix)[t] <- query_case
      row_index <- which(rownames(testing_microarray_distance) == query_case)
      for(j in 1:length(clin_samples)) {
        col_index <- which(colnames(testing_microarray_distance) == clin_samples[j])
        temp_distance_matrix[,j] <- testing_microarray_distance[row_index, col_index]
      }
      retrieved_samples[[t]] <- temp_distance_matrix
      names(retrieved_samples)[[t]] <- query_case
      indices <- knn_temp_test(temp_distance_matrix, classframe, testing_microarray_confidence_matrix)
      neighbor_matrix <- build_neighbor_matrix(neighbor_matrix, query_case, indices, testing_microarray_confidence_matrix)
      label_table <- table(training_result[indices])
      testing_predictions[t] <- sample(names(which(label_table == max(label_table))), size = 1)
    }
    testing_result <- factor(testing_predictions)
    testing_confusion_matrix <- confusionMatrix(testing_result, reference = testing_labels)
    testing_bacc <- (testing_confusion_matrix[["byClass"]][["Balanced Accuracy"]]*100)
    testing_results[i] <- testing_bacc


    FStat <- testing_confusion_matrix[["byClass"]][["F1"]]
    Kappa <- testing_confusion_matrix[["overall"]][["Kappa"]]
    testing_results[i] <- testing_bacc
    F_Results[i] <- FStat
    KappaResults[i] <- Kappa
    CBRMSR$testing.confusion.matrices[[i]] <- testing_confusion_matrix
    CBRMSR$testing.predicted.labels[[i]] <- testing_result


  }

  # Once we're done, we want to retrieve the results from testing and training and report them
  CBRMSR$retrieved.samples <- retrieved_samples
  training_overall_bacc <- sapply(training_results, mean)
  training_overall_bacc <- mean(training_overall_bacc, na.rm=T)
  cat("-- Average Balanced Accuracy during training was ",training_overall_bacc,"%  -- \n")


  testing_overall_bacc <- sapply(testing_results, mean)
  testing_overall_bacc <- mean(testing_overall_bacc, na.rm=T)
  cat("-- Average Balanced Accuracy during testing was ",testing_overall_bacc,"%  -- \n")

  overall_F <- sapply(F_Results, mean)
  overall_F <- mean(overall_F, na.rm=T)
  cat("-- Average F Stat during testing was ",overall_F,"  -- \n")

  overall_Kappa <- sapply(KappaResults, mean)
  overall_Kappa <- mean(overall_Kappa, na.rm=T)
  cat("-- Average Kappa statistic during testing was ",overall_Kappa,"  -- \n")


  toc()
  return(CBRMSR)
}

# this function retrieves the nearest clinical samples for the training data
get_clin <- function(k, training, training_clinical_distance, training_microarray_distance, clinical_confidence_matrix) {
    clin_indices <- knn_for_one(k, training_clinical_distance, classframe, clinical_confidence_matrix)
    sample_list <- list()
    for(i in 1:length(clin_indices)) {
      sample <- rownames(training_clinical_distance)[clin_indices[i]]
      sample_list[i] <- sample
    }
    return(sample_list)
}

build_neighbor_matrix <- function(neighbor_matrix, query_case, indices, testing_microarray_confidence_matrix) {
  index <- which(rownames(neighbor_matrix) == query_case)
  for(i in 1:length(indices)) {
    sample <- rownames(testing_microarray_confidence_matrix)[indices[i]]
    neighbor_matrix[index, i] <- sample
  }
  return(neighbor_matrix)
}

# this function retrieves the nearest clinical samples for the testing data
get_clin_test  <- function(t, testing, testing_clinical_distance, testing_microarray_distance, clinical_confidence_matrix) {
  clin_indices <- knn_for_one(t, testing_clinical_distance, classframe, clinical_confidence_matrix)
  sample_list <- list()
  for(i in 1:length(clin_indices)) {
    sample <- colnames(testing_clinical_distance)[clin_indices[i]]
    sample_list[i] <- sample
  }
  return(sample_list)
}

# This function retrieves clinical samples for one sample at a time.
knn_for_one <- function(i, distance_matrix, classframe, confidence_matrix) {
  ordered_neighbors <- order(distance_matrix[i, ])
  name_of_samples <- colnames(distance_matrix)[ordered_neighbors]
  current_confidence <- 0
  indices <- integer()
  for(i in 1:length(name_of_samples)) {
    index <- which(rownames(confidence_matrix) == name_of_samples[i])
    confidence <- confidence_matrix[index]
    current_confidence <- current_confidence + confidence
    # If you want to edit how many clinical samples are retrieved, you can do so here. I leave it high because it's
    # narrowed down with microarray data
    if(current_confidence > 25.0) {
      break
    }
    indices <- rbind(indices, index)
  }

  return(indices)
}

# This function pulls samples based on the microarray data. It's for the training sets
knn_temp <- function(distance_matrix, classframe, confidence_matrix) {
  distance_matrix <- as.matrix(distance_matrix)
  ordered_neighbors <- order(distance_matrix[1,])
  name_of_samples <- colnames(distance_matrix)[ordered_neighbors]
  current_confidence <- 0
  indices <- integer()
  for(i in 1:length(name_of_samples)) {
    index <- which(rownames(confidence_matrix) == name_of_samples[i])
    confidence <- confidence_matrix[index]
    current_confidence <- current_confidence + confidence
    # If you want to modify how many samples are retrieved during training based on the microarray data, do so here
    # Bear in mind that 1.0 does not equate to only 1 sample. Each sample has a confidence value between 0 and 1 so
    # only 1 (or possibly a small subset depending on data) of the training samples will have a 1.0 for confidence
    if(current_confidence > 1.0) {
      break
    }
    indices <- rbind(indices, index)
  }

  return(indices)
}

# This function pulls samples based on the microarray data. It's for the testing sets
knn_temp_test <- function(distance_matrix, classframe, confidence_matrix) {
  distance_matrix <- as.matrix(distance_matrix)
  ordered_neighbors <- order(distance_matrix[1,])
  name_of_samples <- colnames(distance_matrix)[ordered_neighbors]
  current_confidence <- 0
  indices <- integer()
  for(i in 1:length(name_of_samples)) {
    index <- which(rownames(confidence_matrix) == name_of_samples[i])
    confidence <- confidence_matrix[index]
    current_confidence <- current_confidence + confidence
    # If you want to modify how many samples are retrieved during testing based on the microarray data, do so here
    if(current_confidence > 3.0) {
      break
    }
    indices <- rbind(indices, index)
  }

  return(indices)
}

get_confidence <- function(dataframe, classframe) {
  confidence_frame <- matrix(0, ncol = 1, nrow = nrow(dataframe))
  rownames(confidence_frame) <- rownames(dataframe)
  colnames(confidence_frame) <- "confidence"
  for(i in 1:ncol(dataframe)) {
    sample <- colnames(dataframe)[i]
    index <- which(rownames(classframe) == sample)
    classification <- classframe[index,]
    classframe_subset <- classframe[-index,]
    same_class <- which(classframe == classification)
    different_class <- which(!classframe == classification)
    same_class_samples <- rownames(classframe)[same_class]
    different_class_samples <- rownames(classframe)[different_class]

    column <- as.data.frame(dataframe[,i])
    rownames(column) <- rownames(dataframe)
    names(column) <- rownames(column)[1]
    column <- as.data.frame(column[-1,])

    same_class_column <- column[same_class,]
    different_class_column <- column[different_class,]
    same_class_column <- na.omit(same_class_column)
    different_class_column <- na.omit(different_class_column)

    same_class_average <- mean(same_class_column)
    different_class_average <- mean(different_class_column)

    confidence <- different_class_average - same_class_average
    confidence_frame[i,] <- confidence
    confidence_frame <- normalize(confidence_frame)
  }
  return(confidence_frame)
}

get_confidence_test <- function(dataframe, classframe) {
  dataframe <- as.data.frame(t(dataframe))
  confidence_frame <- matrix(0, ncol = 1, nrow = nrow(dataframe))
  rownames(confidence_frame) <- rownames(dataframe)
  colnames(confidence_frame) <- "confidence"
  for(i in 1:ncol(dataframe)) {
    sample <- colnames(dataframe)[i]
    index <- which(rownames(classframe) == sample)
    classification <- classframe[index,]
    classframe_subset <- classframe[-index,]
    same_class <- which(classframe == classification)
    different_class <- which(!classframe == classification)
    same_class_samples <- rownames(classframe)[same_class]
    different_class_samples <- rownames(classframe)[different_class]

    column <- as.data.frame(dataframe[,i])
    rownames(column) <- rownames(dataframe)
    names(column) <- rownames(column)[1]
    column <- as.data.frame(column[-1,])

    same_class_column <- column[same_class,]
    different_class_column <- column[different_class,]
    same_class_column <- na.omit(same_class_column)
    different_class_column <- na.omit(different_class_column)

    same_class_average <- mean(same_class_column)
    different_class_average <- mean(different_class_column)

    confidence <- different_class_average - same_class_average
    confidence_frame[i,] <- confidence
    confidence_frame <- normalize(confidence_frame)
  }
  return(confidence_frame)
}

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
