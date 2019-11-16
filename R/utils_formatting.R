#' @title Creating a new column with significance labels
#' @name signif_column
#' @author Indrajeet Patil
#' @description This function will add a new column with significance labels to
#'   a dataframe containing *p*-values.
#' @return Returns the dataframe in tibble format with an additional column
#'   corresponding to APA-format statistical significance labels.
#'
#' @param data Data frame from which variables specified are preferentially to
#'   be taken.
#' @param p The column containing *p*-values.
#' @param messages Logical decides whether to produce notes (Default: `TRUE`).
#'
#' @importFrom dplyr group_by summarize n arrange pull
#' @importFrom dplyr mutate mutate_at mutate_if
#' @importFrom rlang !! !!! enquo
#' @importFrom stats lm
#'
#' @family helper_stats
#'
#' @examples
#' # preparing a newdataframe
#' df <- cbind.data.frame(
#'   x = 1:5,
#'   y = 1,
#'   p.value = c(0.1, 0.5, 0.00001, 0.05, 0.01)
#' )
#'
#' # dataframe with significance column
#' groupedstats::signif_column(data = df, p = p.value)
#' @export

# function body
signif_column <- function(data, p, messages = FALSE) {
  # add new significance column based on standard APA guidelines
  data %<>%
    dplyr::mutate(
      .data = .,
      significance = dplyr::case_when(
        {{ p }} >= 0.050 ~ "ns",
        {{ p }} < 0.050 & {{ p }} >= 0.010 ~ "*",
        {{ p }} < 0.010 & {{ p }} >= 0.001 ~ "**",
        {{ p }} < 0.001 ~ "***"
      )
    ) %>% # convert to tibble dataframe
    tibble::as_tibble(x = .)
}


#' @title Formatting numeric (*p*-)values
#' @name specify_decimal_p
#' @author Indrajeet Patil
#'
#' @description Function to format an R object for pretty printing with a
#'   specified (`k`) number of decimal places. The function also allows really
#'   small *p*-values to be denoted as `"p < 0.001"` rather than `"p = 0.000"`.
#'   Note that if `p.value` is set to `TRUE`, the minimum value of `k` allowed
#'   is `3`. If `k` is set to less than 3, the function will ignore entered `k`
#'   value and use `k = 3` instead. **Important**: This function is not
#'   vectorized.
#'
#' @param x A numeric value.
#' @param k Number of digits after decimal point (should be an integer)
#'   (Default: `k = 3`).
#' @param p.value Decides whether the number is a *p*-value (Default: `FALSE`).
#'
#' @return Formatted numeric value.
#'
#' @examples
#' library(groupedstats)
#' specify_decimal_p(x = 0.00001, k = 2, p.value = TRUE)
#' specify_decimal_p(x = 0.008, k = 2, p.value = TRUE)
#' specify_decimal_p(x = 0.008, k = 3, p.value = FALSE)
#' @export

# function body
specify_decimal_p <- function(x, k = 3, p.value = FALSE) {

  # for example, if p.value is 0.002, it should be displayed as such
  if (k < 3 && isTRUE(p.value)) k <- 3

  # formatting the output properly
  output <- trimws(format(round(x = x, digits = k), nsmall = k), which = "both")

  # if it's a p-value, then format it properly
  if (isTRUE(p.value) && output < 0.001) output <- "< 0.001"

  # this will return a character
  return(output)
}
