#' @title Function to run robust simple linear regression (slr) on multiple variables across
#'   multiple grouping variables.
#' @name grouped_robustslr
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from robust linear regression
#'   analyses. The estimates are standardized, i.e. the `lm` model used is
#'   `scale(y) ~ scale(x)`, and not `y ~ x`.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param dep.vars List criterion or dependent variables for regression (`y` in
#'   `y ~ x`).
#' @param indep.vars List predictor or independent variables for regression (`x`
#'   in `y ~ x`).
#' @inheritParams robust::lmRob
#'
#' @importFrom robust lmRob
#' @importFrom glue glue
#' @importFrom purrr map map_lgl map2_dfr pmap
#' @importFrom stats wilcox.test as.formula lm
#' @importFrom tidyr nest
#' @importFrom rlang !! enquos enquo quo quo_squash
#' @importFrom dplyr select group_by arrange mutate mutate_at mutate_if
#' @importFrom dplyr left_join right_join
#'
#' @examples
#'
#' # in case of just one grouping variable
#' groupedstats::grouped_robustslr(
#'   data = iris,
#'   dep.vars = c(Sepal.Length, Petal.Length),
#'   indep.vars = c(Sepal.Width, Petal.Width),
#'   grouping.vars = Species
#' )
#' @export

# defining the function
grouped_robustslr <- function(data,
                              dep.vars,
                              indep.vars,
                              grouping.vars,
                              nrep = 1000,
                              control = robust::lmRob.control(
                                tlo = 1e-4,
                                tua = 1.5e-06,
                                mxr = 50,
                                mxf = 50,
                                mxs = 50,
                                tl = 1e-06,
                                estim = "Final",
                                initial.alg = "Auto",
                                final.alg = "MM",
                                seed = 1313,
                                level = 0.1,
                                efficiency = 0.9,
                                weight = c("Optimal", "Optimal"),
                                trace = TRUE
                              )) {

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
    tidyr::nest(data = .) %>%
    dplyr::filter(.data = ., !purrr::map_lgl(.x = data, .f = is.null)) %>%
    dplyr::ungroup(x = .)

  # ============== custom function ================

  # custom function to run linear regression for every element of a list for two
  # variables
  lm_listed <- function(list.col, x_name, y_name, nrep, control) {

    # creating a formula out of entered variables
    fx <- glue::glue("scale({y_name}) ~ scale({x_name})")

    # plain version of the formula to return
    fx_plain <- glue::glue("{y_name} ~ {x_name}")

    # this tags any names that are not predictor variables (used to remove
    # intercept terms)
    filter_name <- glue::glue("scale({x_name})")

    # dataframe with results from lm
    results_df <-
      list.col %>% # running linear regression on each individual group with purrr
      purrr::map(
        .x = .,
        .f = ~ robust::lmRob(
          formula = stats::as.formula(fx),
          data = (.),
          nrep = nrep,
          control = control
        )
      ) %>% # tidying up the output with broom
      purrr::map_dfr(
        .x = .,
        .f = ~ broomExtra::tidy(x = .),
        .id = "..group"
      ) %>% # remove intercept terms
      dplyr::filter(.data = ., term == !!filter_name) %>% # add formula as a character
      dplyr::mutate(.data = ., formula = as.character(fx_plain)) %>% # rearrange the dataframe
      dplyr::select(
        .data = .,
        `..group`,
        formula,
        term,
        t.value = statistic,
        estimate,
        std.error,
        p.value
      ) %>% # convert to a tibble dataframe
      tibble::as_tibble(x = .)

    # return the dataframe
    return(results_df)
  }

  # ========= using  custom function on entered dataframe =================

  df %<>%
    tibble::rownames_to_column(., var = "..group")

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
      ),
      nrep = list(nrep),
      control = list(control)
    ),
    .f = lm_listed
  ) %>%
    dplyr::bind_rows(.) %>%
    dplyr::left_join(x = ., y = df, by = "..group") %>%
    dplyr::select(.data = ., !!!grouping.vars, dplyr::everything()) %>%
    dplyr::select(.data = ., -`..group`, -data, -term) %>%
    signif_column(data = ., p = `p.value`)

  # ============================== output ==================================

  # return the final dataframe with results
  return(combined_df)
}
