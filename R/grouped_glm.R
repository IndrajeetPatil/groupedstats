#' @title Function to run generalized linear model (glm) across multiple
#'   grouping variables.
#' @name grouped_glm
#' @aliases grouped_glm
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"glance"`,
#'   which will return model summaries.
#' @param quick Logical indicating if the only the term and estimate columns
#'   should be returned. Often useful to avoid time consuming covariance and
#'   standard error calculations. Defaults to `FALSE`.
#' @param exponentiate Logical indicating whether or not to exponentiate the the
#'   coefficient estimates. This is typical for logistic and multinomial
#'   regressions, but a bad idea if there is no log or logit link. Defaults to
#'   `FALSE`.
#' @inheritParams stats::glm
#'
#' @importFrom magrittr "%<>%"
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
#' @seealso grouped_lm, grouped_glmer
#'
#' @examples
#'
#' # to get tidy output
#' groupedstats::grouped_glm(
#'   data = groupedstats::Titanic_full,
#'   formula = Survived ~ Sex,
#'   grouping.vars = Class,
#'   family = stats::binomial(link = "logit")
#' )
#'
#' # to get glance output
#' groupedstats::grouped_glm(
#'   data = groupedstats::Titanic_full,
#'   formula = Survived ~ Sex,
#'   grouping.vars = Class,
#'   family = stats::binomial(link = "logit"),
#'   output = "glance"
#' )
#' @export

grouped_glm <- function(data,
                        grouping.vars,
                        formula,
                        family = stats::binomial(link = "logit"),
                        quick = FALSE,
                        exponentiate = FALSE,
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
    dplyr::filter(.data = ., !purrr::map_lgl(.x = data, .f = is.null)) %>%
    dplyr::ungroup(x = .)

  # ====================================== custom function ==================================

  # custom function to run tidy operation on every element of list column
  fnlisted <-
    function(list.col,
                 formula,
                 family,
                 output,
                 quick,
                 exponentiate) {
      if (output == "tidy") {
        # dataframe with results from glm
        results_df <-
          list.col %>% # tidying up the output with broom
          purrr::map_dfr(
            .x = .,
            .f = ~ broom::tidy(
              x = stats::glm(
                formula = stats::as.formula(formula),
                data = (.),
                na.action = na.omit,
                family = family
              ),

              conf.int = TRUE,
              conf.level = 0.95,
              quick = quick,
              exponentiate = exponentiate
            ),
            .id = "..group"
          )
      } else if (output == "glance") {
        # dataframe with results from glm
        results_df <-
          list.col %>% # tidying up the output with broom
          purrr::map_dfr(
            .x = .,
            .f = ~ broom::glance(
              x = stats::glm(
                formula = stats::as.formula(formula),
                data = (.),
                na.action = na.omit,
                family = family
              )
            ),
            .id = "..group"
          )
      }

      # return the final dataframe
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
      family = list(family),
      output = list(output),
      quick = list(quick),
      exponentiate = list(exponentiate)
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
      signif_column(data = ., p = p.value)
  }

  return(combined_df)
}
