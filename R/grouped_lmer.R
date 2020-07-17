#' @title Linear mixed-effects model (`lmer`) across multiple grouping
#'   variables.
#' @name grouped_lmer
#' @return A tibble dataframe with tidy results from a linear mixed-effects
#'   model. Note that *p*-value is computed using `parameters::p_value`.
#'
#' @inheritParams grouped_lm
#' @inheritDotParams lme4::lmer -control
#' @inheritParams parameters::p_value
#'
#' @importFrom dplyr left_join
#' @importFrom broomExtra grouped_tidy grouped_glance grouped_augment
#'
#' @examples
#' \donttest{
#' # for reproducibility
#' set.seed(123)
#'
#' # loading libraries containing data
#' library(gapminder)
#'
#' # getting tidy output of results
#' # let's use only subset of the data
#' groupedstats::grouped_lmer(
#'   data = gapminder,
#'   formula = scale(lifeExp) ~ scale(gdpPercap) + (gdpPercap | continent),
#'   grouping.vars = year,
#'   REML = FALSE,
#'   tidy.args = list(effects = "fixed", conf.int = TRUE, conf.level = 0.95),
#'   output = "tidy"
#' )
#' }
#' @export

# function body
grouped_lmer <- function(data,
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
    tidy_df <-
      broomExtra::grouped_tidy(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = lme4::lmer,
        ...,
        tidy.args = tidy.args
      )

    # extracting p-values
    p_df <-
      grouped_p_value(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = lme4::lmer,
        ...
      )

    # joining two things together
    combined_df <- suppressMessages(dplyr::left_join(x = tidy_df, y = p_df))

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
        ..f = lme4::lmer,
        ...
      )
  }

  # augmented results
  if (output == "augment") {
    combined_df <-
      broomExtra::grouped_augment(
        data = data,
        grouping.vars = {{ grouping.vars }},
        ..f = lme4::lmer,
        ...,
        augment.args = augment.args
      )
  }

  # return the final dataframe
  return(combined_df)
}
