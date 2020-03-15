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
    testthat::expect_equal(dim(df1), c(12L, 9L))
    testthat::expect_equal(dim(df2), c(32L, 10L))
    testthat::expect_equal(dim(df3), c(35L, 14L))

    # testing random values
    # testthat::expect_equal(df1$estimate[2], 30.2986507, tolerance = 0.001)
    # testthat::expect_equal(df2$.resid[3], 0.7595966, tolerance = 0.001)
    # testthat::expect_equal(df3$adj.r.squared[5], 0.9292861, tolerance = 0.001)
  }
)
