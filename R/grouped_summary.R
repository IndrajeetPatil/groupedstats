#' @title Descriptive statistics for multiple variables for all grouping
#'   variable levels
#' @name grouped_summary
#' @return Dataframe with descriptive statistics for numeric variables (n, mean,
#'   sd, median, min, max).
#'
#' @param data Dataframe from which variables need to be taken.
#' @param grouping.vars A list of grouping variables. Please use unquoted
#'   arguments (i.e., use `x` and not `"x"`).
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
#' @param k Number of digits.
#' @param ... Currently ignored.
#'
#' @importFrom skimr skim
#' @importFrom dplyr filter_at mutate_at mutate_if n rename group_by ungroup
#' @importFrom dplyr group_modify group_nest summarise
#' @importFrom purrr keep map map_dfr set_names map_chr
#' @importFrom tidyr unnest separate
#' @importFrom tibble enframe
#' @importFrom stats qt
#' @importFrom rlang !!! as_string quo_squash enquo
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
#'
#' # for factors, you can also convert the dataframe to a long format with counts
#' groupedstats::grouped_summary(
#'   data = ggplot2::msleep,
#'   grouping.vars = c(vore),
#'   measures = c(genus:order),
#'   measures.type = "factor",
#'   topcount.long = TRUE
#' )
#' @export

# function body
grouped_summary <- function(data,
                            grouping.vars,
                            measures = NULL,
                            measures.type = "numeric",
                            topcount.long = FALSE,
                            k = 2L,
                            ...) {

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

  # data cleanup -------------------------------------------------------------

  # removing grouping levels that are `NA`
  df %<>%
    dplyr::mutate_if(
      .tbl = .,
      .predicate = purrr::is_bare_character,
      .funs = as.factor
    )

  # summary -------------------------------------------------------------------

  # skimming across groups
  df_results <- dplyr::group_by(.data = df, !!!grouping.vars, .drop = TRUE)

  # what to retain depends on the type of columns needed
  if (measures.type == "numeric") {
    ..f <- base::is.numeric
  } else {
    ..f <- base::is.factor
  }

  # format the number of digits in `skimr` output
  df_skim <-
    dplyr::left_join(
      x = df_results %>%
        dplyr::group_modify(
          .f = ~ as_tibble(skimr::skim(purrr::keep(.x = ., .p = ..f)))
        ) %>%
        dplyr::ungroup(.),
      y = dplyr::summarise(df_results, n_obs = dplyr::n()),
      by = purrr::map_chr(.x = grouping.vars, .f = rlang::as_string)
    ) %>%
    dplyr::mutate(.data = ., n = n_obs - n_missing) %>%
    # changing column names
    dplyr::select(.data = ., -n_obs) %>%
    purrr::set_names(x = ., nm = ~ sub("numeric.|factor.|^n_|_rate$", "", .x))

  # factor long format conversion --------------------------------------------

  if (measures.type %in% c("factor", "character") && isTRUE(topcount.long)) {
    # converting to long format using the custom function
    df_skim %<>%
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
      tidyr::unnest(data = ., cols = c(long.counts))
  }

  # renaming numeric variable ----------------------------------------------

  if (measures.type == "numeric") {
    # changing class of summary variables if these are numeric variables
    df_summary <-
      df_skim %>%
      dplyr::rename(
        .data = .,
        min = p0,
        median = p50,
        max = p100
      ) %>% # computing more descriptive indices
      dplyr::mutate(
        .data = .,
        std.error = sd / sqrt(n),
        mean.conf.low = mean - stats::qt(p = 1 - (0.05 / 2), df = n - 1) * std.error,
        mean.conf.high = mean + stats::qt(p = 1 - (0.05 / 2), df = n - 1) * std.error
      )
  } else {
    df_summary <- df_skim
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
  ) %>%
    dplyr::select(.data = ., -name)
}
