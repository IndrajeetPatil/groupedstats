#' @title Confidence intervals for partial eta-squared and omega-squared for
#'   linear models.
#' @name lm_effsize_ci
#' @author Indrajeet Patil
#' @description This function will convert a linear model object to a dataframe
#'   containing statistical details for all effects along with partial
#'   eta-squared effect size and its confidence interval.
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
#'
#' @importFrom sjstats eta_sq omega_sq
#' @importFrom stats anova na.omit lm
#' @importFrom tibble as_tibble
#'
#' @examples
#' # model
#' set.seed(123)
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
                          nboot = 500) {

  # based on the class, get the tidy output using broom
  if (class(object)[[1]] == "lm") {
    aov_df <-
      broomExtra::tidy(stats::anova(object = object))
  } else if (class(object)[[1]] %in% c("aov", "anova")) {
    aov_df <- broomExtra::tidy(x = object)
  } else if (class(object)[[1]] == "aovlist") {
    if (dim(dplyr::filter(broomExtra::tidy(object), stratum == "Within"))[[1]] != 0L) {
      aov_df <- broomExtra::tidy(x = object) %>%
        dplyr::filter(.data = ., stratum == "Within")
    } else {
      aov_df <- broomExtra::tidy(x = object)
    }
  } else {
    aov_df <- broomExtra::tidy(x = object)
  }

  # creating numerator and denominator degrees of freedom
  if (dim(dplyr::filter(aov_df, term == "Residuals"))[[1]] == 1L) {
    # create a new column for residual degrees of freedom
    aov_df$df2 <- aov_df$df[aov_df$term == "Residuals"]
  }

  # cleaning up the dataframe
  aov_df %<>%
    dplyr::select(
      .data = ., -c(base::grep(pattern = "sq", x = names(.)))
    ) %>%
    # remove NAs, which would remove the row containing Residuals (redundant at this point)
    dplyr::rename(.data = ., df1 = df) %>%
    stats::na.omit(.) %>%
    tibble::as_tibble(x = .)

  # computing the effect sizes using sjstats
  if (effsize == "eta") {
    # creating dataframe of partial eta-squared effect size and its CI with sjstats
    effsize_df <- suppressWarnings(sjstats::eta_sq(
      model = object,
      partial = partial,
      ci.lvl = conf.level,
      n = nboot
    ))
  } else {
    # creating dataframe of partial omega-squared effect size and its CI with sjstats
    effsize_df <- suppressWarnings(sjstats::omega_sq(
      model = object,
      partial = partial,
      ci.lvl = conf.level,
      n = nboot
    ))
  }

  if (class(object)[[1]] == "aovlist") {
    if (dim(dplyr::filter(effsize_df, stratum == "Within"))[[1]] != 0L) {
      effsize_df %<>%
        dplyr::filter(.data = ., stratum == "Within")
    }
  }

  # combining the dataframes
  # merge the two preceding pieces of information by the common element of Effect
  combined_df <- dplyr::left_join(
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
      dplyr::select(.data = ., -c(base::grep(pattern = "stratum", x = names(.)))) %>%
      dplyr::mutate(.data = ., stratum = "Within")
  }

  # returning the final dataframe
  return(combined_df)
}
