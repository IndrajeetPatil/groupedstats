#'
#' @title Function to run linear mixed-effects model (lmer) across multiple
#'   grouping variables.
#' @name grouped_lmer
#' @aliases grouped_lmer
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from linear model or model
#'   summaries.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @param output A character describing what output is expected. Two possible
#'   options: `"tidy"` (default), which will return the results, or `"glance"`,
#'   which will return model summaries.
#' @inheritParams lme4::lmer
#' @inheritParams sjstats::p_value.lmerMod
#'
#' @importFrom magrittr "%<>%"
#' @importFrom broom.mixed tidy
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom purrr map2_dfr
#' @importFrom purrr pmap
#' @importFrom lme4 lmer
#' @importFrom lme4 lmerControl
#' @importFrom sjstats p_value
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
#' @importFrom broom.mixed glance
#' @importFrom broom.mixed tidy
#' @importFrom broom.mixed augment
#'
#' @examples
#' 
#' # loading libraries containing data
#' library(ggplot2)
#' library(gapminder)
#' 
#' # getting tidy output of results
#' # let's use only 50% data to speed it up
#' groupedstats::grouped_lmer(
#'   data = dplyr::sample_frac(gapminder, size = 0.5),
#'   formula = scale(lifeExp) ~ scale(gdpPercap) + (gdpPercap | continent),
#'   grouping.vars = year,
#'   output = "tidy"
#' )
#' 
#' # getting model summaries
#' # let's use only 50% data to speed it up
#' grouped_lmer(
#'   data = ggplot2::diamonds,
#'   formula = scale(price) ~ scale(carat) + (carat | color),
#'   REML = FALSE,
#'   grouping.vars = c(cut, clarity),
#'   output = "glance"
#' )
#' @export

grouped_lmer <- function(data,
                         grouping.vars,
                         formula,
                         REML = TRUE,
                         control = lme4::lmerControl(
                           optimizer = "bobyqa",
                           restart_edge = TRUE,
                           boundary.tol = 1e-7,
                           calc.derivs = FALSE,
                           use.last.params = FALSE,
                           optCtrl = list(maxfun = 2e9)
                         ),
                         p.kr = FALSE,
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
                 REML,
                 control,
                 p.kr) {
      if (output == "tidy") {
        # dataframe with results from lmer
        results_df <-
          list.col %>% # tidying up the output with broom.mixed
          purrr::map_dfr(
            .x = .,
            .f = ~broom.mixed::tidy(
              x = lme4::lmer(
                formula = stats::as.formula(formula),
                data = (.),
                REML = REML,
                control = control,
                na.action = na.omit
              ),
              conf.int = TRUE,
              conf.level = 0.95,
              conf.method = "Wald",
              effects = "fixed"
            ),
            .id = "..group"
          ) %>%
          dplyr::rename(.data = ., t.value = statistic) %>%
          dplyr::mutate_at(
            .tbl = .,
            .vars = "term",
            .funs = ~as.character(.)
          )

        # computing p-values
        pval_df <-
          list.col %>% # getting p-values with sjstats package
          purrr::map_dfr(
            .x = .,
            .f = ~sjstats::p_value(
              fit = lme4::lmer(
                formula = stats::as.formula(formula),
                data = (.),
                REML = REML,
                control = control,
                na.action = na.omit
              ),
              p.kr = p.kr
            ),
            .id = "..group"
          ) %>%
          dplyr::select(.data = ., -std.error) %>%
          dplyr::mutate_at(
            .tbl = .,
            .vars = "term",
            .funs = ~as.character(.)
          )

        # combining the two dataframes
        results_df %<>%
          dplyr::full_join(
            x = .,
            y = pval_df,
            by = c("term", "..group")
          )
      } else {
        # dataframe with results from lm
        results_df <-
          list.col %>% # tidying up the output with broom.mixed
          purrr::map_dfr(
            .x = .,
            .f = ~broom.mixed::glance(
              x = lme4::lmer(
                formula = stats::as.formula(formula),
                data = (.),
                REML = REML,
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
    tibble::rownames_to_column(., var = "..group")

  # running the custom function and cleaning the dataframe
  combined_df <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      formula = list(formula),
      output = list(output),
      REML = list(REML),
      control = list(control),
      p.kr = list(p.kr)
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

  # return the final combined dataframe
  return(combined_df)
}
