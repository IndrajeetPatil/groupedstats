
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
[![Last-changedate](https://img.shields.io/badge/last%20change-2018--03--24-yellowgreen.svg)](/commits/master)
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
?grouped_summary
```

## Usage

  - `grouped_summary`

Getting summary for multiple variables across multiple grouping
variables.

``` r
library(datasets)

groupedstats::grouped_summary(data = mtcars,
                              grouping.vars = c(am, cyl),
                              measures = c(disp, wt, mpg))
#> # A tibble: 18 x 14
#>       am   cyl type   variable missing complete n     mean    sd    p0    
#>    <dbl> <dbl> <chr>  <chr>    <chr>   <chr>    <chr> <chr>   <chr> <chr> 
#>  1    1.    6. numer~ disp     0       3        3     "155  ~ 8.66  "145 ~
#>  2    1.    6. numer~ mpg      0       3        3     " 20.5~ 0.75  " 19.~
#>  3    1.    6. numer~ wt       0       3        3     "  2.7~ 0.13  "  2.~
#>  4    1.    4. numer~ disp     0       8        8     93.61   20.48 "71.1~
#>  5    1.    4. numer~ mpg      0       8        8     28.07   " 4.~ "21.4~
#>  6    1.    4. numer~ wt       0       8        8     " 2.04" " 0.~ " 1.5~
#>  7    0.    6. numer~ disp     0       4        4     204.55  44.74 "167.~
#>  8    0.    6. numer~ mpg      0       4        4     " 19.1~ " 1.~ " 17.~
#>  9    0.    6. numer~ wt       0       4        4     "  3.3~ " 0.~ "  3.~
#> 10    0.    8. numer~ disp     0       12       12    357.62  71.82 "275.~
#> 11    0.    8. numer~ mpg      0       12       12    " 15.0~ " 2.~ " 10.~
#> 12    0.    8. numer~ wt       0       12       12    "  4.1~ " 0.~ "  3.~
#> 13    0.    4. numer~ disp     0       3        3     135.87  13.97 "120.~
#> 14    0.    4. numer~ mpg      0       3        3     " 22.9~ " 1.~ " 21.~
#> 15    0.    4. numer~ wt       0       3        3     "  2.9~ " 0.~ "  2.~
#> 16    1.    8. numer~ disp     0       2        2     "326  ~ 35.36 "301 ~
#> 17    1.    8. numer~ mpg      0       2        2     " 15.4~ " 0.~ " 15 ~
#> 18    1.    8. numer~ wt       0       2        2     "  3.3~ " 0.~ "  3.~
#> # ... with 4 more variables: p25 <chr>, p50 <chr>, p75 <chr>, p100 <chr>
```

  - `grouped_lm`

This function can be used to run linear regression between different
pairs of variables across multiple levels of grouping variables. For
example, if we want to assess the linear relationship between
`Sepal.Length` and `Sepal.Width`, **and** `Sepal.Length` and
`Sepal.Width` (notice the order in which variables are being entered)
for all levels of `Species`:

``` r
library(datasets)

groupedstats::grouped_lm(data = iris,
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
following example, we use the
[`gapminder`](https://cran.r-project.org/web/packages/gapminder/index.html)
dataset to regress life expectency and population on GDP per capita for
each continent and for each country.

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
