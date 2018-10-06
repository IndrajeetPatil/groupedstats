#' @title Creating a new character type column with significance labels
#' @name signif_column
#' @aliases signif_column
#' @author Indrajeet Patil
#' @description This function will add a new column to a dataframe containing
#'   *p*-values
#' @return Returns the originally entered object (either a vector or a
#'   dataframe) in tibble format with an additional column corresponding to
#'   statistical significance.
#'
#' @param data Data frame from which variables specified are preferentially to
#'   be taken.
#' @param p The column containing p-values.
#'
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr n
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
#' @importFrom dplyr mutate_at
#' @importFrom dplyr mutate_if
#' @importFrom magrittr "%<>%"
#' @importFrom magrittr "%>%"
#' @importFrom broom tidy
#' @importFrom crayon red
#' @importFrom crayon blue
#' @importFrom rlang enquo
#' @importFrom stats lm
#' @importFrom tibble as_data_frame
#'
#' @family helper_stats
#'
#' @examples
#' 
#' # vector as input
#' groupedstats::signif_column(p = c(0.05, 0.1, 1, 0.00001, 0.001, 0.01))
#' 
#' # dataframe as input
#' # preparing a newdataframe
#' df <- cbind.data.frame(
#'   x = 1:5,
#'   y = 1,
#'   p.value = c(0.1, 0.5, 0.00001, 0.05, 0.01)
#' )
#' 
#' groupedstats::signif_column(data = df, p = p.value)
#' 
#' # numbers entered as characters are also tolerated
#' groupedstats::signif_column(p = c("1", "0.1", "0.0002", "0.03", "0.65"))
#' @export

# function body
signif_column <- function(data = NULL, p) {

  # if dataframe is provided
  if (!is.null(data)) {

    # storing variable name to be assigned later
    p_lab <- colnames(dplyr::select(
      .data = data,
      !!rlang::enquo(p)
    ))

    # preparing dataframe
    df <-
      dplyr::select(
        .data = data,
        # column corresponding to p-values
        p = !!rlang::enquo(p),
        dplyr::everything()
      )
  } else {

    # if only vector is provided
    df <-
      base::cbind.data.frame(p = p)
  }

  # make sure the p-value column is numeric; if not, convert it to numeric
  if (!is.numeric(df$p)) {

    # display message about conversion
    base::message(cat(
      crayon::green("Note: "),
      crayon::blue(
        "The entered vector is of class",
        crayon::yellow(class(df$p)[[1]]),
        "; attempting to convert it to numeric."
      ),
      sep = ""
    ))

    # conversion
    df$p <- as.numeric(as.character(df$p))
  }

  # add new significance column based on standard APA guidelines for describing
  # different levels of significance
  df %<>%
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

  # change back from the generic p-value to the original name that was provided
  # by the user for the p-value
  if (!is.null(data)) {

    # reordering the dataframe
    df %<>%
      dplyr::select(.data = ., -p, -significance, dplyr::everything())

    # renaming the p-value variable with the name provided by the user
    colnames(df)[which(names(df) == "p")] <- p_lab
  }

  # return the final tibble dataframe
  return(df)
}

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
#' @param object The linear model object (can be of class `lm`, `aov`, `anova`, or
#'   `aovlist`).
#' @param effsize Character describing the effect size to be displayed: `"eta"`
#'   (default) or `"omega"`.
#' @param partial Logical that decides if partial eta-squared or omega-squared
#'   are returned (Default: `TRUE`). If `FALSE`, eta-squared or omega-squared
#'   will be returned. Valid only for objects of class `lm`, `aov`, `anova`, or
#'   `aovlist`.
#' @param conf.level Numeric specifying Level of confidence for the confidence
#'   interval (Default: `0.95`).
#' @param nboot Number of bootstrap samples for confidence intervals for partial
#'   eta-squared and omega-squared (Default: `500`).
#'
#' @importFrom sjstats eta_sq
#' @importFrom sjstats omega_sq
#' @importFrom stats anova
#' @importFrom stats na.omit
#' @importFrom stats lm
#' @importFrom tibble as_data_frame
#' @importFrom broom tidy
#'
#' @export

# defining the function body
lm_effsize_ci <-
  function(object,
             effsize = "eta",
             partial = TRUE,
             conf.level = 0.95,
             nboot = 500) {

    # based on the class, get the tidy output using broom
    if (class(object)[[1]] == "lm") {
      aov_df <-
        broom::tidy(stats::anova(object = object))
    } else if (class(object)[[1]] %in% c("aov", "anova")) {
      aov_df <- broom::tidy(x = object)
    } else if (class(object)[[1]] == "aovlist") {
      aov_df <- broom::tidy(x = object) %>%
        dplyr::filter(.data = ., stratum == "Within")
    }

    # create a new column for residual degrees of freedom
    aov_df$df2 <- aov_df$df[aov_df$term == "Residuals"]

    # cleaning up the dataframe
    aov_df %<>%
      dplyr::select(
        .data = .,
        -c(base::grep(
          pattern = "sq",
          x = names(.)
        ))
      ) %>% # rename to something more meaningful and tidy
      dplyr::rename(
        .data = .,
        df1 = df
      ) %>% # remove NAs, which would remove the row containing Residuals (redundant at this point)
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
    combined_df <- dplyr::left_join(
      x = aov_df,
      y = effsize_df,
      by = "term"
    ) %>% # reordering columns
      dplyr::select(
        .data = .,
        term,
        F.value = statistic,
        df1,
        df2,
        p.value,
        dplyr::everything()
      ) %>%
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
