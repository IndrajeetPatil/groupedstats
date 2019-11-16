#' @title Confidence intervals for (partial) eta-squared and omega-squared for
#'   linear models.
#' @name lm_effsize_ci
#' @author Indrajeet Patil
#' @description This function will convert a linear model object to a dataframe
#'   containing statistical details for all effects along with effect size
#'   measure and its confidence interval. For more details, see
#'   `parameters::eta_squared` and `parameters::omega_squared`.
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
#' @param nboot Number of bootstrap samples for confidence intervals for partial
#'   eta-squared and omega-squared (Default: `500`).
#' @param ... Currently ignored.
#' @inheritParams sjstats::omega_sq
#'
#' @importFrom sjstats eta_sq omega_sq
#' @importFrom stats anova na.omit lm
#' @importFrom tibble as_tibble
#' @importFrom rlang exec
#' @importFrom tidyr drop_na
#' @importFrom dplyr matches everything
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
                          nboot = 500,
                          method = c("dist", "quantile"),
                          ...) {

  # based on the class, get the tidy output using broom
  if (class(object)[[1]] == "lm") {
    aov_df <- broomExtra::tidy(stats::anova(object))
  } else if (class(object)[[1]] == "aovlist") {
    if (dim(dplyr::filter(broomExtra::tidy(object), stratum == "Within"))[[1]] != 0L) {
      aov_df <- dplyr::filter(.data = broomExtra::tidy(object), stratum == "Within")
    } else {
      aov_df <- broomExtra::tidy(object)
    }
  } else {
    aov_df <- broomExtra::tidy(object)
  }

  # creating numerator and denominator degrees of freedom
  if (dim(dplyr::filter(aov_df, term == "Residuals"))[[1]] == 1L) {
    # create a new column for residual degrees of freedom
    aov_df$df2 <- aov_df$df[aov_df$term == "Residuals"]
  }

  # remove NAs, which would remove the row containing Residuals
  # (redundant at this point)
  aov_df %<>%
    dplyr::select(.data = ., -c(grep(pattern = "sq", x = names(.)))) %>%
    dplyr::rename(.data = ., df1 = df) %>%
    tidyr::drop_na(.) %>%
    tibble::as_tibble(x = .)

  # function to compute effect sizes
  if (effsize == "eta") {
    .f <- sjstats::eta_sq
  } else {
    .f <- sjstats::omega_sq
  }

  # computing effect size
  effsize_df <-
    rlang::exec(
      .fn = .f,
      model = object,
      partial = partial,
      ci.lvl = conf.level,
      n = nboot,
      method = method
    )

  if (class(object)[[1]] == "aovlist") {
    if (dim(dplyr::filter(effsize_df, stratum == "Within"))[[1]] != 0L) {
      effsize_df %<>% dplyr::filter(.data = ., stratum == "Within")
    }
  }

  # combining the dataframes
  # merge the two preceding pieces of information by the common element of Effect
  combined_df <-
    dplyr::left_join(
      x = aov_df,
      y = effsize_df,
      by = "term"
    ) %>% # reordering columns
    dplyr::select(
      .data = .,
      term,
      F.value = statistic,
      dplyr::matches("^df"),
      p.value,
      dplyr::everything()
    ) %>%
    tibble::as_tibble(x = .)

  # in case of within-subjects design, the stratum columns will be unnecessarily added
  if ("stratum.x" %in% names(combined_df)) {
    combined_df %<>%
      dplyr::select(.data = ., -c(grep(pattern = "stratum", x = names(.)))) %>%
      dplyr::mutate(.data = ., stratum = "Within")
  }

  # returning the final dataframe
  return(combined_df)
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
#'   conf.level = 0.99,
#'   nboot = 20
#' )
#' @export

# function body
lm_effsize_standardizer <- function(object,
                                    effsize = "eta",
                                    partial = TRUE,
                                    conf.level = 0.95,
                                    nboot = 500,
                                    method = c("dist", "quantile")) {

  # creating a dataframe with effect size and its CI
  groupedstats::lm_effsize_ci(
    object = object,
    effsize = effsize,
    partial = partial,
    conf.level = conf.level,
    nboot = nboot,
    method = method
  ) %>% # renaming the effect size to standard term 'estimate'
    dplyr::rename(.data = ., estimate = dplyr::matches("etasq$|omegasq$"))
}
