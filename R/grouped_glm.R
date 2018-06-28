#'
#' @title Function to run generalized linear model on multiple variables across
#'   multiple grouping variables.
#' @name grouped_glm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear regression analyses.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param dep.vars List criterion or dependent variables for regression (`y` in
#'   `y ~ x`).
#' @param indep.vars List predictor or independent variables for regression (`x`
#'   in `y ~ x`).
#' @param family A description of the error distribution and link function to be
#'   used in the model. For glm this can be a character string naming a `family`
#'   function, a `family` function or the result of a call to a family function.
#'   For more, see `?stats::family`.
#'
#' @importFrom broom tidy
#' @importFrom broom confint_tidy
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom purrr map2_dfr
#' @importFrom purrr pmap
#' @importFrom stats glm
#' @importFrom stats as.formula
#' @importFrom tibble as_data_frame
#' @importFrom tidyr nest
#' @importFrom dplyr bind_cols
#' @importFrom dplyr bind_rows
#' @importFrom dplyr everything
#' @importFrom dplyr left_join
#'
#' @examples
#'
#' groupedstats::grouped_glm(data = datasets::mtcars,
#'  dep.vars = am,
#'  indep.vars = wt,
#'  grouping.vars = cyl,
#'  family = "gaussian"
#' )
#
#' @export
#'

# defining the function
grouped_glm <- function(data,
                       dep.vars,
                       indep.vars,
                       grouping.vars,
                       family) {
  # ================== preparing dataframe ==================
  #
  # check how many variables were entered for criterion variables vector
  dep.vars <-
    as.list(rlang::quo_squash(rlang::enquo(dep.vars)))
  dep.vars <-
    if (length(dep.vars) == 1) {
      dep.vars
    } else {
      dep.vars[-1]
    }

  # check how many variables were entered for predictor variables vector
  indep.vars <-
    as.list(rlang::quo_squash(rlang::enquo(indep.vars)))
  indep.vars <-
    if (length(indep.vars) == 1) {
      indep.vars
    } else {
      indep.vars[-1]
    }

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
    !!!dep.vars,
    !!!indep.vars
  ) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(data = .)

  # ============== custom function ================

  # custom function to run linear regression for every element of a list for two variables
  lm_listed <- function(list.col, x_name, y_name) {
    #
    # creating a formula out of entered variables
    fx <- glue::glue("{y_name} ~ {x_name}")

    # this tags any names that are not predictor variables (used to remove intercept terms)
    filter_name <- glue::glue("{x_name}")

    # dataframe with results from lm
    results_df <-
      list.col %>% # running linear regression on each individual group with purrr
      purrr::map(
        .x = .,
        .f = ~stats::glm(
          formula = stats::as.formula(fx),
          family = family,
          data = (.)
        )
      ) %>% # tidying up the output with broom
      purrr::map_dfr(
        .x = .,
        .f = ~dplyr::bind_cols(broom::tidy(x = .), broom::confint_tidy(x = .)),
        .id = "group"
      ) %>% # remove intercept terms
      dplyr::filter(.data = ., term == !!filter_name) %>% # add formula as a character
      dplyr::mutate(.data = ., formula = as.character(fx)) %>% # rearrange the dataframe
      dplyr::select(
        .data = .,
        group,
        formula,
        term,
        statistic,
        estimate,
        conf.low,
        conf.high,
        std.error,
        p.value
      ) %>% # convert to a tibble dataframe
      tibble::as_data_frame(x = .)

    # return the dataframe
    return(results_df)
  }

  # ========= using  custom function on entered dataframe =================

  df <- df %>%
    tibble::rownames_to_column(df = ., var = "group")
  # running custom function for each element of the created list column
  df_lm <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      x_name = purrr::map(
        .x = indep.vars,
        .f = ~rlang::quo_name(quo = .)
      ),
      y_name = purrr::map(
        .x = dep.vars,
        .f = ~rlang::quo_name(quo = .)
      )
    ),
    .f = lm_listed
  ) %>%
    dplyr::bind_rows(.) %>%
    dplyr::left_join(x = ., y = df, by = "group") %>%
    dplyr::select(.data = ., !!!grouping.vars, dplyr::everything()) %>%
    dplyr::select(.data = ., -group, -data, -term) %>%
    signif_column(data = ., p = `p.value`)

  # ============================== output ==================================

  # return the final dataframe with results
  return(df_lm)
}
