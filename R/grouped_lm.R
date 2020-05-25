#' @title Running linear model (`lm`) across multiple grouping variables.
#' @name grouped_lm
#' @return A tibble dataframe with tidy results from linear model.
#'
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"glance"`,
#'   which will return model summaries.
#' @param ... Additional arguments to `broom::tidy`, `broom::glance`, or
#'   `broom::augment` S3 method.
#' @inheritParams broomExtra::grouped_tidy
#' @inheritParams broomExtra::grouped_augment
#'
#' @importFrom broomExtra grouped_tidy grouped_glance grouped_augment
#' @importFrom rlang !! enquos
#' @importFrom stats lm glm
#'
#' @seealso \code{\link{grouped_slr}}, \code{\link{grouped_tidy}}
#'
#' @examples
#'
#' # loading needed libraries
#' library(ggplot2)
#'
#' # getting tidy output of results
#' grouped_lm(
#'   data = mtcars,
#'   grouping.vars = cyl,
#'   formula = mpg ~ am * wt,
#'   output = "tidy"
#' )
#'
#' # getting model summaries
#' # diamonds dataset from ggplot2
#' grouped_lm(
#'   data = diamonds,
#'   grouping.vars = c(cut, color),
#'   formula = price ~ carat * clarity,
#'   output = "glance"
#' )
#' @export

grouped_lm <- function(data,
                       grouping.vars,
                       ...,
                       output = "tidy",
                       tidy.args = list(conf.int = TRUE, conf.level = 0.95),
                       augment.args = list()) {

  # tidy results
  if (output == "tidy") {
    combined_df <-
      broomExtra::grouped_tidy(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = stats::lm,
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
        ..f = stats::lm,
        ...
      )
  }

  # augmented results
  if (output == "augment") {
    combined_df <-
      broomExtra::grouped_augment(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = stats::lm,
        ...,
        augment.args = augment.args
      )
  }

  # return the final dataframe
  return(combined_df)
}
