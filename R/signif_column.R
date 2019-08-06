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
#' @importFrom crayon red blue
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

  # make sure the p-value column is numeric; if not, convert it to numeric
  # if (!rlang::is_bare_numeric(data %>% dplyr::pull({{ p }}))) {
  #   # display message about conversion
  #   if (isTRUE(messages)) {
  #     message(cat(
  #       crayon::green("Note: "),
  #       crayon::blue("The entered vector is of class"),
  #       crayon::yellow(class(data %>% dplyr::pull({{ p }}))[[1]]),
  #       crayon::blue("; attempting to convert it to numeric."),
  #       sep = ""
  #     ))
  #   }
  #
  #   # conversion
  #   data %<>% dplyr::mutate(.data = ., {{ p }} := as.numeric(as.character({{ p }})))
  # }

  # add new significance column based on standard APA guidelines for describing
  # different levels of significance
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

  # return the final tibble dataframe
  return(data)
}
