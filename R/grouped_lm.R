#' @title Function to run linear model (lm) across multiple grouping variables.
#' @name grouped_lm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model.
#'
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"glance"`,
#'   which will return model summaries.
#' @inheritParams broomExtra::grouped_tidy
#' @inheritParams broomExtra::grouped_augment
#'
#' @importFrom magrittr "%<>%"
#' @importFrom broomExtra grouped_tidy grouped_glance grouped_augment
#' @importFrom rlang !! enquos
#' @importFrom stats lm glm
#'
#' @seealso \code{\link{grouped_slr}}
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
  if (output == "tidy") {
    # tidy results
    combined_df <- broomExtra::grouped_tidy(
      data = data,
      grouping.vars = !!rlang::enquo(grouping.vars),
      ..f = stats::lm,
      ...,
      tidy.args = tidy.args
    )

    # add a column with significance labels if p-values are present
    if ("p.value" %in% names(combined_df)) {
      combined_df %<>%
        signif_column(data = ., p = p.value)
    }
  }

  if (output == "glance") {
    # tidy results
    combined_df <- broomExtra::grouped_glance(
      data = data,
      grouping.vars = !!rlang::enquo(grouping.vars),
      ..f = stats::lm,
      ...
    )
  }

  if (output == "augment") {
    # tidy results
    combined_df <- broomExtra::grouped_augment(
      data = data,
      grouping.vars = !!rlang::enquo(grouping.vars),
      ..f = stats::lm,
      ...,
      augment.args = augment.args
    )
  }

  return(combined_df)
}
