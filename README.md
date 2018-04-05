
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
[![Last-changedate](https://img.shields.io/badge/last%20change-2018--04--04-yellowgreen.svg)](/commits/master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-red.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![minimal R
version](https://img.shields.io/badge/R%3E%3D-3.3.0-6666ff.svg)](https://cran.r-project.org/)
<!-- [![Coverage Status](https://img.shields.io/codecov/c/github/IndrajeetPatil/groupedstats/master.svg)](https://codecov.io/github/IndrajeetPatil/groupedstats?branch=master)
[![Dependency Status](http://img.shields.io/gemnasium/IndrajeetPatil/groupedstats.svg)](https://gemnasium.com/IndrajeetPatil/groupedstats) -->

## Overview

`groupedstats` package provides a collection of functions to run
statistical operations on multiple variables across multiple grouping
variables in a dataframe. **This package is still in development. Use at
your own risk\!**

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
?grouped_summary
?grouped_lm
?grouped_robustlm
?grouped_proptest
?grouped_ttest
```

## Usage

  - `grouped_summary`

Getting summary for multiple variables across multiple grouping
variables.

This is a handy tool if you have just one grouping variable and multiple
variables for which summary statistics are to be computed-

``` r
library(datasets)
options(tibble.width = Inf)            # show me all columns

groupedstats::grouped_summary(data = datasets::iris,
                              grouping.vars = Species,
                              measures = c(Sepal.Length:Petal.Width))
#> # A tibble: 12 x 13
#>    Species    type    variable     missing complete     n  mean    sd
#>    <fct>      <fct>   <fct>          <dbl>    <dbl> <dbl> <dbl> <dbl>
#>  1 setosa     numeric Petal.Length      0.      50.   50. 1.46  0.170
#>  2 setosa     numeric Petal.Width       0.      50.   50. 0.250 0.110
#>  3 setosa     numeric Sepal.Length      0.      50.   50. 5.01  0.350
#>  4 setosa     numeric Sepal.Width       0.      50.   50. 3.43  0.380
#>  5 versicolor numeric Petal.Length      0.      50.   50. 4.26  0.470
#>  6 versicolor numeric Petal.Width       0.      50.   50. 1.33  0.200
#>  7 versicolor numeric Sepal.Length      0.      50.   50. 5.94  0.520
#>  8 versicolor numeric Sepal.Width       0.      50.   50. 2.77  0.310
#>  9 virginica  numeric Petal.Length      0.      50.   50. 5.55  0.550
#> 10 virginica  numeric Petal.Width       0.      50.   50. 2.03  0.270
#> 11 virginica  numeric Sepal.Length      0.      50.   50. 6.59  0.640
#> 12 virginica  numeric Sepal.Width       0.      50.   50. 2.97  0.320
#>      min   p25 median   p75   max
#>    <dbl> <dbl>  <dbl> <dbl> <dbl>
#>  1 1.00  1.40   1.50  1.58  1.90 
#>  2 0.100 0.200  0.200 0.300 0.600
#>  3 4.30  4.80   5.00  5.20  5.80 
#>  4 2.30  3.20   3.40  3.68  4.40 
#>  5 3.00  4.00   4.35  4.60  5.10 
#>  6 1.00  1.20   1.30  1.50  1.80 
#>  7 4.90  5.60   5.90  6.30  7.00 
#>  8 2.00  2.52   2.80  3.00  3.40 
#>  9 4.50  5.10   5.55  5.88  6.90 
#> 10 1.40  1.80   2.00  2.30  2.50 
#> 11 4.90  6.23   6.50  6.90  7.90 
#> 12 2.20  2.80   3.00  3.18  3.80
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
                  mapping = ggplot2::aes(x = as.factor(cyl), 
                                         y = mean, 
                                         color = variable)) +
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
options(tibble.width = Inf)            # show me all columns

groupedstats::grouped_lm(data = datasets::iris,
                         dep.vars = c(Sepal.Length, Petal.Length),
                         indep.vars = c(Sepal.Width, Petal.Width),
                         grouping.vars = Species)
#> # A tibble: 6 x 9
#>   Species    formula                    t.value estimate conf.low
#>   <fct>      <chr>                        <dbl>    <dbl>    <dbl>
#> 1 setosa     Sepal.Length ~ Sepal.Width    7.68    0.743   0.548 
#> 2 versicolor Sepal.Length ~ Sepal.Width    4.28    0.526   0.279 
#> 3 virginica  Sepal.Length ~ Sepal.Width    3.56    0.457   0.199 
#> 4 setosa     Petal.Length ~ Petal.Width    2.44    0.332   0.0578
#> 5 versicolor Petal.Length ~ Petal.Width    8.83    0.787   0.607 
#> 6 virginica  Petal.Length ~ Petal.Width    2.36    0.322   0.0474
#>   conf.high std.error  p.value significance
#>       <dbl>     <dbl>    <dbl> <chr>       
#> 1     0.937    0.0967 6.71e-10 ***         
#> 2     0.773    0.123  8.77e- 5 ***         
#> 3     0.715    0.128  8.43e- 4 ***         
#> 4     0.605    0.136  1.86e- 2 *           
#> 5     0.966    0.0891 1.27e-11 ***         
#> 6     0.597    0.137  2.25e- 2 *
```

This can be done with multiple grouping variables. For example, in the
following example, we use the `gapminder` dataset to regress life
expectency and population on GDP per capita for each continent and for
each country.

``` r
library(gapminder)
library(dplyr)
options(tibble.width = Inf)            # show me all columns

groupedstats::grouped_lm(data = gapminder::gapminder,
                         dep.vars = c(lifeExp, pop),
                         indep.vars = c(gdpPercap, gdpPercap),
                         grouping.vars = c(continent, country)) %>%
  dplyr::arrange(.data = ., continent, country)
#> # A tibble: 284 x 10
#>    continent country      formula              t.value estimate conf.low
#>    <fct>     <fct>        <chr>                  <dbl>    <dbl>    <dbl>
#>  1 Africa    Algeria      lifeExp ~ gdpPercap   6.71    0.904      0.604
#>  2 Africa    Algeria      pop ~ gdpPercap       5.04    0.847      0.473
#>  3 Africa    Angola       lifeExp ~ gdpPercap  -0.998  -0.301     -0.973
#>  4 Africa    Angola       pop ~ gdpPercap      -0.964  -0.292     -0.966
#>  5 Africa    Benin        lifeExp ~ gdpPercap   4.98    0.844      0.466
#>  6 Africa    Benin        pop ~ gdpPercap       6.97    0.911      0.620
#>  7 Africa    Botswana     lifeExp ~ gdpPercap   0.0177  0.00560   -0.699
#>  8 Africa    Botswana     pop ~ gdpPercap      18.3     0.985      0.865
#>  9 Africa    Burkina Faso lifeExp ~ gdpPercap   5.91    0.882      0.549
#> 10 Africa    Burkina Faso pop ~ gdpPercap       7.43    0.920      0.644
#>    conf.high std.error       p.value significance
#>        <dbl>     <dbl>         <dbl> <chr>       
#>  1     1.21     0.135  0.0000533     ***         
#>  2     1.22     0.168  0.000503      ***         
#>  3     0.371    0.302  0.342         ns          
#>  4     0.382    0.302  0.358         ns          
#>  5     1.22     0.170  0.000557      ***         
#>  6     1.20     0.131  0.0000386     ***         
#>  7     0.710    0.316  0.986         ns          
#>  8     1.11     0.0539 0.00000000515 ***         
#>  9     1.21     0.149  0.000149      ***         
#> 10     1.20     0.124  0.0000223     ***         
#> # ... with 274 more rows
```

  - `grouped_robustlm`

There is also robust variant of linear regression (as implemented in
`robust::lmRob`)-

``` r
library(gapminder)
library(dplyr)
options(tibble.width = Inf)            # show me all columns

groupedstats::grouped_robustlm(data = gapminder::gapminder,
                         dep.vars = c(lifeExp, pop),
                         indep.vars = c(gdpPercap, gdpPercap),
                         grouping.vars = c(continent, country)) %>%
  dplyr::arrange(.data = ., continent, country)
#> # A tibble: 284 x 8
#>    continent country      formula             t.value estimate std.error
#>    <fct>     <fct>        <chr>                 <dbl>    <dbl>     <dbl>
#>  1 Africa    Algeria      lifeExp ~ gdpPercap   5.82     0.904    0.155 
#>  2 Africa    Algeria      pop ~ gdpPercap       2.49     0.869    0.349 
#>  3 Africa    Angola       lifeExp ~ gdpPercap  -0.734   -0.413    0.563 
#>  4 Africa    Angola       pop ~ gdpPercap      -2.45    -0.541    0.221 
#>  5 Africa    Benin        lifeExp ~ gdpPercap   2.46     0.773    0.315 
#>  6 Africa    Benin        pop ~ gdpPercap       7.18     0.929    0.129 
#>  7 Africa    Botswana     lifeExp ~ gdpPercap   4.42     1.47     0.332 
#>  8 Africa    Botswana     pop ~ gdpPercap      15.3      1.08     0.0706
#>  9 Africa    Burkina Faso lifeExp ~ gdpPercap   2.14     0.882    0.413 
#> 10 Africa    Burkina Faso pop ~ gdpPercap       7.17     0.920    0.128 
#>         p.value significance
#>           <dbl> <chr>       
#>  1 0.000168     ***         
#>  2 0.0319       *           
#>  3 0.480        ns          
#>  4 0.0344       *           
#>  5 0.0338       *           
#>  6 0.0000299    ***         
#>  7 0.00130      **          
#>  8 0.0000000294 ***         
#>  9 0.0583       ns          
#> 10 0.0000304    ***         
#> # ... with 274 more rows
```

  - `grouped_proptest`

This function helps carry out one-sample proportion tests with a unique
variable for multiple grouping variables-

``` r
library(datasets)
options(tibble.width = Inf)            # show me all columns

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

  - `grouped_ttest`

This function can help you carry out t-tests, paired or independent, on
multiple variables across multiple groups. Deomostrating how to use this
function is going to first require getting the `iris` dataset into long
format. Let’s say we want to investigate if `Sepal` part of the flower
has greater measurement (length or width) than `Petal` part of the
flower for **each** *Iris* species.

``` r
# loading the necessary libraries
library(tidyverse)

# converting the iris dataset to long format
iris_long <- datasets::iris %>%
  dplyr::mutate(.data = ., id = dplyr::row_number(x = Species)) %>%
  tidyr::gather(
    data = .,
    key = "condition",
    value = "value",
    Sepal.Length:Petal.Width,
    convert = TRUE,
    factor_key = TRUE
  ) %>%
  tidyr::separate(
    col = "condition",
    into = c("part", "measure"),
    sep = "\\.",
    convert = TRUE
  ) %>%
  tibble::as_data_frame(x = .)

# check the long format iris dataset
iris_long
#> # A tibble: 600 x 5
#>    Species    id part  measure value
#>    <fct>   <int> <chr> <chr>   <dbl>
#>  1 setosa      1 Sepal Length   5.10
#>  2 setosa      2 Sepal Length   4.90
#>  3 setosa      3 Sepal Length   4.70
#>  4 setosa      4 Sepal Length   4.60
#>  5 setosa      5 Sepal Length   5.00
#>  6 setosa      6 Sepal Length   5.40
#>  7 setosa      7 Sepal Length   4.60
#>  8 setosa      8 Sepal Length   5.00
#>  9 setosa      9 Sepal Length   4.40
#> 10 setosa     10 Sepal Length   4.90
#> # ... with 590 more rows

# checking if the Sepal part has different dimentions (value) than Petal part
# for each Species and for each type of measurement (Length and Width)
options(tibble.width = Inf)            # show me all columns

groupedstats::grouped_ttest(
  data = iris_long,
  dep.vars = value,                    # dependent variable
  indep.vars = part,                   # independent variable
  grouping.vars = c(Species, measure), # for each Species and for each measurement
  paired = TRUE                        # paired t-test
)
#> # A tibble: 6 x 11
#>   Species    measure formula      method        t.test estimate conf.low
#>   <fct>      <chr>   <chr>        <fct>          <dbl>    <dbl>    <dbl>
#> 1 setosa     Length  value ~ part Paired t-test  -71.8   -3.54     -3.64
#> 2 versicolor Length  value ~ part Paired t-test  -34.0   -1.68     -1.78
#> 3 virginica  Length  value ~ part Paired t-test  -22.9   -1.04     -1.13
#> 4 setosa     Width   value ~ part Paired t-test  -61.0   -3.18     -3.29
#> 5 versicolor Width   value ~ part Paired t-test  -43.5   -1.44     -1.51
#> 6 virginica  Width   value ~ part Paired t-test  -23.1   -0.948    -1.03
#>   conf.high parameter  p.value significance
#>       <dbl>     <dbl>    <dbl> <chr>       
#> 1    -3.44        49. 2.54e-51 ***         
#> 2    -1.58        49. 9.67e-36 ***         
#> 3    -0.945       49. 7.99e-28 ***         
#> 4    -3.08        49. 7.21e-48 ***         
#> 5    -1.38        49. 8.42e-41 ***         
#> 6    -0.866       49. 5.34e-28 ***
```

<!-- * `grouped_wilcox` -->

<!-- This function is just non-parametric variant of the `grouped_ttest`: -->

<!-- ```{r grouped_wilcox} -->

<!-- # checking if the Sepal part has different dimentions (value) than Petal part -->

<!-- # for each Species and for each type of measurement (Length and Width) -->

<!-- options(tibble.width = Inf)            # show me all columns -->

<!-- groupedstats::grouped_wilcox( -->

<!--   data = iris_long, -->

<!--   dep.vars = value,                    # dependent variable -->

<!--   indep.vars = part,                   # independent variable -->

<!--   grouping.vars = c(Species, measure), # for each Species and for each measurement -->

<!--   paired = TRUE                        # paired Wilcoxon signed rank test with continuity correction -->

<!-- ) -->

<!-- ``` -->
