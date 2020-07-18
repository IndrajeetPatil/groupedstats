#' @title Function to run proportion test on grouped data.
#' @name grouped_proptest
#' @return Dataframe with percentages and statistical details from a proportion
#'  test.
#'
#' @param ... Currently ignored.
#' @inheritParams broomExtra::grouped_tidy
#' @param measure A variable for which proportion test needs to be carried out
#'  for each combination of levels of factors entered in `grouping.vars`.
#'
#' @importFrom tidyr nest unnest spread
#' @importFrom broomExtra tidy
#' @importFrom stats chisq.test
#' @importFrom rlang enquos
#' @importFrom dplyr group_by_at group_modify ungroup group_vars select
#' @importFrom dplyr count left_join
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#'
#' groupedstats::grouped_proptest(
#'   data = mtcars,
#'   grouping.vars = cyl,
#'   measure = am
#' )
#' @export

# function body
grouped_proptest <- function(data, grouping.vars, measure, ...) {
  # creating a grouped dataframe
  df_grouped <- dplyr::group_by_at(data, rlang::enquos(grouping.vars))

  # extracting grouping variables as a character
  grouping_vars <- dplyr::group_vars(df_grouped)

  # calculating percentages and running chi-squared test
  df_grouped %>%
    {
      dplyr::left_join(
        x = (.) %>%
          dplyr::count({{ measure }}) %>%
          dplyr::mutate(perc = paste(specify_decimal_p((n / sum(n)) * 100, k = 2), "%", sep = "")) %>%
          dplyr::select(-n) %>%
          tidyr::spread(data = ., key = {{ measure }}, value = perc),
        y = (.) %>%
          dplyr::group_modify(.f = ~ chisq_test_safe(., {{ measure }})),
        by = grouping_vars
      )
    } %>%
    dplyr::ungroup(.) %>%
    signif_column(data = ., p = p.value)
}

# safer version of chi-squared test that returns NAs
# needed to work with `group_modify` since it will not work when NULL is returned
# by `broomExtra::tidy`
#' @noRd

chisq_test_safe <- function(data, x, ...) {
  # create a table
  xtab <- table(data %>% dplyr::pull({{ x }}))

  # run chi-square test
  chi_result <- broomExtra::tidy(stats::chisq.test(xtab))

  # if not null, return tidy output, otherwise return NAs
  if (!is.null(chi_result)) {
    chi_result
  } else {
    tibble(
      statistic = NA_real_,
      p.value = NA_real_,
      parameter = NA_real_,
      method = "Chi-squared test for given probabilities"
    )
  }
}
