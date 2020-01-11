context("grouped_p_value")

# grouped_p_value works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_p_value works",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    # one grouping var
    set.seed(123)
    df1 <- groupedstats:::grouped_p_value(
      data = dplyr::sample_frac(ggplot2::diamonds, 0.1),
      formula = scale(price) ~ scale(carat),
      grouping.vars = cut,
      ..f = stats::lm
    )

    testthat::expect_equal(dim(df1), c(10L, 3L))
    testthat::expect_identical(names(df1), c("cut", "term", "p.value"))
    testthat::expect_equal(df1$p.value[1], 1, tolerance = 0.001)

    # more than one grouping var
    set.seed(123)
    df2 <- groupedstats:::grouped_p_value(
      data = ggplot2::diamonds,
      formula = scale(price) ~ scale(carat),
      grouping.vars = c(cut, clarity),
      ..f = stats::lm
    )

    testthat::expect_equal(dim(df2), c(80L, 4L))
    testthat::expect_identical(names(df2), c("cut", "clarity", "term", "p.value"))
    testthat::expect_equal(df2$p.value[16], 7.673354e-05, tolerance = 0.001)
  }
)
