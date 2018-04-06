#'
#' @title Function to run proportion test on grouped data.
#' @name grouped_proptest
#' @author Indrajeet Patil
#' @return Dataframe with percentages and statistical details from a proportion
#'  test.
#'
#' @param data Dataframe from which variables are to be drawn.
#' @param grouping.vars List of grouping variables
#' @param measure A variable for which proportion test needs to be carried out
#'  for each combination of levels of factors entered in `grouping.vars`.
#'
#' @import dplyr
#' @import rlang
#'
#' @importFrom purrr map
#' @importFrom tidyr nest
#' @importFrom tidyr unnest
#' @importFrom tidyr spread
#'
#' @export

# defining global variables and functions to quient the R CMD check notes
utils::globalVariables(
  c(
    "Df",
    "F value",
    "F.value",
    "LL",
    "Pr(>F)",
    "UL",
    "complete",
    "data",
    "df1",
    "df2",
    "effect",
    "effsize",
    "formula",
    "hist",
    "median",
    "p0",
    "p100",
    "p50",
    "p25",
    "p75",
    "sd",
    "type",
    "Chi-squared",
    "df",
    "p-value",
    "chi_sq",
    "significance"
  )
)

grouped_proptest <- function(data,
                             grouping.vars,
                             measure) {
  # turn off warning messages because there are going to be many of them for tidyr::unnest
  options(warn = -1)
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
    measure = !!rlang::enquo(measure)
  )

  # creating a nested dataframe
  df_nest <- df %>%
    dplyr::group_by(!!!grouping.vars) %>%
    tidyr::nest(data = .)

  # creating the final results with the
  df_results <- df_nest %>%
    dplyr::mutate(
      .data = .,
      percentage = data %>% purrr::map(
        .x = .,
        .f = ~dplyr::group_by(.data = ., measure) %>%
          dplyr::summarize(.data = ., counts = length(measure)) %>%
          dplyr::mutate(
            .data = .,
            perc = paste0(specify_decimal_p(
              x = (counts / sum(counts)) * 100, k = 2
            ), "%", sep = "")
          ) %>%
          dplyr::select(.data = ., -counts) %>%
          tidyr::spread(
            data = .,
            key = measure,
            value = perc
          )
      )
    ) %>%
    dplyr::mutate(
      .data = .,
      chi_sq = data %>% purrr::map(
        .x = .,
        .f = ~stats::chisq.test(x = base::table(.$measure))
      )
    ) %>%
    dplyr::mutate(
      .data = .,
      results = chi_sq %>% purrr::map(
        .x = .,
        .f = ~
        base::cbind.data.frame(
          "Chi-squared" = as.numeric(as.character(
            specify_decimal_p(x = .$statistic, k = 3)
          )),
          "df" = as.numeric(as.character(
            specify_decimal_p(x = .$parameter, k = 0)
          )),
          "p-value" = as.numeric(as.character(
            specify_decimal_p(
              x = .$p.value,
              k = 3
            )
          ))
        )
      )
    ) %>%
    dplyr::select(.data = ., -data, -chi_sq) %>%
    tidyr::unnest(data = .) %>%
    signif_column(data = ., p = `p-value`)

  # for every level of grouping.vars, it is going to throw following errors
  # Warning in bind_rows_(x, .id) :
  # Unequal factor levels: coercing to character
  # Warning in bind_rows_(x, .id) :
  #   binding character and factor vector, coercing into character vector
  # Warning in bind_rows_(x, .id) :
  #   binding character and factor vector, coercing into character vector

  # this is due different columns having different types

  # clean up after yourself and change the options back to what are R base defaults
  options(warn = 1)

  # return the final results
  return(df_results)
}
