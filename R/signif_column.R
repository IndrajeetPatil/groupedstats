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
#' @param messages Logical decides whether to produce notes (Default: `TRUE`).
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
signif_column <- function(data = NULL, p, messages = FALSE) {

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
    if (isTRUE(messages)) {
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
    }
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
