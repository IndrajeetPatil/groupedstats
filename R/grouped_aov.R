#' @title Running analysis of variance (aov) across multiple grouping variables.
#' @name grouped_aov
#'
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"tukey"`,
#'   which will return results from Tukey's Honest Significant Differences
#'   method for *post hoc* comparisons. The `"glance"` method to get model
#'   summary is currently not supported for this function.
#' @param ... Currently ignored.
#' @inheritParams stats::aov
#' @inheritParams broomExtra::grouped_tidy
#' @inheritParams lm_effsize_ci
#'
#' @importFrom purrr map pmap
#' @importFrom stats aov as.formula TukeyHSD
#' @importFrom tidyr nest
#' @importFrom rlang !! enquos enquo quo quo_squash
#' @importFrom dplyr select group_by arrange mutate mutate_at mutate_if
#' @importFrom dplyr left_join bind_rows bind_cols
#'
#' @examples
#'
#' # uses dataset included in the `groupedstats` package
#' set.seed(123)
#' library(groupedstats)
#'
#' # effect size
#' groupedstats::grouped_aov(
#'   formula = wt ~ mpg,
#'   data = mtcars,
#'   grouping.vars = am,
#'   effsize = "eta"
#' )
#' @export

# function body
grouped_aov <- function(data,
                        grouping.vars,
                        formula,
                        effsize = "eta",
                        output = "tidy",
                        ...) {

  # glace is not supported for all models
  if (output == "glance") {
    stop(message(
      "The glance model summary is currently not supported for this function.
        Use either 'tidy' or 'tukey'."
    ))
  }

  # check how many variables were entered for grouping variable vector
  grouping.vars <- as.list(rlang::quo_squash(rlang::enquo(grouping.vars)))
  grouping.vars <-
    if (length(grouping.vars) == 1) {
      grouping.vars
    } else {
      grouping.vars[-1]
    }

  # getting the dataframe ready
  df <-
    dplyr::select(.data = data, !!!grouping.vars, dplyr::everything()) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(.) %>%
    dplyr::filter(.data = ., !purrr::map_lgl(.x = data, .f = is.null)) %>%
    dplyr::ungroup(x = .)

  # ======================= custom function ==================================

  # custom function to run tidy operation on every element of list column
  fnlisted <- function(list.col,
                       formula,
                       effsize,
                       output) {
    if (output == "tidy") {
      # getting tidy dataframe with results
      results_df <-
        list.col %>%
        purrr::map_dfr(
          .x = .,
          .f = ~ lm_effsize_ci(
            object = stats::aov(
              formula = stats::as.formula(formula),
              data = (.),
              na.action = na.omit
            ),
            effsize = effsize,
            partial = TRUE,
            conf.level = 0.95
          ),
          .id = "..group"
        )

      # return the tidy dataframe
      return(results_df)
    } else if (output == "tukey") {

      # getting tidy dataframe for Tukey HSD comparisons
      results_df <-
        list.col %>%
        purrr::map_dfr(
          .x = .,
          .f = ~ broomExtra::tidy(
            x = stats::TukeyHSD(
              x = stats::aov(
                formula = stats::as.formula(formula),
                data = (.),
                na.action = na.omit
              ),
              ordered = FALSE,
              conf.level = 0.95
            )
          ),
          .id = "..group"
        )

      # return the posthoc dataframe
      return(results_df)
    }
  }
  # =============== using  custom function on entered dataframe ===============

  # converting the original dataframe to have a grouping variable column
  df %<>% tibble::rownames_to_column(., var = "..group")

  # running the custom function and cleaning the dataframe
  combined_df <-
    purrr::pmap(
      .l = list(
        list.col = list(df$data),
        formula = list(formula),
        effsize = list(effsize),
        output = list(output)
      ),
      .f = fnlisted
    ) %>%
    dplyr::bind_rows(.) %>%
    dplyr::left_join(x = ., y = df, by = "..group") %>%
    dplyr::select(.data = ., !!!grouping.vars, dplyr::everything()) %>%
    dplyr::select(.data = ., -`..group`, -data)

  # add a column with significance labels if p-values are present
  if ("p.value" %in% names(combined_df)) {
    combined_df %<>% signif_column(data = ., p = p.value)
  }

  if ("adj.p.value" %in% names(combined_df)) {
    combined_df %<>% signif_column(data = ., p = adj.p.value)

    # display note about adjustment
    message("Note: The p-value is adjusted for the number of tests conducted
            at each level of the grouping variable.")
  }

  # return the final combined dataframe
  return(combined_df)
}
