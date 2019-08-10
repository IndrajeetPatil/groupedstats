#' @title Function to run generalized linear mixed-effects model (glmer) across multiple
#'   grouping variables.
#' @name grouped_glmer
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model or model
#'   summaries.
#'
#' @inheritParams grouped_lm
#'
#' @importFrom lme4 glmer
#' @importFrom broomExtra tidy glance augment
#'
#' @seealso grouped_lmer
#'
#' @examples
#'
#' # for reproducibility
#' set.seed(123)
#'
#' # categorical outcome; binomial family
#' groupedstats::grouped_glmer(
#'   formula = Survived ~ Age + (Age | Class),
#'   family = stats::binomial(link = "probit"),
#'   data = dplyr::sample_frac(groupedstats::Titanic_full, size = 0.3),
#'   grouping.vars = Sex
#' )
#' @export

grouped_glmer <- function(data,
                          grouping.vars,
                          ...,
                          output = "tidy",
                          tidy.args = list(conf.int = TRUE, conf.level = 0.95),
                          augment.args = list()) {

  # tidy results
  if (output == "tidy") {
    combined_df <- broomExtra::grouped_tidy(
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
    combined_df <- broomExtra::grouped_glance(
      data = data,
      grouping.vars = {{ grouping.vars }},
      ..f = lme4::glmer,
      ...
    )
  }

  # augmented results
  if (output == "augment") {
    combined_df <- broomExtra::grouped_augment(
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
