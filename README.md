
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

# Overview

`groupedstats` package provides a collection of functions to run
statistical operations on multiple variables across multiple grouping
variables in a dataframe. This is a common situation, as illustrated by
few example cases-

1.  If you have combined multiple studies in a single dataframe and want
    to run a common operation (e.g., linear regression) on **each
    study**. In this case, column corresponding to `study` will be the
    grouping variable.

2.  If you have multiple groups in your dataframe (e.g., clinical
    disorder groups and controls group) and you want to carry out the
    same operation for **each group** (e.g., planned t-test to check for
    differences in reaction time in condition 1 versus condition 2 for
    both groups). In this case, `group` will be the grouping variable.

3.  If you have multiple conditions in a given study (e.g., six types of
    videos participants saw) and want to run a common operation between
    different measures of interest for **each condition** (e.g.,
    correlation between subjective rating of emotional intensity and
    reaction time).

4.  Combination of all of the above.

# Installation

| Type        | Source | Command                                                  |
|-------------|--------|----------------------------------------------------------|
| Release     | CRAN   | `install.packages("groupedstats")`                       |
| Development | GitHub | `remotes::install_github("IndrajeetPatil/groupedstats")` |
