# grouped_lm works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_lm works",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    # loading needed libraries
    library(ggplot2)

    # getting tidy output of results
    set.seed(123)
    df1 <-
      groupedstats::grouped_lm(
        data = mtcars,
        grouping.vars = cyl,
        formula = mpg ~ am * wt,
        output = "tidy"
      )

    # getting augmented dataframe
    set.seed(123)
    df2 <-
      groupedstats::grouped_lm(
        data = mtcars,
        grouping.vars = "cyl",
        formula = mpg ~ am * wt,
        output = "augment"
      )

    # getting model summaries
    # diamonds dataset from ggplot2
    set.seed(123)
    df3 <-
      groupedstats::grouped_lm(
        data = diamonds,
        grouping.vars = c("cut", color),
        formula = price ~ carat * clarity,
        output = "glance"
      )

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1)[[1]], 12L)
    testthat::expect_equal(dim(df2)[[1]], 32L)
    testthat::expect_equal(dim(df3)[[1]], 35L)
  }
)
