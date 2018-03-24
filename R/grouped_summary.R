#'
#' @title Function to get descriptive statistics for multiple variables for all grouping variable levels
#' @name grouped_summary
#' @author Indrajeet Patil
#' @return Dataframe with descriptive statistics for numeric variables (n, mean, sd, median, min, max)
#'
#' @param data Dataframe from which variables need to be taken.
#' @param grouping.vars A list of grouping variables.
#' @param measures List variables for which summary needs to computed (only *numeric* variables should be entered).
#'
#' @import dplyr
#' @import rlang
#'
#' @importFrom skimr skim_to_wide
#' @importFrom tibble as_data_frame
#' @importFrom purrr map
#' @importFrom tidyr nest
#' @importFrom tidyr unnest
#'
#' @examples
#'
#' # if you have multiple variable for each argument
#' grouped_summary(data = mtcars, grouping.vars = c(am, cyl), measures = c(wt, mpg))
#' # if you have just one variable per argument
#' grouped_summary(data = mtcars, grouping.vars = am, measures = wt)
#'
#' @export

# defining global variables and functions to quient the R CMD check notes
utils::globalVariables(
  c(
    "complete",
    "missing",
    "data",
    "hist",
    "median",
    "p0",
    "p100",
    "p50",
    "p25",
    "p75",
    "sd",
    "type"
  )
)

# function body
grouped_summary <- function(data,
                         grouping.vars,
                         measures) {
  # check how many variables were entered for this grouping variable
  grouping.vars <-
    as.list(rlang::quo_squash(rlang::enquo(grouping.vars)))
  grouping.vars <-
    if (length(grouping.vars) == 1) {
      # e.g., in mtcars dataset, grouping.vars = am
      grouping.vars
    } else {
      # e.g., in mtcars dataset, grouping.vars = c(am, cyl)
      grouping.vars[-1]
    }

  # getting the dataframe ready
  df <- dplyr::select(
    .data = data,
    !!!grouping.vars,
    !!rlang::enquo(measures)
  )

  # creating a nested dataframe
  df_nest <- df %>%
    dplyr::group_by(!!!grouping.vars) %>%
    tidyr::nest(data = .)

  # computing summary
  df_summary <- df_nest %>%
    dplyr::mutate(
      .data = .,
      summary = data %>% # 'data' variable is automatically created by tidyr::nest function
        purrr::map(
          .x = .,
          .f = skimr::skim_to_wide
        )
    )

  # tidying up the skimr output by removing unnecessary information and renaming certain columns
  df_summary <- df_summary %>%
    dplyr::select(.data = ., -data) %>% # removing the redudant data column
    dplyr::mutate(
      .data = .,
      summary = summary %>%
        purrr::map(
          .x = .,
          .f = dplyr::select,
          -hist # remove the histograms since they are not that helpful
        )
    ) %>%
    tidyr::unnest(data = .) %>% # unnesting the data
    tibble::as_data_frame(x = .) # converting to tibble dataframe

  # uncomment this when next version of skimr is released
  # # changing class of summary variables
  # df_summary <-
  #   df_summary %>%
  #   dplyr::mutate_at(
  #     .tbl = .,
  #     .vars = dplyr::vars(missing, complete, n, mean, sd, p0, p25, p50, p75, p100),
  #     .funs = ~ as.numeric(as.character(.)) # change summary variables to numeric
  #   ) %>%
  #   dplyr::rename(.data = ., min = p0, median = p50, max = p100) %>% # renaming columns to minimum and maximum
  #   dplyr::mutate_if(
  #     .tbl = .,
  #     .predicate = is.character,
  #     .funs = as.factor
  #   ) # change grouping variables to factors (tibble won't have it though)

  # return the summary dataframe
  return(df_summary)
}
