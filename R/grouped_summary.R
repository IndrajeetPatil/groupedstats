#'
#' @title Function to get descriptive statistics for multiple variables for all
#'   grouping variable levels
#' @name grouped_summary
#' @author Indrajeet Patil
#' @return Dataframe with descriptive statistics for numeric variables (n, mean,
#'   sd, median, min, max)
#'
#' @param data Dataframe from which variables need to be taken.
#' @param grouping.vars A list of grouping variables.
#' @param measures List variables for which summary needs to computed.
#' @param measures.type A character indicating whether summary for *numeric*
#'   ("numeric") or *factor/character* ("factor") variables is expected
#'   (Default: `measures.type = "numeric"`). This function can't be used for
#'   both numeric **and** variables simultaneously.
#' @param topcount.long If `measures.type = factor`, you can get the top counts
#'   in long format for plotting purposes. (Default: `topcount.long = FALSE`).
#'
#' @import dplyr
#' @import rlang
#'
#' @importFrom magrittr "%<>%"
#' @importFrom skimr skim_to_wide
#' @importFrom tibble as_data_frame
#' @importFrom purrr is_bare_numeric
#' @importFrom purrr is_bare_character
#' @importFrom purrr map_lgl
#' @importFrom purrr map_dfr
#' @importFrom purrr map
#' @importFrom tidyr nest
#' @importFrom tidyr unnest
#' @importFrom tidyr separate
#' @importFrom crayon blue
#' @importFrom crayon red
#'
#' @examples
#'
#' library(datasets)
#'
#' # if you have multiple variable for each argument
#' groupedstats::grouped_summary(
#' data = datasets::mtcars,
#' grouping.vars = c(am, cyl),
#' measures = c(wt, mpg)
#' )
#'
#' # another possibility
#' groupedstats::grouped_summary(
#' data = datasets::iris,
#' grouping.vars = Species,
#' measures = Sepal.Length:Petal.Width,
#' measures.type = "numeric"
#' )
#'
#' # if you have just one variable per argument, you can also not use `c()`
#' groupedstats::grouped_summary(
#' data = datasets::ToothGrowth,
#' grouping.vars = supp,
#' measures = len,
#' measures.type = "numeric"
#' )
#'
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
                            measures,
                            measures.type = "numeric",
                            topcount.long = FALSE) {
  #================================================== data ===========================================================
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
  df <- dplyr::select(.data = data,
                      !!!grouping.vars,
                      !!rlang::enquo(measures))

  #================================================== checks ===========================================================
  #
  # check the class of variables (all have to be of uniform type)
  # numeric
  numeric_count <- sum(purrr::map_lgl(
    .x = dplyr::select(.data = data,
                       !!rlang::enquo(measures)),
    .f = ~ purrr::is_bare_numeric(.)
  ) == FALSE)
  # factor
  # convert factor into characters
  df_char <- dplyr::select(.data = data,
                           !!rlang::enquo(measures)) %>%
    dplyr::mutate_if(.tbl = .,
                     .predicate = base::is.factor,
                     .funs = as.character)

  # count the number of character type variables
  factor_count <- sum(purrr::map_lgl(.x = df_char,
                                     .f = ~ purrr::is_bare_character(.)) == FALSE)

  # conditionally stopping the function
  # if a mix type of variables have been entered
  if (numeric_count != 0 && factor_count != 0) {
    base::stop(base::cat(
      crayon::red("Error:"),
      crayon::blue(
        "This function can either be used with numeric or with factor/character variables, but not both\n"
      )
    ),
    call. = FALSE)
  }
  #options(show.error.messages = FALSE)
  if (measures.type == "numeric") {
    # if one or more of the variables are not numeric, then stop the execution and let the user know
    if (numeric_count != 0) {
      base::stop(base::cat(
        crayon::red("Error:"),
        crayon::blue("One of the entered variables is not a numeric variable\n")
      ),
      call. = FALSE)
    }
  } else if (measures.type == "factor") {
    # if one or more of the variables are not numeric, then stop the execution and let the user know
    if (factor_count != 0) {
      base::stop(base::cat(
        crayon::red("Error:"),
        crayon::blue(
          "One of the entered variables is not a factor/character variable\n"
        )
      ),
      call. = FALSE)
    }
  }
  #options(show.error.messages = TRUE)
  #================================================== summary ===========================================================
  #
  # creating a nested dataframe
  df_nest <- df %>%
    dplyr::group_by(.data = ., !!!grouping.vars) %>%
    tidyr::nest(data = .)

  # computing summary
  df_summary <- df_nest %>%
    dplyr::mutate(
      .data = .,
      summary = data %>% # 'data' variable is automatically created by tidyr::nest function
        purrr::map(.x = .,
                   .f = ~ skimr::skim_to_wide(.))
    )

  #================================================== factor ===========================================================
  #
  if (factor_count == 0 && measures.type == "factor") {
    # tidying up the skimr output by removing unnecessary information and renaming certain columns
    df_summary %<>%
      dplyr::select(.data = ., -data) %>% # removing the redudant data column
      dplyr::mutate(.data = .,
                    summary = summary %>%
                      purrr::map(
                        .x = .,
                        .f = ~ dplyr::select(.data = ., dplyr::everything())
                      )) %>% # remove the histograms since they are not that helpful
      tidyr::unnest(data = .) %>% # unnesting the data
      tibble::as_data_frame(x = .) # converting to tibble dataframe
    #=========================================== factor long format conversion ==========================================
    if (isTRUE(topcount.long)) {
      # custom function used to convert counts into long format
      count_long_format_fn <- function(top_counts) {
        purrr::map_dfr(
          .x = base::strsplit(x = top_counts, split = ","),
          .f = ~ tibble::as_data_frame(x = .) %>%
            dplyr::mutate_all(.tbl = ., .funs = base::trimws) %>%
            tidyr::separate(
              data = .,
              col = "value",
              into = c("factor.level", "count"),
              sep = ":",
              convert = TRUE
            )
        )
      }
      #
      # converting to long format using the custom function
      df_summary_long <- df_summary %>%
        dplyr::group_by(!!!grouping.vars) %>%
        tidyr::nest(data = .) %>%
        dplyr::mutate(
          .data = .,
          long.counts = data %>%
            purrr::map(
              .x = .,
              .f = ~ count_long_format_fn(top_counts = .$top_counts)
            )
        ) %>%
        dplyr::select(.data = ., -data) %>%
        tidyr::unnest(data = .)
      #
      # joining the wide and long format datasets together
      df_summary <-
        dplyr::full_join(x =  df_summary, y = df_summary_long)
    }
  }
  #================================================== numeric ===========================================================
  #
  if (numeric_count == 0 && measures.type == "numeric") {
    # tidying up the skimr output by removing unnecessary information and renaming certain columns
    df_summary %<>%
      dplyr::select(.data = ., -data) %>% # removing the redudant data column
      dplyr::mutate(
        .data = .,
        summary = summary %>%
          purrr::map(.x = .,
                     .f = dplyr::select,
                     -hist)
      ) %>% # remove the histograms since they are not that helpful
      tidyr::unnest(data = .) %>% # unnesting the data
      tibble::as_data_frame(x = .) # converting to tibble dataframe

    # changing class of summary variables if these are numeric variables
    df_summary %<>%
      dplyr::mutate_at(
        .tbl = .,
        .vars = dplyr::vars(missing, complete, n, mean, sd, p0, p25, p50, p75, p100),
        .funs = ~ as.numeric(as.character(.)) # change summary variables to numeric
      ) %>%
      dplyr::rename(
        .data = .,
        min = p0,
        median = p50,
        max = p100
      ) %>% # renaming columns to minimum and maximum
      dplyr::mutate_if(.tbl = .,
                       .predicate = is.character,
                       .funs = as.factor) # change grouping variables to factors (tibble won't have it though)
  }
  # return the summary dataframe
  return(df_summary)
}
