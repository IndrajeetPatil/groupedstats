#' @title Running simple linear regression (slr) on multiple variables across
#'   multiple grouping variables.
#' @name grouped_slr
#' @return A tibble dataframe with tidy results from simple linear regression
#'   analyses. The estimates are standardized, i.e. the `lm` model used is
#'   `scale(y) ~ scale(x)`, and not `y ~ x`.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param dep.vars List criterion or **dependent** variables for simple linear
#'   model (`y` in `y ~ x`).
#' @param indep.vars List predictor or **independent** variables for simple
#'   linear model (`x` in `y ~ x`).
#'
#' @importFrom glue glue
#' @importFrom purrr map pmap
#' @importFrom stats wilcox.test as.formula lm
#' @importFrom tidyr nest
#' @importFrom rlang !! enquos enquo quo quo_squash
#' @importFrom dplyr select group_by arrange mutate mutate_at mutate_if
#' @importFrom dplyr left_join
#'
#' @seealso \code{\link{grouped_lm}}, \code{\link{grouped_tidy}}
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#'
#' # in case of just one grouping variable
#' groupedstats::grouped_slr(
#'   data = iris,
#'   dep.vars = c(Sepal.Length, Petal.Length),
#'   indep.vars = c(Sepal.Width, Petal.Width),
#'   grouping.vars = Species
#' )
#' @export

# defining the function
grouped_slr <- function(data,
                        dep.vars,
                        indep.vars,
                        grouping.vars) {
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
    tidyr::nest(.)

  # ============== custom function ================

  # custom function to run linear regression for every element of a list for two variables
  lm_listed <- function(list.col, x_name, y_name) {
    #
    # creating a formula out of entered variables
    fx <- glue::glue("scale({y_name}) ~ scale({x_name})")

    # plain version of the formula to return
    fx_plain <- glue::glue("{y_name} ~ {x_name}")

    # this tags any names that are not predictor variables (used to remove intercept terms)
    filter_name <- glue::glue("scale({x_name})")

    # dataframe with results from lm
    results_df <-
      list.col %>% # running linear regression on each individual group with purrr
      purrr::map(
        .x = .,
        .f = ~ stats::lm(
          formula = stats::as.formula(fx),
          data = (.),
          na.action = na.omit
        )
      ) %>% # tidying up the output with broom
      purrr::map_dfr(
        .x = .,
        .f = ~ dplyr::filter(
          .data = broomExtra::tidy(x = ., conf.int = TRUE),
          term == !!filter_name
        ),
        .id = "..group"
      ) %>% # removing the unnecessary term column
      dplyr::select(.data = ., -term) %>% # convert to a tibble dataframe
      tibble::as_tibble(x = .)

    # preparing the final dataframe to be returned
    results_df %<>%
      dplyr::mutate(.data = ., formula = as.character(fx_plain)) %>% # rearrange the dataframe
      dplyr::select(
        .data = .,
        `..group`,
        formula,
        t.value = statistic,
        estimate,
        conf.low,
        conf.high,
        std.error,
        p.value
      ) %>% # convert to a tibble dataframe
      tibble::as_tibble(x = .)

    # return the dataframe
    return(results_df)
  }

  # ========= using  custom function on entered dataframe =================

  # converting the original dataframe to have a grouping variable column
  df %<>% tibble::rownames_to_column(., var = "..group")

  # running custom function for each element of the created list column
  combined_df <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      x_name = purrr::map(
        .x = indep.vars,
        .f = ~ rlang::quo_name(quo = .)
      ),
      y_name = purrr::map(
        .x = dep.vars,
        .f = ~ rlang::quo_name(quo = .)
      )
    ),
    .f = lm_listed
  ) %>%
    dplyr::bind_rows(.) %>%
    dplyr::left_join(x = ., y = df, by = "..group") %>%
    dplyr::select(.data = ., !!!grouping.vars, dplyr::everything()) %>%
    dplyr::select(.data = ., -`..group`, -data) %>%
    signif_column(data = ., p = `p.value`)

  # ============================== output ==================================

  # return the final dataframe with results
  return(combined_df)
}
