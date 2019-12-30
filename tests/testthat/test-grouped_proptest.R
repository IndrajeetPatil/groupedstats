context("grouped_proptest")

# grouped_proptest() works --------------------------------

testthat::test_that(
  desc = "grouped_proptest works",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    set.seed(123)
    df1 <- suppressWarnings(groupedstats::grouped_proptest(
      data = mtcars,
      grouping.vars = cyl,
      measure = "am"
    ))

    set.seed(123)
    df2 <- suppressWarnings(groupedstats::grouped_proptest(
      data = dplyr::sample_frac(ggplot2::diamonds, 0.1),
      grouping.vars = c(cut, color),
      measure = clarity
    ))

    set.seed(123)
    df3 <- suppressWarnings(groupedstats::grouped_proptest(
      data = dplyr::sample_frac(ggplot2::diamonds, 0.1),
      grouping.vars = color:clarity,
      measure = cut
    ))

    # testing dimensions
    testthat::expect_equal(dim(df1), c(3L, 8L))
    testthat::expect_equal(dim(df2), c(35L, 15L))
    testthat::expect_equal(dim(df3), c(56L, 12L))

    # testing random values
    testthat::expect_equal(df1$statistic, c(0.143, 2.273, 7.143), tolerance = 0.001)
    testthat::expect_equal(df1$p.value, c(0.705, 0.132, 0.008), tolerance = 0.001)
    testthat::expect_identical(df1$significance, c("ns", "ns", "**"))

    testthat::expect_equal(df2$statistic[5], 200.96, tolerance = 0.001)
    testthat::expect_equal(df2$p.value[33], 0.154, tolerance = 0.001)
    testthat::expect_identical(df2$IF[7], "2.11%")

    testthat::expect_equal(df3$statistic[22], 26.667, tolerance = 0.001)
    testthat::expect_equal(df3$p.value[49], 0.534, tolerance = 0.001)
    testthat::expect_identical(df3$Ideal[8], "38.52%")
  }
)
