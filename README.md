
<!-- README.md is generated from README.Rmd. Please edit that file -->

# groupedstats: Grouped statistical analysis in a tidy way

[![CRAN\_Release\_Badge](https://www.r-pkg.org/badges/version-ago/groupedstats)](https://CRAN.R-project.org/package=groupedstats)
[![CRAN
Checks](https://cranchecks.info/badges/summary/groupedstats)](https://cran.r-project.org/web/checks/check_results_groupedstats.html)
[![R build
status](https://github.com/IndrajeetPatil/groupedstats/workflows/R-CMD-check/badge.svg)](https://github.com/IndrajeetPatil/groupedstats)
[![pkgdown](https://github.com/IndrajeetPatil/groupedstats/workflows/pkgdown/badge.svg)](https://github.com/IndrajeetPatil/groupedstats/actions)

# Retirement

------------------------------------------------------------------------

This package is no longer under active development and no new
functionality will be added. You should instead be using `group_map()`,
`group_modify()` and `group_walk()` functions from `dplyr`. See:
<https://dplyr.tidyverse.org/reference/group_map.html>

This is for two reasons-

1.  `dplyr 0.8.1` introduced `group_map()`, `group_modify()` and
    `group_walk()` functions that can be used to iterate on grouped
    dataframes. So if you want to do `grouped_` operations, I would
    highly recommend using these functions over `groupedstats` functions
    since the former are much more general, efficient, and faster than
    the latter. For more, see:
    <https://dplyr.tidyverse.org/reference/group_map.html>

2.  There are more general versions of these functions introduced in
    `broomExtra` package:<br> `grouped_tidy`, `grouped_augment`,
    `grouped_glance`. For more, see:
    <https://indrajeetpatil.github.io/broomExtra/reference/index.html#section-grouped-variants-of-generics>

------------------------------------------------------------------------

# Installation

| Type        | Source | Command                                                  |
|-------------|--------|----------------------------------------------------------|
| Release     | CRAN   | `install.packages("groupedstats")`                       |
| Development | GitHub | `remotes::install_github("IndrajeetPatil/groupedstats")` |
