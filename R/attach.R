.onAttach <- function(...) {
  packageStartupMessage(
    "This package is no longer being maintained and might be removed from CRAN in future.
    You should instead be using `group_map()`, `group_modify()` and `group_walk()` functions
    from `dplyr`. See: https://dplyr.tidyverse.org/reference/group_map.html"
  )
}
