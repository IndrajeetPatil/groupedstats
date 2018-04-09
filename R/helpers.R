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
#' @import dplyr
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
#' @param p.value Decides whether the number is a p-value (Dafault: `FALSE`).
#'
#' @return Formatted numeric values.
#'
#' @keywords internal
#'
#' @note This is a helper function used internally in the package and not
#'   exported. In case you want to use it, you can do so by
#'   `groupedstats:::specify_decimal_p`. Note that it is `:::` and not `::`.

specify_decimal_p <- function(x,
                              k = NULL,
                              p.value = FALSE) {
  # if the number of decimal places hasn't been specified, use the default of 3
  if (is.null(k)) {
    k <- 3
  }
  # formatting the output properly
  output <-
    base::trimws(
      x = base::format(
        x = base::round(x = x, digits = k),
        nsmall = k
      ),
      which = "both"
    )
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
