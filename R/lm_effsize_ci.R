#' @title Confidence intervals for (partial) eta-squared and omega-squared for
#'   linear models.
#' @name lm_effsize_ci
#' @author Indrajeet Patil
#' @description This function will convert a linear model object to a dataframe
#'   containing statistical details for all effects along with effect size
#'   measure and its confidence interval. For more details, see
#'   `effectsize::eta_squared` and `effectsize::omega_squared`.
#' @return A dataframe with results from `stats::lm()` with partial eta-squared,
#'   omega-squared, and bootstrapped confidence interval for the same.
#'
#' @param object The linear model object (can be of class `lm`, `aov`, `anova`, or
#'   `aovlist`).
#' @param effsize Character describing the effect size to be displayed: `"eta"`
#'   (default) or `"omega"`.
#' @param partial Logical that decides if partial eta-squared or omega-squared
#'   are returned (Default: `TRUE`). If `FALSE`, eta-squared or omega-squared
#'   will be returned. Valid only for objects of class `lm`, `aov`, `anova`, or
#'   `aovlist`.
#' @param conf.level Numeric specifying Level of confidence for the confidence
#'   interval (Default: `0.95`).
#' @param ... Ignored.
#'
#' @importFrom effectsize eta_squared omega_squared
#' @importFrom broomExtra tidy_parameters
#' @importFrom parameters standardize_names
#' @importFrom stats anova na.omit lm
#' @importFrom rlang exec
#' @importFrom dplyr matches everything contains
#' @importFrom magrittr "%>%" "%<>%"
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#'
#' # model
#' mod <-
#'   stats::aov(
#'     formula = mpg ~ wt + qsec + Error(disp / am),
#'     data = mtcars
#'   )
#'
#' # dataframe with effect size and confidence intervals
#' groupedstats::lm_effsize_ci(mod)
#' @export

# defining the function body
lm_effsize_ci <- function(object,
                          effsize = "eta",
                          partial = TRUE,
                          conf.level = 0.95,
                          ...) {
  # for `lm` objects, `anova` object should be created
  if (class(object)[[1]] == "lm") object <- stats::anova(object)

  # stats details
  stats_df <- broomExtra::tidy_parameters(object, ...)

  # creating numerator and denominator degrees of freedom
  if (dim(dplyr::filter(stats_df, term == "Residuals"))[[1]] > 0L) {
    # create a new column for residual degrees of freedom
    # always going to be the last column
    stats_df$df2 <- stats_df$df[nrow(stats_df)]
  }

  # function to compute effect sizes
  if (effsize == "eta") {
    .f <- effectsize::eta_squared
  } else {
    .f <- effectsize::omega_squared
  }

  # computing effect size
  effsize_df <-
    rlang::exec(
      .fn = .f,
      model = object,
      partial = partial,
      ci = conf.level
    ) %>%
    parameters::standardize_names(data = ., style = "broom") %>%
    dplyr::filter(.data = ., !grepl(pattern = "Residuals", x = term, ignore.case = TRUE)) %>%
    dplyr::select(.data = ., -dplyr::matches("group"))

  # combine them in the same place
  dplyr::right_join(
    x = dplyr::filter(.data = stats_df, !is.na(statistic)), # for `aovlist` objects
    y = effsize_df,
    by = "term"
  ) %>% # renaming to standard term 'estimate'
    dplyr::rename("df1" = "df", "F.value" = "statistic")
}

#' @title Standardize a dataframe with effect sizes for `aov`, `lm`, `aovlist`,
#'   etc. objects.
#' @description The difference between `lm_effsize_ci` and
#'   `lm_effsize_standardizer` is that the former has more opinionated column
#'   naming, while the latter doesn't. The latter can thus be more helpful in
#'   writing a wrapper around this function.
#' @name lm_effsize_standardizer
#'
#' @inheritParams lm_effsize_ci
#'
#' @examples
#' set.seed(123)
#' groupedstats::lm_effsize_standardizer(
#'   object = stats::lm(formula = brainwt ~ vore, data = ggplot2::msleep),
#'   effsize = "eta",
#'   partial = FALSE,
#'   conf.level = 0.99
#' )
#' @export

# function body
lm_effsize_standardizer <- function(object,
                                    effsize = "eta",
                                    partial = TRUE,
                                    conf.level = 0.95,
                                    ...) {

  # creating a dataframe with effect size and its CI
  groupedstats::lm_effsize_ci(
    object = object,
    effsize = effsize,
    partial = partial,
    conf.level = conf.level
  ) %>% # renaming the effect size to standard term 'estimate'
    dplyr::rename(.data = ., estimate = dplyr::matches("eta|omega"))
}
