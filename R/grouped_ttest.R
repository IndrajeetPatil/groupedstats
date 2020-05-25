#' @title Function to run *t*-test on multiple variables across multiple
#'   grouping variables.
#' @name grouped_ttest
#' @return A tibble dataframe with tidy results from *t*-test analyses.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param dep.vars List dependent variables for a *t*-test (`y` in `y ~ x`).
#' @param indep.vars List independent variables for a *t*-test (`x` in `y ~ x`).
#' @param grouping.vars List of grouping variables.
#' @param paired A logical indicating whether you want a paired *t*-test (Default:
#'   `paired = FALSE`; independent *t*-test, i.e.).
#' @param var.equal A logical variable indicating whether to treat the two
#'   variances as being equal. If `TRUE`, then the pooled variance is used to
#'   estimate the variance otherwise the Welch (or Satterthwaite) approximation
#'   to the degrees of freedom is used (Default: `var.equal = FALSE`; Welch's
#'   *t*-test, i.e.).
#'
#' @importFrom glue glue
#' @importFrom purrr map pmap map_lgl
#' @importFrom stats wilcox.test as.formula t.test
#' @importFrom tidyr nest
#' @importFrom rlang !! enquos enquo quo quo_squash
#' @importFrom dplyr select group_by arrange mutate mutate_at mutate_if
#' @importFrom dplyr left_join
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#'
#' groupedstats::grouped_ttest(
#'   data = dplyr::filter(.data = ggplot2::diamonds, color == "E" | color == "J"),
#'   dep.vars = c(carat, price, depth),
#'   indep.vars = color,
#'   grouping.vars = clarity,
#'   paired = FALSE,
#'   var.equal = FALSE
#' )
#' @export

# defining the function
grouped_ttest <- function(data,
                          dep.vars,
                          indep.vars,
                          grouping.vars,
                          paired = FALSE,
                          var.equal = FALSE) {
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

  # custom function to run linear regression for every element of a list for two
  # variables
  lm_listed <- function(list.col,
                        x_name,
                        y_name,
                        paired,
                        var.equal) {
    # plain version of the formula to return
    fx <- glue::glue("{y_name} ~ {x_name}")

    # dataframe with results from lm
    results_df <-
      list.col %>% # running t-test on each individual group with purrr
      purrr::map(
        .x = .,
        .f = ~ stats::t.test(
          formula = stats::as.formula(fx),
          mu = 0,
          paired = paired,
          var.equal = var.equal,
          alternative = "two.sided",
          conf.level = 0.95,
          na.action = na.omit,
          data = (.)
        )
      ) %>% # tidying up the output with broom
      purrr::map_dfr(
        .x = .,
        .f = ~ broomExtra::tidy(x = .),
        .id = "..group"
      ) %>% # add formula as a character
      dplyr::mutate(.data = ., formula = as.character(fx)) %>%
      # rearrange the dataframe
      dplyr::select(
        .data = .,
        `..group`,
        formula,
        method,
        t.test = statistic,
        estimate,
        conf.low,
        conf.high,
        parameter,
        p.value,
        alternative
      ) %>% # convert to a tibble dataframe
      tibble::as_tibble(x = .)

    # return the dataframe
    return(results_df)
  }

  # using  custom function on entered dataframe ----------------------------

  df %<>% tibble::rownames_to_column(., var = "..group")

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
      var.equal = var.equal
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
