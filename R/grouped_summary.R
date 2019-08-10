#' @title Descriptive statistics for multiple variables for all grouping
#'   variable levels
#' @name grouped_summary
#' @author Indrajeet Patil
#' @return Dataframe with descriptive statistics for numeric variables (n, mean,
#'   sd, median, min, max)
#'
#' @param data Dataframe from which variables need to be taken.
#' @param grouping.vars A list of grouping variables.
#' @param measures List variables for which summary needs to computed. If not
#'   specified, all variables of type specified in the argument `measures.type`
#'   will be used to calculate summaries. **Don't** explicitly set
#'   `measures.type = NULL` in function call, which will produce an error
#'   because the function will try to find a column in a dataframe named "NULL".
#' @param measures.type A character indicating whether summary for *numeric*
#'   ("numeric") or *factor/character* ("factor") variables is expected
#'   (Default: `measures.type = "numeric"`). This function can't be used for
#'   both numeric **and** variables simultaneously.
#' @param topcount.long If `measures.type = factor`, you can get the top counts
#'   in long format for plotting purposes. (Default: `topcount.long = FALSE`).
#'
#' @importFrom skimr skim
#' @importFrom dplyr filter_at mutate_at mutate_if group_modify group_nest any_vars
#' @importFrom purrr is_bare_numeric is_bare_character keep map map_lgl map_dfr
#' @importFrom tidyr unnest separate
#' @importFrom crayon red blue
#' @importFrom tibble as_tibble enframe
#' @importFrom stats qt
#' @importFrom utils packageVersion
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#'
#' # another possibility
#' groupedstats::grouped_summary(
#'   data = iris,
#'   grouping.vars = Species,
#'   measures = Sepal.Length:Petal.Width,
#'   measures.type = "numeric"
#' )
#'
#' # if no measures are chosen, all relevant columns will be summarized
#' groupedstats::grouped_summary(
#'   data = ggplot2::msleep,
#'   grouping.vars = vore,
#'   measures.type = "factor"
#' )
#' @export

# function body
grouped_summary <- function(data,
                            grouping.vars,
                            measures = NULL,
                            measures.type = "numeric",
                            topcount.long = FALSE) {
  # check -------------------------------------------------------------------

  if (utils::packageVersion("skimr") >= "2.0") {
    stop(message("This package is currently not compatible with `skimr 2.0` package."))
  }

  # data -------------------------------------------------------------------

  # check how many variables were entered for this grouping variable
  grouping.vars <- as.list(rlang::quo_squash(rlang::enquo(grouping.vars)))

  # based on number of arguments, select grouping.vars in cases like `c(cyl)`,
  # the first list element after `quo_squash` will be `c` which we don't need,
  # but if we pass just `cyl`, there is no `c`, this will take care of that
  # issue
  grouping.vars <-
    if (length(grouping.vars) == 1) {
      grouping.vars
    } else {
      grouping.vars[-1]
    }

  # if no measures are provided, use the entire dataset
  if (missing(measures)) {
    df <- data
  } else {
    df <- dplyr::select(.data = data, !!!grouping.vars, {{ measures }})
  }

  # summary -------------------------------------------------------------------

  # removing grouping levels that are NA
  df %<>%
    dplyr::filter_at(
      .tbl = .,
      .vars = dplyr::vars(!!!grouping.vars),
      .vars_predicate = dplyr::any_vars(!is.na(.))
    ) %>%
    dplyr::mutate_if(
      .tbl = .,
      .predicate = purrr::is_bare_character,
      .funs = as.factor
    )

  # what to retain depends on the type of columns needed
  if (measures.type == "numeric") {
    ..f <- purrr::is_bare_numeric
  } else {
    ..f <- base::is.factor
  }

  # skimming across groups
  df_results <- df %>%
    dplyr::group_by(.data = ., !!!grouping.vars, .drop = TRUE) %>%
    dplyr::group_modify(
      .tbl = .,
      .f = ~ tibble::as_tibble(skimr::skim_to_wide(
        purrr::keep(.x = ., .p = ..f)
      )),
      keep = FALSE
    ) %>%
    dplyr::ungroup(x = .)

  # factor long format conversion --------------------------------------------

  if (measures.type %in% c("factor", "character") && isTRUE(topcount.long)) {
    # converting to long format using the custom function
    df_results %<>%
      dplyr::group_nest(
        .tbl = .,
        !!!grouping.vars,
        .key = "data",
        keep = TRUE
      ) %>%
      dplyr::mutate(
        .data = .,
        long.counts = data %>%
          purrr::map(
            .x = .,
            .f = ~ count_long_format_fn(top_counts = .$top_counts)
          )
      ) %>%
      dplyr::select(.data = ., -data) %>%
      tidyr::unnest(.)
    # tidyr::unnest(., cols = c(long.counts)) # for tidyr 0.8.9
  }

  # renaming numeric variable ----------------------------------------------

  if (measures.type == "numeric") {
    # changing class of summary variables if these are numeric variables
    df_summary <-
      df_results %>%
      dplyr::mutate_at(
        .tbl = .,
        .vars = dplyr::vars(missing:p100),
        .funs = ~ as.numeric(as.character(.)) # change summary variables to numeric
      ) %>% # renaming variables to more common terminology
      dplyr::rename(
        .data = .,
        min = p0,
        median = p50,
        max = p100
      ) %>% # computing more descriptive indices
      dplyr::mutate(
        .data = .,
        std.error = sd / sqrt(n),
        mean.low.conf = mean - stats::qt(
          p = 1 - (0.05 / 2),
          df = n - 1,
          lower.tail = TRUE
        ) * std.error,
        mean.high.conf = mean + stats::qt(
          p = 1 - (0.05 / 2),
          df = n - 1,
          lower.tail = TRUE
        ) * std.error
      )
  } else {
    df_summary <- df_results
  }

  # remove the histogram column
  if ("hist" %in% names(df_summary)) df_summary %<>% dplyr::select(.data = ., -hist)

  # return the summary dataframe
  return(df_summary)
}

#' @keywords internal
#' @noRd

# custom function used to convert counts into long format
count_long_format_fn <- function(top_counts) {
  purrr::map_dfr(
    .x = strsplit(x = top_counts, split = ","),
    .f = ~ tibble::enframe(x = .) %>%
      dplyr::mutate_all(.tbl = ., .funs = trimws) %>%
      tidyr::separate(
        data = .,
        col = "value",
        into = c("factor.level", "count"),
        sep = ":",
        convert = TRUE
      )
  )
}
