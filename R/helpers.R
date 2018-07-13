#' @title Creating a new character type column with significance labels
#' @name signif_column
#' @aliases signif_column
#' @author Indrajeet Patil
#' @description This function will add a new column to a dataframe containing
#'   p-values
#' @return Returns the originally entered object (either a vector or a
#'   dataframe) in tibble format with an additional column corresponding to
#'   statistical significance.
#'
#' @param data Data frame from which variables specified are preferentially to
#'   be taken.
#' @param p The column containing p-values.
#'
#'
#' @importFrom broom tidy
#' @importFrom crayon red
#' @importFrom crayon blue
#' @importFrom rlang enquo
#' @importFrom stats lm
#' @importFrom tibble as_data_frame
#'
#' @keywords internal
#'
#' @note This is a helper function used internally in the package and not
#'   exported. In case you want to use it, you can do so by
#'   `groupedstats:::signif_column`. Note that it is `:::` and not `::`.
#'

signif_column <- function(data = NULL, p) {
  # storing variable name to be assigned later
  p_lab <- colnames(dplyr::select(.data = data,
                                  !!rlang::enquo(p)))
  # if dataframe is provided
  if (!is.null(data)) {
    df <-
      dplyr::select(.data = data,
                    # column corresponding to p-values
                    p = !!rlang::enquo(p),
                    dplyr::everything())
  } else {
    # if only vector is provided
    df <-
      base::cbind.data.frame(p = p) # column corresponding to p-values
  }

  #make sure the p-value column is numeric; if not, convert it to numeric and give a warning to the user
  if (!is.numeric(df$p)) {
    df$p <- as.numeric(as.character(df$p))
  }
  # add new significance column based on standard APA guidelines for describing different levels of significance
  df <- df %>%
    dplyr::mutate(
      .data = .,
      significance = dplyr::case_when(
        # first condition
        p >= 0.050 ~ "ns",
        # second condition
        p < 0.050 &
          p >= 0.010 ~ "*",
        # third condition
        p < 0.010 &
          p >= 0.001 ~ "**",
        # fourth condition
        p < 0.001 ~ "***"
      )
    ) %>%
    tibble::as_data_frame(x = .) # convert to tibble dataframe
  # change back from the generic p-value to the original name that was provided by the user for the p-value
  if (!is.null(data)) {
    # reordering the dataframe
    df <- df %>%
      dplyr::select(.data = ., -p, -significance, dplyr::everything())
    # renaming the p-value variable with the name provided by the user
    colnames(df)[which(names(df) == "p")] <- p_lab
  }
  # return the final tibble dataframe
  return(df)
}


#'
#' @title Custom function for getting specified number of decimal places in
#'   results for p-value
#' @name specify_decimal_p
#' @aliases specify_decimal_p
#' @description Function to format an R object for pretty printing with a
#'   specified (`k`) number of decimal places. The function also allows highly
#'   significant p-values to be denoted as "p < 0.001" rather than "p = 0.000".
#' @author Indrajeet Patil
#'
#' @param x A numeric variable.
#' @param k Number of digits after decimal point (should be an integer).
#' @param p.value Decides whether the number is a p-value (Default: `FALSE`).
#'
#' @return Formatted numeric values.
#'
#' @keywords internal
#'
#' @note This is a helper function used internally in the package and not
#'   exported. In case you want to use it, you can do so by
#'   `groupedstats:::specify_decimal_p`. Note that it is `:::` and not `::`.
#'

specify_decimal_p <- function(x,
                              k = NULL,
                              p.value = FALSE) {
  # if the number of decimal places hasn't been specified, use the default of 3
  if (is.null(k)) {
    k <- 3
  }
  # formatting the output properly
  output <-
    base::trimws(x = base::format(x = base::round(x = x, digits = k),
                                  nsmall = k),
                 which = "both")
  # if it's a p-value, then format it properly
  if (isTRUE(p.value)) {
    # determing the class of output
    if (output < 0.001) {
      output <- "< 0.001"
    }
  }
  # this will return a character
  return(output)
}


#'
#' @title Confidence intervals for partial eta-squared and omega-squared for
#'   linear models.
#' @name lm_effsize_ci
#' @author Indrajeet Patil
#' @description This function will convert a linear model object to a dataframe
#'   containing statistical details for all effects along with partial
#'   eta-squared effect size and its confidence interval.
#' @return A dataframe with results from `stats::lm()` with partial eta-squared,
#'   omega-squared, and bootstrapped confidence interval for the same.
#'
#' @param object The linear model object (can be of class `lm`, `aov`, or
#'   `aovlist`).
#' @param effsize Character describing the effect size to be displayed: `"eta"`
#'   (default) or `"omega"`.
#' @param partial Logical that decides if partial eta-squared or omega-squared
#'   are returned (Default: `TRUE`).
#' @param conf.level Numeric specifying Level of confidence for the confidence
#'   interval (Default: `0.95`).
#' @param nboot Number of bootstrap samples for confidence intervals for partial
#'   eta-squared and omega-squared (Default: `1000`).
#'
#' @importFrom sjstats eta_sq
#' @importFrom sjstats omega_sq
#' @importFrom stats anova
#' @importFrom stats na.omit
#' @importFrom stats lm
#' @importFrom tibble as_data_frame
#' @importFrom tibble rownames_to_column
#' @importFrom broom tidy
#'
#' @examples
#'
#' # lm object
#' # lm_effsize_ci(object = stats::lm(formula = wt ~ am * cyl, data = mtcars),
#' # effsize = "omega",
#' # partial = TRUE)
#'
#' # aov object
#' # lm_effsize_ci(object = stats::aov(formula = wt ~ am * cyl, data = mtcars),
#' # effsize = "eta",
#' # partial = FALSE)
#'
#' @keywords internal
#'

# defining the function body
lm_effsize_ci <-
  function(object,
           effsize = "eta",
           partial = TRUE,
           conf.level = 0.95,
           nboot = 1000) {
    # based on the class, get the tidy output using broom
    if (class(object)[[1]] == "lm") {
      aov_df <-
        broom::tidy(stats::anova(object = object))
    } else if (class(object)[[1]] == "aov") {
      aov_df <- broom::tidy(x = object)
    } else if (class(object)[[1]] == "aovlist") {
      aov_df <- broom::tidy(x = object) %>%
        dplyr::filter(.data = ., stratum == "Within")
    }

    # create a new column for residual degrees of freedom
    aov_df$df2 <- aov_df$df[aov_df$term == "Residuals"]

    # cleaning up the dataframe
    aov_df %<>%
      dplyr::select(.data = .,
                    -c(base::grep(pattern = "sq",
                                  x = names(.)))) %>% # rename to something more meaningful and tidy
      dplyr::rename(.data = .,
                    df1 = df) %>% # remove NAs, which would remove the row containing Residuals (redundant at this point)
      stats::na.omit(.) %>%
      tibble::as_data_frame(x = .)

    # computing the effect sizes using sjstats
    if (effsize == "eta") {
      # creating dataframe of partial eta-squared effect size and its CI with sjstats
      effsize_df <- sjstats::eta_sq(
        model = object,
        partial = partial,
        ci.lvl = conf.level,
        n = nboot
      )

      if (class(object)[[1]] == "aovlist") {
        effsize_df %<>%
          dplyr::filter(.data = ., stratum == "Within")
      }

    } else if (effsize == "omega") {
      # creating dataframe of partial omega-squared effect size and its CI with sjstats
      effsize_df <- sjstats::omega_sq(
        model = object,
        partial = partial,
        ci.lvl = conf.level,
        n = nboot
      )

      if (class(object)[[1]] == "aovlist") {
        effsize_df %<>%
          dplyr::filter(.data = ., stratum == "Within")
      }
    }

    # combining the dataframes (erge the two preceding pieces of information by the common element of Effect
    combined_df <- dplyr::left_join(x = aov_df,
                                    y = effsize_df,
                                    by = "term") %>% # reordering columns
      dplyr::select(.data = .,
                    term,
                    F.value = statistic,
                    df1,
                    df2,
                    p.value,
                    dplyr::everything()) %>%
      tibble::as_data_frame(x = .)

    # in case of within-subjects design, the stratum columns will be unnecessarily added
    if ("stratum.x" %in% names(combined_df)) {
      combined_df %<>%
        dplyr::select(.data = ., -c(base::grep(pattern = "stratum", x = names(.)))) %>%
        dplyr::mutate(.data = ., stratum = "Within")
    }

    # returning the final dataframe
    return(combined_df)
  }
