#' @title Function to run generalized linear model (glm) across multiple
#'   grouping variables.
#' @name grouped_glm
#' @aliases grouped_glm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model.
#'
#' @inheritParams grouped_lm
#'
#' @importFrom magrittr "%<>%"
#' @importFrom broomExtra grouped_tidy grouped_glance grouped_augment
#' @importFrom rlang !! enquos
#'
#' @seealso \code{\link{grouped_lm}}, \code{\link{grouped_lmer}},
#' \code{\link{grouped_glmer}}
#'
#' @examples
#'
#' # to get tidy output
#' groupedstats::grouped_glm(
#'   data = groupedstats::Titanic_full,
#'   formula = Survived ~ Sex,
#'   grouping.vars = Class,
#'   family = stats::binomial(link = "logit")
#' )
#'
#' # to get glance output
#' groupedstats::grouped_glm(
#'   data = groupedstats::Titanic_full,
#'   formula = Survived ~ Sex,
#'   grouping.vars = Class,
#'   family = stats::binomial(link = "logit"),
#'   output = "glance"
#' )
#' @export

grouped_glm <- function(data,
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
      ..f = stats::glm,
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
      ..f = stats::glm,
      ...
    )
  }

  if (output == "augment") {
    # tidy results
    combined_df <- broomExtra::grouped_augment(
      data = data,
      grouping.vars = !!rlang::enquo(grouping.vars),
      ..f = stats::glm,
      ...,
      augment.args = augment.args
    )
  }

  return(combined_df)
}
