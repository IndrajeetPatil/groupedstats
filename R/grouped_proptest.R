#' @title Function to run proportion test on grouped data.
#' @name grouped_proptest
#' @author Indrajeet Patil
#' @return Dataframe with percentages and statistical details from a proportion
#'  test.
#'
#' @inheritParams broomExtra::grouped_tidy
#' @param measure A variable for which proportion test needs to be carried out
#'  for each combination of levels of factors entered in `grouping.vars`.
#'
#' @importFrom purrr map
#' @importFrom tidyr nest unnest spread
#' @importFrom broomExtra tidy
#' @importFrom stats chisq.test
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
grouped_proptest <- function(data, grouping.vars, measure) {

  # check how many variables were entered for this grouping variable
  grouping.vars <- as.list(rlang::quo_squash(rlang::enquo(grouping.vars)))
  grouping.vars <-
    if (length(grouping.vars) == 1) {
      # e.g., in mtcars dataset, grouping.vars = am
      grouping.vars
    } else {
      # e.g., in mtcars dataset, grouping.vars = c(am, cyl)
      grouping.vars[-1]
    }

  # getting the dataframe ready
  df <- dplyr::select(.data = data, !!!grouping.vars, measure = {{ measure }})

  # creating a nested dataframe
  df_nest <- df %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(.) %>%
    dplyr::filter(.data = ., !purrr::map_lgl(.x = data, .f = is.null)) %>%
    dplyr::ungroup(x = .)

  # creating the final results with the
  df_results <- df_nest %>%
    dplyr::mutate(
      .data = .,
      percentage = data %>%
        purrr::map(
          .x = .,
          .f = ~ dplyr::group_by(.data = ., measure) %>%
            dplyr::summarize(.data = ., n = dplyr::n()) %>%
            dplyr::mutate(
              .data = .,
              perc = paste(specify_decimal_p((n / sum(n)) * 100, k = 2), "%", sep = "")
            ) %>%
            dplyr::select(.data = ., -n) %>%
            tidyr::spread(
              data = .,
              key = measure,
              value = perc
            )
        )
    ) %>%
    dplyr::mutate(
      .data = .,
      chi_sq = data %>%
        purrr::map(
          .x = .,
          .f = ~ broomExtra::tidy(stats::chisq.test(table(.$measure)))
        )
    ) %>%
    dplyr::select(.data = ., -data)

  # unnest the dataframe and add significance column
  df_results %<>%
    tidyr::unnest(., cols = c(percentage, chi_sq)) %>%
    signif_column(data = ., p = p.value)

  # return the final results
  return(df_results)
}
