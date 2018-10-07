#' @title Function to get descriptive statistics for multiple variables for all
#'   grouping variable levels
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
#' @importFrom magrittr "%<>%"
#' @importFrom skimr skim_to_wide
#' @importFrom tibble as_data_frame
#' @importFrom purrr is_bare_numeric
#' @importFrom purrr is_bare_character
#' @importFrom purrr map_lgl
#' @importFrom purrr map_dfr
#' @importFrom purrr map
#' @importFrom purrr keep
#' @importFrom tidyr nest
#' @importFrom tidyr unnest
#' @importFrom tidyr separate
#' @importFrom crayon blue
#' @importFrom crayon red
#' @importFrom stats qt
#'
#' @examples
#' 
#' # another possibility
#' groupedstats::grouped_summary(
#'   data = datasets::iris,
#'   grouping.vars = Species,
#'   measures = Sepal.Length:Petal.Width,
#'   measures.type = "numeric"
#' )
#' 
#' # if you have just one variable per argument, you need not use `c()`
#' groupedstats::grouped_summary(
#'   data = datasets::ToothGrowth,
#'   grouping.vars = supp,
#'   measures = len,
#'   measures.type = "numeric"
#' )
#' @export

# function body
grouped_summary <- function(data,
                            grouping.vars,
                            measures = NULL,
                            measures.type = "numeric",
                            topcount.long = FALSE) {
  # ============================== data ========================================

  # check how many variables were entered for this grouping variable
  grouping.vars <-
    base::as.list(x = rlang::quo_squash(quo = rlang::enquo(arg = grouping.vars)))

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

  # getting the dataframe ready
  if (base::missing(measures)) {
    # if the measures are not provided, select all relevant variables *in
    # addition to* grouping variables
    if (measures.type == "numeric") {
      # check if there are any columns of factor type
      numeric_cols <- length(tibble::as_data_frame(
        x = purrr::keep(
          .x = dplyr::select(
            .data = data,
            -c(!!!grouping.vars)
          ),
          .p = purrr::is_bare_numeric
        )
      ))
      # create a dataframe only if this is the case
      if (numeric_cols > 0) {
        # of numeric type
        df <- cbind(
          # select columns corresponding to grouping variables
          dplyr::select(
            .data = data,
            !!!grouping.vars
          ),
          # select all additional columns of numeric type
          purrr::keep(
            .x = dplyr::select(
              .data = data,
              -c(!!!grouping.vars)
            ),
            .p = purrr::is_bare_numeric
          )
        )
      } else {
        # otherwise throw an error with the following message
        base::stop(base::cat(
          crayon::red("Error:"),
          crayon::blue(
            "None of the variables in the dataframe are of numeric type\n"
          )
        ),
        call. = FALSE
        )
      }
    } else if (measures.type == "factor") {
      # check if there are any columns of factor type
      factor_cols <- length(tibble::as_data_frame(x = purrr::keep(
        .x = dplyr::select(
          .data = data,
          -c(!!!grouping.vars)
        ),
        .p = base::is.factor
      )))
      # create a dataframe only if this is the case
      if (factor_cols > 0) {
        # of character/factor type
        df <- cbind(
          # select columns corresponding to grouping variables
          dplyr::select(
            .data = data,
            !!!grouping.vars
          ),
          # select all additional columns of character/factor type
          purrr::keep(
            .x = dplyr::select(
              .data = data,
              -c(!!!grouping.vars)
            ),
            .p = base::is.factor
          )
        )
      } else {
        # otherwise throw an error with the following message
        base::stop(base::cat(
          crayon::red("Error:"),
          crayon::blue(
            "None of the variables in the dataframe are of factor/character type\n"
          )
        ),
        call. = FALSE
        )
      }
    }
  } else {
    # if the measures are provided, select all relevant grouping variables and measures
    df <- dplyr::select(
      .data = data,
      !!!grouping.vars,
      !!rlang::enquo(measures)
    )
  }
  # ================================================== checks ===========================================================
  # when measures have been specified
  if (!base::missing(measures)) {
    # check the class of variables (all have to be of uniform type)
    # numeric
    numeric_count <- sum(purrr::map_lgl(
      .x = dplyr::select(
        .data = data,
        !!rlang::enquo(measures)
      ),
      .f = ~purrr::is_bare_numeric(.)
    ) == FALSE)
    # factor
    # convert factor into characters
    df_char <- dplyr::select(
      .data = data,
      !!rlang::enquo(measures)
    ) %>%
      dplyr::mutate_if(
        .tbl = .,
        .predicate = base::is.factor,
        .funs = as.character
      )

    # count the number of character type variables
    factor_count <- sum(purrr::map_lgl(
      .x = df_char,
      .f = ~purrr::is_bare_character(.)
    ) == FALSE)

    # conditionally stopping the function
    # if a mix type of variables have been entered
    if (numeric_count != 0 && factor_count != 0) {
      base::stop(base::cat(
        crayon::red("Error:"),
        crayon::blue(
          "This function can either be used with numeric or with factor/character variables, but not both\n"
        )
      ),
      call. = FALSE
      )
    }
    # options(show.error.messages = FALSE)
    if (measures.type == "numeric") {
      # if one or more of the variables are not numeric, then stop the execution and let the user know
      if (numeric_count != 0) {
        base::stop(base::cat(
          crayon::red("Error:"),
          crayon::blue("One of the entered variables is not a numeric variable\n")
        ),
        call. = FALSE
        )
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
        call. = FALSE
        )
      }
    }
  }
  # options(show.error.messages = TRUE)
  # ================================================== summary ===========================================================
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
        purrr::map(
          .x = .,
          .f = ~skimr::skim_to_wide(.)
        )
    )

  # ================================================== factor ===========================================================
  #
  if (measures.type == "factor") {
    # tidying up the skimr output by removing unnecessary information and renaming certain columns
    df_summary %<>%
      dplyr::select(.data = ., -data) %>% # removing the redudant data column
      dplyr::mutate(
        .data = .,
        summary = summary %>%
          purrr::map(
            .x = .,
            .f = ~dplyr::select(.data = ., dplyr::everything())
          )
      ) %>% # remove the histograms since they are not that helpful
      tidyr::unnest(data = .) %>% # unnesting the data
      tibble::as_data_frame(x = .) # converting to tibble dataframe
    # =========================================== factor long format conversion ==========================================
    if (isTRUE(topcount.long)) {
      # custom function used to convert counts into long format
      count_long_format_fn <- function(top_counts) {
        purrr::map_dfr(
          .x = base::strsplit(x = top_counts, split = ","),
          .f = ~tibble::as_data_frame(x = .) %>%
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
        dplyr::group_by(.data = ., !!!grouping.vars) %>%
        tidyr::nest(data = .) %>%
        dplyr::mutate(
          .data = .,
          long.counts = data %>%
            purrr::map(
              .x = .,
              .f = ~count_long_format_fn(top_counts = .$top_counts)
            )
        ) %>%
        dplyr::select(.data = ., -data) %>%
        tidyr::unnest(data = .)
      #
      # joining the wide and long format datasets together
      df_summary <-
        dplyr::full_join(x = df_summary, y = df_summary_long)
    }
  }
  # ================================================== numeric ===========================================================
  #
  if (measures.type == "numeric") {
    # tidying up the skimr output by removing unnecessary information and renaming certain columns
    df_summary %<>%
      dplyr::select(.data = ., -data) %>% # removing the redudant data column
      dplyr::mutate(
        .data = .,
        summary = summary %>%
          purrr::map(
            .x = .,
            .f = dplyr::select,
            -hist
          )
      ) %>% # remove the histograms since they are not that helpful
      tidyr::unnest(data = .) %>% # unnesting the data
      tibble::as_data_frame(x = .) # converting to tibble dataframe

    # changing class of summary variables if these are numeric variables
    df_summary %<>%
      dplyr::mutate_at(
        .tbl = .,
        .vars = dplyr::vars(missing, complete, n, mean, sd, p0, p25, p50, p75, p100),
        .funs = ~as.numeric(as.character(.)) # change summary variables to numeric
      ) %>% # renaming variables to more common terminology
      dplyr::rename(
        .data = .,
        min = p0,
        median = p50,
        max = p100
      ) %>% # computing more descriptive indices
      dplyr::mutate(
        .data = .,
        std.error = sd / base::sqrt(n),
        mean.low.conf = mean - stats::qt(p = 1 - (0.05 / 2), df = n - 1, lower.tail = TRUE) * std.error,
        mean.high.conf = mean + stats::qt(p = 1 - (0.05 / 2), df = n - 1, lower.tail = TRUE) * std.error
      )
  }

  # return the summary dataframe
  return(df_summary)
}
