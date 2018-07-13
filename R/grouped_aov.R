#'
#' @title Function to run analysis of variance (aov) across multiple grouping
#'   variables.
#' @name grouped_aov
#' @aliases grouped_aov
#' @author Indrajeet Patil
#' @return A tibble dataframe with tidy results from anova. No model summaries
#'   available.
#'
#' @param data Dataframe from which variables are to be taken.
#' @param grouping.vars List of grouping variables.
#' @inheritParams stats::aov
#' @inheritParams lm_effsize_ci
#'
#' @importFrom magrittr "%<>%"
#' @importFrom broom tidy
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom purrr map2_dfr
#' @importFrom purrr pmap
#' @importFrom stats aov
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
#' @examples
#'
#' # uses dataset included in the groupedstats package
#' library(groupedstats)
#'
#' groupedstats::grouped_aov(
#' formula = rating ~ belief * outcome * question,
#' data = intent_morality,
#' grouping.vars = item,
#' effsize = "eta"
#' )
#'
#' @export
#'

grouped_aov <- function(data,
                        grouping.vars,
                        formula,
                        effsize = "eta",
                        nboot = 1000) {
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
                      dplyr::everything()) %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(data = .) %>%
    dplyr::ungroup(x = .)

  # ====================================== custom function ==================================

  # custom function to run tidy operation on every element of list column
  fnlisted <-
    function(list.col,
             formula,
             effsize,
             nboot) {

      # getting tidy dataframe with results
        results_df <-
        list.col %>%
        purrr::map_dfr(
          .x = .,
          .f = ~ lm_effsize_ci(
            object = stats::aov(
              formula = stats::as.formula(formula),
              data = (.),
              na.action = na.omit
            ),
            effsize = effsize,
            partial = TRUE,
            nboot = nboot,
            conf.level = 0.95
          ),
          .id = "..group"
        )

      return(results_df)
    }

  #========================== using  custom function on entered dataframe ==================================

  # converting the original dataframe to have a grouping variable column
  df %<>%
    tibble::rownames_to_column(df = ., var = "..group")

  # running the custom function and cleaning the dataframe
  combined_df <- purrr::pmap(
    .l = list(
      list.col = list(df$data),
      formula = list(formula),
      effsize = list(effsize),
      nboot = list(nboot)
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
