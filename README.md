
<!-- README.md is generated from README.Rmd. Please edit that file -->

# groupedstats: Grouped statistical analysis in a tidy way

[![packageversion](https://img.shields.io/badge/Package%20version-0.0.1.9000-orange.svg?style=flat-square)](commits/master)
[![Travis Build
Status](https://travis-ci.org/IndrajeetPatil/groupedstats.svg?branch=master)](https://travis-ci.org/IndrajeetPatil/groupedstats)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/IndrajeetPatil/groupedstats?branch=master&svg=true)](https://ci.appveyor.com/project/IndrajeetPatil/groupedstats)
[![Licence](https://img.shields.io/badge/licence-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Last-changedate](https://img.shields.io/badge/last%20change-2018--04--02-yellowgreen.svg)](/commits/master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-red.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![minimal R
version](https://img.shields.io/badge/R%3E%3D-3.3.0-6666ff.svg)](https://cran.r-project.org/)
<!-- [![Coverage Status](https://img.shields.io/codecov/c/github/IndrajeetPatil/groupedstats/master.svg)](https://codecov.io/github/IndrajeetPatil/groupedstats?branch=master)
[![Dependency Status](http://img.shields.io/gemnasium/IndrajeetPatil/groupedstats.svg)](https://gemnasium.com/IndrajeetPatil/groupedstats) -->

## Overview

`groupedstats` package provides a collection of functions to run
statistical operations on multiple variables across multiple grouping
variables in a dataframe.

## Installation

You can get the development version from GitHub. If you are in hurry and
want to reduce the time of installation,
prefer-

``` r
# install.packages("devtools")                                # needed package to download from GitHub repo
devtools::install_github(repo = "IndrajeetPatil/groupedstats", # package path on GitHub
                         quick = TRUE)                        # skips docs, demos, and vignettes
```

If time is not a
constraint-

``` r
devtools::install_github(repo = "IndrajeetPatil/groupedstats", # package path on GitHub
                         dependencies = TRUE,                 # installs packages which groupedstats depends on
                         upgrade_dependencies = TRUE          # updates any out of date dependencies
)
```

## Help

Documentation for any function can be accessed with the standard `help`
command-

``` r
?grouped_lm
?grouped_robustlm
?grouped_proptest
?grouped_summary
```

## Usage

  - `grouped_summary`

Getting summary for multiple variables across multiple grouping
variables.

This is a handy tool if you have just one grouping variable and multiple
variables for which summary statistics are to be computed-

``` r
library(datasets)

groupedstats::grouped_summary(data = datasets::iris,
                              grouping.vars = Species,
                              measures = c(Sepal.Length:Petal.Width))
#> # A tibble: 12 x 13
#>    Species  type   variable missing complete     n  mean    sd   min   p25
#>    <fct>    <fct>  <fct>      <dbl>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 setosa   numer~ Petal.L~      0.      50.   50. 1.46  0.170 1.00  1.40 
#>  2 setosa   numer~ Petal.W~      0.      50.   50. 0.250 0.110 0.100 0.200
#>  3 setosa   numer~ Sepal.L~      0.      50.   50. 5.01  0.350 4.30  4.80 
#>  4 setosa   numer~ Sepal.W~      0.      50.   50. 3.43  0.380 2.30  3.20 
#>  5 versico~ numer~ Petal.L~      0.      50.   50. 4.26  0.470 3.00  4.00 
#>  6 versico~ numer~ Petal.W~      0.      50.   50. 1.33  0.200 1.00  1.20 
#>  7 versico~ numer~ Sepal.L~      0.      50.   50. 5.94  0.520 4.90  5.60 
#>  8 versico~ numer~ Sepal.W~      0.      50.   50. 2.77  0.310 2.00  2.52 
#>  9 virgini~ numer~ Petal.L~      0.      50.   50. 5.55  0.550 4.50  5.10 
#> 10 virgini~ numer~ Petal.W~      0.      50.   50. 2.03  0.270 1.40  1.80 
#> 11 virgini~ numer~ Sepal.L~      0.      50.   50. 6.59  0.640 4.90  6.23 
#> 12 virgini~ numer~ Sepal.W~      0.      50.   50. 2.97  0.320 2.20  2.80 
#> # ... with 3 more variables: median <dbl>, p75 <dbl>, max <dbl>
```

Or multiple grouping variables and multiple variables of interest-

``` r
library(datasets)
library(tidyverse)

groupedstats::grouped_summary(
  data = datasets::mtcars,
  grouping.vars = c(am, cyl),
  measures = c(disp, wt, mpg)
) %>%                                                         # further modification with the pipe operator
  dplyr::select(.data = ., -type, -missing, -complete) %>%    # feeding the output into another function
  ggplot2::ggplot(data = .,                                   # note that `.` is just a placeholder for data here
                  mapping = ggplot2::aes(x = as.factor(cyl), y = mean, color = variable)) +
  ggplot2::geom_jitter() +
  ggplot2::labs(x = "No. of cylinders", y = "mean")
```

![](man/figures/README-grouped_summary2-1.png)<!-- -->

As demonstrated, the output from the function is further modifiable and
can be directly outputed into other routines (e.g., preparing a plot of
`mean` and `sd` values in `ggplot2`).

  - `grouped_lm`

This function can be used to run linear regression between different
pairs of variables across multiple levels of grouping variables. For
example, if we want to assess the linear relationship between
`Sepal.Length` and `Sepal.Width`, **and** `Sepal.Length` and
`Sepal.Width` (notice the order in which variables are being entered)
for all levels of `Species`:

``` r
library(datasets)

groupedstats::grouped_lm(data = datasets::iris,
                         crit.vars = c(Sepal.Length, Petal.Length),
                         pred.vars = c(Sepal.Width, Petal.Width),
                         grouping.vars = Species)
#> # A tibble: 6 x 9
#>   Species  formula    estimate conf.low conf.high std.error     t  p.value
#>   <fct>    <chr>         <dbl>    <dbl>     <dbl>     <dbl> <dbl>    <dbl>
#> 1 setosa   Sepal.Len~    0.743   0.548      0.937    0.0967  7.68 6.71e-10
#> 2 versico~ Sepal.Len~    0.526   0.279      0.773    0.123   4.28 8.77e- 5
#> 3 virgini~ Sepal.Len~    0.457   0.199      0.715    0.128   3.56 8.43e- 4
#> 4 setosa   Petal.Len~    0.332   0.0578     0.605    0.136   2.44 1.86e- 2
#> 5 versico~ Petal.Len~    0.787   0.607      0.966    0.0891  8.83 1.27e-11
#> 6 virgini~ Petal.Len~    0.322   0.0474     0.597    0.137   2.36 2.25e- 2
#> # ... with 1 more variable: significance <chr>
```

This can be done with multiple grouping variables. For example, in the
following example, we use the `gapminder` dataset to regress life
expectency and population on GDP per capita for each continent and for
each country.

``` r
library(gapminder)
library(dplyr)

groupedstats::grouped_lm(data = gapminder::gapminder,
                         crit.vars = c(lifeExp, pop),
                         pred.vars = c(gdpPercap, gdpPercap),
                         grouping.vars = c(continent, country)) %>%
  dplyr::arrange(.data = ., continent, country)
#> # A tibble: 284 x 10
#>    continent country    formula      estimate conf.low conf.high std.error
#>    <fct>     <fct>      <chr>           <dbl>    <dbl>     <dbl>     <dbl>
#>  1 Africa    Algeria    lifeExp ~ g~  0.904      0.604     1.21     0.135 
#>  2 Africa    Algeria    pop ~ gdpPe~  0.847      0.473     1.22     0.168 
#>  3 Africa    Angola     lifeExp ~ g~ -0.301     -0.973     0.371    0.302 
#>  4 Africa    Angola     pop ~ gdpPe~ -0.292     -0.966     0.382    0.302 
#>  5 Africa    Benin      lifeExp ~ g~  0.844      0.466     1.22     0.170 
#>  6 Africa    Benin      pop ~ gdpPe~  0.911      0.620     1.20     0.131 
#>  7 Africa    Botswana   lifeExp ~ g~  0.00560   -0.699     0.710    0.316 
#>  8 Africa    Botswana   pop ~ gdpPe~  0.985      0.865     1.11     0.0539
#>  9 Africa    Burkina F~ lifeExp ~ g~  0.882      0.549     1.21     0.149 
#> 10 Africa    Burkina F~ pop ~ gdpPe~  0.920      0.644     1.20     0.124 
#> # ... with 274 more rows, and 3 more variables: t <dbl>, p.value <dbl>,
#> #   significance <chr>
```

  - `grouped_robustlm`

There is also robust variant of linear regression (as implemented in
`robust::lmRob`)-

``` r
library(gapminder)
library(dplyr)

groupedstats::grouped_robustlm(data = gapminder::gapminder,
                         crit.vars = c(lifeExp, pop),
                         pred.vars = c(gdpPercap, gdpPercap),
                         grouping.vars = c(continent, country)) %>%
  dplyr::arrange(.data = ., continent, country)
#> # A tibble: 284 x 8
#>    continent country    formula       estimate std.error       t   p.value
#>    <fct>     <fct>      <chr>            <dbl>     <dbl>   <dbl>     <dbl>
#>  1 Africa    Algeria    lifeExp ~ gd~    0.904    0.155    5.82    1.68e-4
#>  2 Africa    Algeria    pop ~ gdpPer~    0.869    0.349    2.49    3.19e-2
#>  3 Africa    Angola     lifeExp ~ gd~   -0.413    0.563   -0.734   4.80e-1
#>  4 Africa    Angola     pop ~ gdpPer~   -0.541    0.221   -2.45    3.44e-2
#>  5 Africa    Benin      lifeExp ~ gd~    0.773    0.315    2.46    3.38e-2
#>  6 Africa    Benin      pop ~ gdpPer~    0.929    0.129    7.18    2.99e-5
#>  7 Africa    Botswana   lifeExp ~ gd~    1.47     0.332    4.42    1.30e-3
#>  8 Africa    Botswana   pop ~ gdpPer~    1.08     0.0706  15.3     2.94e-8
#>  9 Africa    Burkina F~ lifeExp ~ gd~    0.882    0.413    2.14    5.83e-2
#> 10 Africa    Burkina F~ pop ~ gdpPer~    0.920    0.128    7.17    3.04e-5
#> # ... with 274 more rows, and 1 more variable: significance <chr>
```

  - `grouped_proptest`

This function helps carry out one-sample proportion tests with a unique
variable for multiple grouping variables-

``` r
library(datasets)

groupedstats::grouped_proptest(data = mtcars,
                               grouping.vars = cyl,
                               measure = am)
#> # A tibble: 3 x 7
#>     cyl `0`    `1`    `Chi-squared`    df `p-value` significance
#>   <dbl> <chr>  <chr>          <dbl> <dbl>     <dbl> <chr>       
#> 1    6. 57.14% 42.86%         0.143    1.   0.705   ns          
#> 2    4. 27.27% 72.73%         2.27     1.   0.132   ns          
#> 3    8. 85.71% 14.29%         7.14     1.   0.00800 **
```
