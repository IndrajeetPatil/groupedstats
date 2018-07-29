#'
#' @title Function to run linear model (lm) across multiple grouping variables.
#' @name grouped_lm
#' @aliases grouped_lm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"glance"`,
#'   which will return model summaries.
#' @inheritParams stats::lm
#'
#' @importFrom magrittr "%<>%"
#' @importFrom broom tidy
#' @importFrom broom confint_tidy
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom purrr map2_dfr
#' @importFrom purrr pmap
#' @importFrom stats lm
#' @importFrom stats as.formula
#' @importFrom tibble as_data_frame
#' @importFrom tidyr nest
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
#' @importFrom dplyr mutate_at
#' @importFrom dplyr mutate_if
#' @importFrom dplyr select
#' @importFrom rlang quo_squash
#' @importFrom rlang enquo
#' @importFrom rlang quo
#'
#' @seealso grouped_slr
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
#'

grouped_lm <- function(data,
                       grouping.vars,
                       formula,
                       output = "tidy") {
  # check how many variables were entered for grouping variable vector
  grouping.vars <-
    as.list(rlang::quo_squash(rlang::enquo(grouping.vars)))
  grouping.vars <-
    if (length(grouping.vars) == 1) {
      grouping.vars
    } else {
      grouping.vars[-1]
    }

  # getting the dataframe ready
  df <- dplyr::select(
    .data = data,
    !!!grouping.vars,
    dplyr::everything()
  ) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(data = .) %>%
    dplyr::ungroup(x = .)

  # ====================================== custom function ==================================

  # custom function to run tidy operation on every element of list column
  fnlisted <- function(list.col, formula, output) {
    if (output == "tidy") {
      # dataframe with results from lm
      results_df <-
        list.col %>% # tidying up the output with broom
        purrr::map_dfr(
          .x = .,
          .f = ~broom::tidy(
            x = stats::lm(
              formula = stats::as.formula(formula),
              data = (.),
              na.action = na.omit
            ),
            conf.int = TRUE,
            conf.level = 0.95
          ),
          .id = "..group"
        ) %>%
        dplyr::rename(.data = ., t.value = statistic)
    } else if (output == "glance") {
      # dataframe with results from lm
      results_df <-
        list.col %>% # tidying up the output with broom
        purrr::map_dfr(
          .x = .,
          .f = ~broom::glance(x = stats::lm(
            formula = stats::as.formula(formula),
            data = (.),
            na.action = na.omit
          )),
          .id = "..group"
        )
    }
    return(results_df)
  }


  # ========================== using  custom function on entered dataframe ==================================

  # converting the original dataframe to have a grouping variable column
  df %<>%
    tibble::rownames_to_column(., var = "..group")

  combined_df <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      formula = list(formula),
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
    combined_df %<>%
      ggstatsplot:::signif_column(data = ., p = p.value)
  }

  return(combined_df)
}
