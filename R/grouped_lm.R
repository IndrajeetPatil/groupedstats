#'
#' @title Function to run linear regression on multiple variables across
#'   multiple grouping variables.
#' @name grouped_lm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear regression analyses.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param dep.vars List criterion or **dependent** variables for simple linear
#'   model (`y` in `y ~ x`).
#' @param indep.vars List predictor or **independent** variables for simple
#'   linear model (`x` in `y ~ x`).
#' @param nboot Number of bootstrap samples to construct 95% confidence
#'   intervals for partial eta-squared and omega-squared. Default is `nboot =
#'   100`.
#'
#' @import dplyr
#' @import rlang
#' @import tibble
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
#'
#' @examples
#
# # in case of just one grouping variable
# groupedstats::grouped_lm(data = iris,
# dep.vars = c(Sepal.Length, Petal.Length),
# indep.vars = c(Sepal.Width, Petal.Width),
# grouping.vars = Species)
#
# # in case of multiple grouping variables
# groupedstats::grouped_lm( data = mtcars,
# dep.vars = c(wt, mpg),
# indep.vars = c(drat, disp),
# grouping.vars = c(am, cyl))
#
#' @export


# defining global variables and functions to quient the R CMD check notes
utils::globalVariables(
  c(
    "estimate",
    "formula",
    "group",
    "p.value",
    "statistic",
    "std.error",
    "term",
    "beta",
    "conf.low",
    "conf.high",
    "partial.etasq",
    "partial.etasq.conf.low",
    "partial.etasq.conf.high",
    "partial.omegasq",
    "partial.omegasq.conf.low",
    "partial.omegasq.conf.high"
  )
)

# defining the function
grouped_lm <- function(data,
                       dep.vars,
                       indep.vars,
                       grouping.vars,
                       nboot = 100) {
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
  df <- dplyr::select(.data = data,
                      !!!grouping.vars,
                      !!!dep.vars,
                      !!!indep.vars) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(data = .)

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
        .f = ~ dplyr::bind_cols(
          dplyr::filter(.data = broom::tidy(x = .), term == !!filter_name),
          broom::confint_tidy(x = .)[-c(1), ]
        ),
        .id = "group"
      ) %>% # removing the unnecessary term column
      dplyr::select(.data = ., -term) %>% # convert to a tibble dataframe
      tibble::as_data_frame(x = .)

    # dataframe with results from lm
    effsize_df <-
      list.col %>% # running linear regression on each individual group with purrr
      purrr::map(
        .x = .,
        .f = ~ stats::lm(
          formula = stats::as.formula(fx_plain),
          data = (.),
          na.action = na.omit
        )
      ) %>% # tidying up the output with broom
      purrr::map_dfr(
        .x = .,
        .f = ~ lm_effsize_ci(
          lm_object = .,
          conf.level = 0.95,
          nboot = nboot
        ),
        .id = "group"
      ) %>% # convert to a tibble dataframe
      tibble::as_data_frame(x = .)

    # combining summary results and effect size results in a single dataframe
    combined_df <-
      dplyr::full_join(x = results_df,
                       y = effsize_df,
                       by = "group") %>% # remove intercept terms
      #dplyr::filter(.data = ., term == !!filter_name) %>% # add formula as a character
      dplyr::mutate(.data = ., formula = as.character(fx_plain)) %>% # rearrange the dataframe
      dplyr::select(
        .data = .,
        group,
        term,
        formula,
        t.value = statistic,
        beta = estimate,
        conf.low,
        conf.high,
        std.error,
        p.value,
        `F value`,
        df1,
        df2,
        `Pr(>F)`,
        partial.etasq,
        partial.etasq.conf.low,
        partial.etasq.conf.high,
        partial.omegasq,
        partial.omegasq.conf.low,
        partial.omegasq.conf.high
      ) %>% # convert to a tibble dataframe
      tibble::as_data_frame(x = .)

    # return the dataframe
    return(combined_df)
  }

  # ========= using  custom function on entered dataframe =================

  # converting the original dataframe to have a grouping variable column
  df %<>%
    tibble::rownames_to_column(df = ., var = "group")

  # running custom function for each element of the created list column
  df_lm <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      x_name = purrr::map(.x = indep.vars,
                          .f = ~ rlang::quo_name(quo = .)),
      y_name = purrr::map(.x = dep.vars,
                          .f = ~ rlang::quo_name(quo = .))
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
