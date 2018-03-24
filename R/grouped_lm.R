#'
#' @title Function to run linear regression on multiple variables across multiple grouping variables.
#' @name grouped_lm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear regression analyses.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param crit.vars List criterion or dependent variables for regression (`y` in `y ~ x`).
#' @param pred.vars List predictor or independent variables for regression (`x` in `y ~ x`).
#'
#' @import dplyr
#' @import rlang
#' @import tibble
#'
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
# crit.vars = c(Sepal.Length, Petal.Length),
# pred.vars = c(Sepal.Width, Petal.Width),
# grouping.vars = Species)
#
# # in case of multiple grouping variables
# groupedstats::grouped_lm( data = mtcars,
# crit.vars = c(wt, mpg),
# pred.vars = c(drat, disp),
# grouping.vars = c(am, cyl))
#
#' @export


# defining global variables and functions to quient the R CMD check notes
utils::globalVariables(c(
  "estimate",
  "formula",
  "group",
  "p.value",
  "statistic",
  "std.error",
  "term"
))

# defining the function
grouped_lm <- function(data,
                       crit.vars,
                       pred.vars,
                       grouping.vars) {
  #================== preparing dataframe ==================
  #
  # check how many variables were entered for criterion variables vector
  crit.vars <-
    as.list(rlang::quo_squash(rlang::enquo(crit.vars)))
  crit.vars <-
    if (length(crit.vars) == 1) {
      crit.vars
    } else {
      crit.vars[-1]
    }

  # check how many variables were entered for predictor variables vector
  pred.vars <-
    as.list(rlang::quo_squash(rlang::enquo(pred.vars)))
  pred.vars <-
    if (length(pred.vars) == 1) {
      pred.vars
    } else {
      pred.vars[-1]
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
                      !!!crit.vars,
                      !!!pred.vars) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(data = .)

  #============== custom function ================

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
      purrr::map(.x = .,
                 .f = ~ stats::lm(formula = stats::as.formula(fx),
                                  data = (.))) %>% # tidying up the output with broom
      purrr::map_dfr(.x = .,
                     .f = ~ broom::tidy(x = .),
                     .id = "group") %>% # remove intercept terms
      dplyr::filter(.data = ., term == !!filter_name) %>% # add formula as a character
      dplyr::mutate(.data = ., formula = as.character(fx_plain)) %>% # rearrange the dataframe
      dplyr::select(
        .data = .,
        group,
        formula,
        term,
        estimate,
        std.error,
        t = statistic,
        p.value
      ) %>% # convert to a tibble dataframe
      tibble::as_data_frame(x = .)

    # return the dataframe
    return(results_df)
  }

  #========= using  custom function on entered dataframe =================

  df <- df %>%
    tibble::rownames_to_column(df = ., var = 'group')
  # running custom function for each element of the created list column
  df_lm <- purrr::pmap(.l = list(
    l = list(df$data),
    x_name = purrr::map(.x = pred.vars,
                        .f = ~ rlang::quo_name(quo = .)),
    y_name = purrr::map(.x = crit.vars,
                        .f = ~ rlang::quo_name(quo = .))
  ),
  .f = lm_listed) %>%
    dplyr::bind_rows(.) %>%
    dplyr::left_join(x = ., y = df, by = "group") %>%
    dplyr::select(.data = ., !!!grouping.vars, dplyr::everything()) %>%
    dplyr::select(.data = ., -group, -data, -term)

  #============================== output ==================================

  # return the final dataframe with results
  return(df_lm)

}
