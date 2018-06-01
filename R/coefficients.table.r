#' Make learner weight, risk, and AUROCC table function
#'
#' This function generates a risk, learner weight and learner-AUROCC table.
#' @param study_sample The study_sample list. No default.
#' @param superlearner_object_path The path to the SuperLearner object as generated from the SuperLearner::SuperLearner() method. Default: "./superlearner.rds"
#' @export
coefficients.table <- function(
                               study_sample,
                               superlearner_object_path = "./superlearner.rds"
                               )
{
    ## User Mikkos answer at https://stackoverflow.com/questions/35790652/removing-words-featured-in-character-vector-from-string
    removeWords <- function(str, stopwords) {
        x <- unlist(strsplit(str, " "))
        paste(x[!x %in% stopwords], collapse = " ")
    }
    ## Load SuperLearner object
    superlearner_object <- readRDS(superlearner_object_path)
    ## Error handling
    if (!is.list(superlearner_object)) stop("Superlearner object is not a list.")
    ## Set learner names
    learner_names <- unlist(lapply(superlearner_object$SL.library$library$predAlgorithm,
                                   function(name) strsplit(name, ".", fixed = TRUE)))
    learner_names <- learner_names[!(learner_names %in% "SL")]
    ## Define pretty names
    pretty_names <- c("SuperLearner",
                      "GLMnet",
                      "GLM",
                      "Random Forest",
                      "XGboost",
                      "GAM")
    ## Get predictons on training set from each model
    preds <- superlearner_object$library.predict
    preds <- cbind(superlearner_object$SL.predict, preds)
    colnames(preds) <- pretty_names
    ## Initiate list and save preds columns, i.e. model predictions, to list
    l_of_predictions <- list()
    for (i in colnames(preds)){
        l_of_predictions[[i]] <- preds[, i]
    }
    ## Calculate AUC of learners
    auroccs <- lapply(l_of_predictions,
                      function (model){
                          pred <- ROCR::prediction(as.numeric(model),
                                                   study_sample[["outcome_train"]])
                          perf <- ROCR::performance(pred, measure = "auc", x.measure = "cutoff")@y.values
                          return(perf)
                      })
    ## Set table
    t_coeff_risk <- data.frame(Learner = pretty_names,
                               Risk = c(NA, superlearner_object$cvRisk),
                               Weight = c(NA, superlearner_object$coef),
                               AUROCC = unlist(auroccs),
                               stringsAsFactors = FALSE)
    ## Round columns
    t_coeff_risk[] <- lapply(t_coeff_risk, function(x) if(!is.character(x)) sprintf("%.3f", x) else x)
    ## Format table
    coeff_risk_table <- print(xtable(t_coeff_risk,
                                      caption = "Cross validated risk, weight and area under the receiver operating curve characteristics (AUROCC) in the complete training sample for SuperLearner and each included learner",
                                      label = "tab:coeff_risk"),
                               include.rownames = FALSE,
                               print.results = FALSE)
    coeff_risk_table <- add.star.caption(coeff_risk_table, "NA is not applicable. The SuperLearner was not cross validated, only the included learners were. Abbreviations: GAM Generalises Additive Model, GLM Generalised Linear Model, XGboost Extreme Gradient Boosting Machine")
    return(coeff_risk_table)
}

