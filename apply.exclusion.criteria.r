#' Apply exclusion criteria function
#'
#' This function applies the study exclusion criteria and saves the results into
#' the parent environments results list
#' @param study_data The study data as a data frame. No default
#' @export
apply.exclusion.criteria <- function(
                                     study_data
                                     )
{
    ## Save number of patients enrolled during study period
    results$n_enrolled <<- nrow(study_data)
    ## Exclude observations with missing clinicians' priority data
    study_data <- study_data[!is.na(study_data$tc), ]
    ## Save number of patients remaining after excluding those with missing
    ## clinicians' priority data
    results$n_after_excluding_missing_priority <<- nrow(study_data)
    ## Exclude observations with missing outcome
    study_data <- study_data[!is.na(study_data$s30d), ]
    ## Save number of patients remaining after excluding those with missing
    ## outcome
    results$n_after_excluding_missing_outcome <<- nrow(study_data)
    return(study_data)
}    