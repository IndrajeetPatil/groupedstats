#'
#' @title Function to run generalized linear mixed-effects model (glmer) across multiple
#'   grouping variables.
#' @name grouped_glmer
#' @aliases grouped_glmer
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model or model
#'   summaries.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"glance"`,
#'   which will return model summaries.
#' @inheritParams lme4::glmer
#'
#' @importFrom magrittr "%<>%"
#' @importFrom broom tidy
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom purrr map2_dfr
#' @importFrom purrr pmap
#' @importFrom lme4 glmer
#' @importFrom lme4 glmerControl
#' @importFrom stats as.formula
#' @importFrom tibble as_data_frame
#' @importFrom tidyr nest
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
#' @importFrom dplyr mutate_at
#' @importFrom dplyr select
#' @importFrom rlang quo_squash
#' @importFrom rlang enquo
#' @importFrom rlang quo
#'
#' @seealso grouped_lmer
#'
#' @examples
#'
#' # commented because the examples take too much time
#'
#' # categorical outcome; binomial family
#' # groupedstats::grouped_glmer(
#' # formula = Survived ~ Age + (Age |
#' #                             Class),
#' # family = stats::binomial(link = "probit"),
#' # data = groupedstats::Titanic_full,
#' # grouping.vars = Sex
#' # )
#'
#' # continuous outcome; gaussian family
#' # library(gapminder)
#'
#' # groupedstats::grouped_glmer(data = gapminder,
#' # formula = scale(lifeExp) ~ scale(gdpPercap) + (gdpPercap | continent),
#' # family = stats::gaussian(),
#' # control = lme4::lmerControl(
#' #  optimizer = "bobyqa",
#' #   restart_edge = TRUE,
#' #   boundary.tol = 1e-7,
#' #   calc.derivs = FALSE,
#' #   optCtrl = list(maxfun = 2e9)
#' # ),
#' # grouping.vars = year)
#'
#' @export
#'

grouped_glmer <- function(data,
                          grouping.vars,
                          formula,
                          family = stats::binomial(link = "probit"),
                          control = lme4::glmerControl(
                            optimizer = "bobyqa",
                            boundary.tol = 1e-07,
                            calc.derivs = FALSE,
                            use.last.params = FALSE,
                            optCtrl = list(maxfun = 2e9)
                          ),
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
    dplyr::ungroup(x = .)

  # ====================================== custom function ==================================

  # custom function to run tidy operation on every element of list column
  fnlisted <-
    function(list.col,
                 formula,
                 output,
                 family,
                 control) {
      if (output == "tidy") {
        # dataframe with results from glmer
        results_df <-
          list.col %>% # tidying up the output with broom
          purrr::map_dfr(
            .x = .,
            .f = ~broom::tidy(
              x = lme4::glmer(
                formula = stats::as.formula(formula),
                data = (.),
                family = family,
                control = control,
                na.action = na.omit
              ),
              conf.int = TRUE,
              conf.level = 0.95,
              conf.method = "Wald",
              effects = "fixed"
            ),
            .id = "..group"
          )
      } else {
        # dataframe with results from lm
        results_df <-
          list.col %>% # tidying up the output with broom
          purrr::map_dfr(
            .x = .,
            .f = ~broom::glance(
              x = lme4::glmer(
                formula = stats::as.formula(formula),
                data = (.),
                family = family,
                control = control,
                na.action = na.omit
              )
            ),
            .id = "..group"
          )
      }
      return(results_df)
    }

  # ========================== using  custom function on entered dataframe ==================================

  # converting the original dataframe to have a grouping variable column
  df %<>%
    tibble::rownames_to_column(df = ., var = "..group")

  # running the custom function and cleaning the dataframe
  combined_df <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      formula = list(formula),
      output = list(output),
      family = list(family),
      control = list(control)
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
      ggstatsplot:::signif_column(data = ., p = p.value)
  }

  # return the final combined dataframe
  return(combined_df)
}
