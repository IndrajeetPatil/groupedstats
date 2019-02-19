#' @title Tidy output from grouped analysis of any function that has `data`
#'   argument in its function call.
#' @name grouped_tidy
#' @description This is the most general form of a `grouped_` function where any
#'   function can be used to run `grouped_` analysis.
#' @inheritParams grouped_lm
#' @param ..f A function, or function name as a string.
#' @inheritParams rlang::exec
#'
#' @importFrom rlang !! !!! quo_squash enquo enquos exec
#' @importFrom dplyr select everything group_by filter ungroup mutate group_map
#' @importFrom tidyr nest unnest
#' @importFrom purrr map_lgl map
#' @importFrom broom tidy
#'
#' @examples
#' groupedstats::grouped_tidy(
#'   data = ggplot2::diamonds,
#'   grouping.vars = c(cut, color),
#'   formula = price ~ carat * clarity,
#'   ..f = stats::lm
#' )
#' @export

# function body
grouped_tidy <- function(data,
                         grouping.vars,
                         ..f,
                         ...) {
  # check how many variables were entered for grouping variable vector
  grouping.vars <-
    as.list(rlang::quo_squash(rlang::enquo(grouping.vars)))
  grouping.vars <-
    if (length(grouping.vars) == 1) {
      grouping.vars
    } else {
      grouping.vars[-1]
    }

  # quote all argument to `..f`
  dots <- rlang::enquos(...)

  # running the grouped analysis
  df_results <- data %>%
    dplyr::group_by(.data = ., !!!grouping.vars, .drop = TRUE) %>%
    dplyr::group_map(.tbl = ., .f = ~ broom::tidy(
      x = rlang::exec(.fn = ..f, !!!dots, data = .x),
      conf.int = TRUE,
      quick = FALSE
    ))

  # return the final dataframe with results
  return(df_results)
}
