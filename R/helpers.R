#' @noRd
#'
#' @importFrom tibble tibble as_tibble

# function body
signif_column <- function(data, p, ...) {
  # add new significance column based on standard APA guidelines
  dplyr::mutate(
    .data = data,
    significance = dplyr::case_when(
      {{ p }} >= 0.050 ~ "ns",
      {{ p }} < 0.050 & {{ p }} >= 0.010 ~ "*",
      {{ p }} < 0.010 & {{ p }} >= 0.001 ~ "**",
      {{ p }} < 0.001 ~ "***"
    )
  ) %>% # convert to tibble dataframe
    tibble::as_tibble(.)
}


#' @noRd

# function body
specify_decimal_p <- function(x, k = 3L, p.value = FALSE, ...) {

  # for example, if p.value is 0.002, it should be displayed as such
  if (k < 3L && isTRUE(p.value)) k <- 3L

  # formatting the output properly
  output <- trimws(format(round(x = x, digits = k), nsmall = k), which = "both")

  # if it's a p-value, then format it properly
  if (isTRUE(p.value) && output < 0.001) output <- prettyNum(x, scientific = TRUE, digits = k)

  # this will return a character
  output
}
