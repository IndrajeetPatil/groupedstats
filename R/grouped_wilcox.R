#' @title Function to run two-sample Wilcoxon tests on multiple variables across
#'   multiple grouping variables.
#' @title Running Wilcox test across multiple grouping variables.
#' @name grouped_wilcox
#' @return A tibble dataframe with tidy results from two-sample Wilcoxon tests
#'   analyses.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param dep.vars List dependent variables for a two-sample Wilcoxon tests (`y`
#'   in `y ~ x`).
#' @param indep.vars List independent variables for a two-sample Wilcoxon tests
#'   (`x` in `y ~ x`).
#' @param grouping.vars List of grouping variables (if `NULL`, the entire
#'   dataframe will be used).
#' @param paired A logical indicating whether you want a paired two-sample
#'   Wilcoxon tests (Default: `paired = FALSE`).
#' @param correct A logical indicating whether to apply continuity correction in
#'   the normal approximation for the p-value (Default: `correct = TRUE`).
#'
#' @importFrom glue glue
#' @importFrom purrr map pmap
#' @importFrom stats wilcox.test as.formula
#' @importFrom tidyr nest
#'
#' @seealso \code{\link{grouped_tidy}}
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#'
#' # only with one grouping variable
#' groupedstats::grouped_wilcox(
#'   data = dplyr::filter(.data = ggplot2::diamonds, color == "E" | color == "J"),
#'   dep.vars = depth:table,
#'   indep.vars = color,
#'   grouping.vars = clarity,
#'   paired = FALSE
#' )
#' @export

# defining the function
grouped_wilcox <- function(data,
                           dep.vars,
                           indep.vars,
                           grouping.vars,
                           paired = FALSE,
                           correct = TRUE) {
  # ================== preparing dataframe ==================
  #
  # check how many variables were entered for criterion variables vector
  dep.vars <- as.list(rlang::quo_squash(rlang::enquo(dep.vars)))
  dep.vars <-
    if (length(dep.vars) == 1) {
      dep.vars
    } else {
      dep.vars[-1]
    }

  # check how many variables were entered for predictor variables vector
  indep.vars <- as.list(rlang::quo_squash(rlang::enquo(indep.vars)))
  indep.vars <-
    if (length(indep.vars) == 1) {
      indep.vars
    } else {
      indep.vars[-1]
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
    dplyr::select(.data = data, !!!grouping.vars, !!!dep.vars, !!!indep.vars) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(.) %>%
    dplyr::filter(.data = ., !purrr::map_lgl(.x = data, .f = is.null)) %>%
    dplyr::ungroup(x = .)

  # ============== custom function ================

  # custom function to run linear regression for every element of a list for two variables
  lm_listed <- function(list.col,
                        x_name,
                        y_name,
                        paired,
                        correct) {
    # plain version of the formula to return
    fx <- glue::glue("{y_name} ~ {x_name}")

    # dataframe with results from wilcox tests
    results_df <-
      list.col %>% # running two-sample Wilcoxon tests on each individual group with purrr
      purrr::map(
        .x = .,
        .f = ~ stats::wilcox.test(
          formula = stats::as.formula(fx),
          mu = 0,
          paired = paired,
          alternative = "two.sided",
          conf.level = 0.95,
          na.action = na.omit,
          exact = NULL,
          correct = correct,
          conf.int = TRUE,
          data = (.)
        )
      ) %>% # tidying up the output with broom
      purrr::map_dfr(
        .x = .,
        .f = ~ broomExtra::tidy(x = .),
        .id = "..group"
      ) %>% # add formula as a character
      dplyr::mutate(.data = ., formula = as.character(fx)) %>% # rearrange the dataframe
      dplyr::select(
        .data = .,
        `..group`,
        formula,
        method,
        statistic,
        estimate,
        conf.low,
        conf.high,
        p.value,
        alternative
      ) %>% # convert to a tibble dataframe
      tibble::as_tibble(x = .)

    # return the dataframe
    return(results_df)
  }

  # ========= using  custom function on entered dataframe =================

  df <- df %>%
    tibble::rownames_to_column(., var = "..group")

  # running custom function for each element of the created list column
  df_lm <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      x_name = purrr::map(
        .x = indep.vars,
        .f = ~ rlang::quo_name(quo = .)
      ),
      y_name = purrr::map(
        .x = dep.vars,
        .f = ~ rlang::quo_name(quo = .)
      ),
      paired = paired,
      correct = correct
    ),
    .f = lm_listed
  ) %>%
    dplyr::bind_rows(.) %>%
    dplyr::left_join(x = ., y = df, by = "..group") %>%
    dplyr::select(.data = ., !!!grouping.vars, dplyr::everything()) %>%
    dplyr::select(.data = ., -`..group`, -data, -alternative) %>%
    signif_column(data = ., p = `p.value`)

  # ============================== output ==================================

  # return the final dataframe with results
  return(df_lm)
}
