#' @title Function to run generalized linear mixed-effects model (`glmer`)
#'   across multiple grouping variables.
#' @name grouped_glmer
#' @return A tibble dataframe with tidy results from linear model or model
#'   summaries.
#'
#' @inheritParams grouped_lm
#' @inheritDotParams lme4::glmer -control
#'
#' @importFrom broomExtra grouped_tidy grouped_glance grouped_augment
#' @export

# function body
grouped_glmer <- function(data,
                          grouping.vars,
                          ...,
                          output = "tidy",
                          tidy.args = list(
                            conf.int = TRUE,
                            conf.level = 0.95,
                            effects = "fixed",
                            conf.method = "Wald"
                          ),
                          augment.args = list()) {

  # tidy results
  if (output == "tidy") {
    combined_df <-
      broomExtra::grouped_tidy(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = lme4::glmer,
        ...,
        tidy.args = tidy.args
      )

    # add a column with significance labels if p-values are present
    if ("p.value" %in% names(combined_df)) {
      combined_df %<>% signif_column(data = ., p = p.value)
    }
  }

  # glance summary
  if (output == "glance") {
    # tidy results
    combined_df <-
      broomExtra::grouped_glance(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = lme4::glmer,
        ...
      )
  }

  # augmented results
  if (output == "augment") {
    combined_df <-
      broomExtra::grouped_augment(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = lme4::glmer,
        ...,
        augment.args = augment.args
      )
  }

  # return the final dataframe
  return(combined_df)
}
