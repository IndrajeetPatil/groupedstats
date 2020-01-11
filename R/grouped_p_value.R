#' @title Extracting *p*-values for models that don't produce them.
#' @name grouped_p_value
#' @author Indrajeet Patil
#'
#' @inheritParams broomExtra::grouped_tidy
#'
#' @examples
#' groupedstats:::grouped_p_value(
#'   data = ggplot2::diamonds,
#'   formula = scale(price) ~ scale(carat) + (carat | color),
#'   grouping.vars = c(cut, clarity),
#'   ..f = lme4::lmer
#' )
#' @keywords internal

grouped_p_value <- function(data,
                            grouping.vars,
                            ..f,
                            ...) {
  # function to run
  tidy_group <- function(.x, .y) {

    # presumes `..f` will work with these args
    model <- ..f(.y = ..., data = .x)

    # variation on `do.call` to call function with list of arguments
    rlang::exec(.fn = parameters::p_value, model)
  }

  # dataframe with grouped analysis results
  data %>%
    dplyr::group_by_at(rlang::enquos(grouping.vars), .drop = TRUE) %>%
    dplyr::group_modify(.f = tidy_group, keep = TRUE) %>%
    dplyr::ungroup(x = .) %>%
    dplyr::rename(.data = ., term = Parameter, p.value = p)
}
