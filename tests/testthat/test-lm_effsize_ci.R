# lm_effsize_standardizer works --------------------------------

testthat::test_that(
  desc = "lm_effsize_standardizer works",
  code = {
    testthat::skip_if(getRversion() < "3.6")
    testthat::skip_on_cran()

    # creating lm object-1
    set.seed(123)
    df1 <-
      groupedstats::lm_effsize_standardizer(
        object = stats::lm(formula = brainwt ~ vore, data = ggplot2::msleep),
        effsize = "eta",
        partial = FALSE
      )

    set.seed(123)
    df2 <-
      groupedstats::lm_effsize_standardizer(
        object = stats::lm(formula = brainwt ~ vore, data = ggplot2::msleep),
        effsize = "eta",
        partial = TRUE
      )

    set.seed(123)
    df3 <-
      groupedstats::lm_effsize_standardizer(
        object = stats::lm(formula = brainwt ~ vore, data = ggplot2::msleep),
        effsize = "omega",
        partial = FALSE
      )

    set.seed(123)
    df4 <-
      groupedstats::lm_effsize_standardizer(
        object = stats::lm(formula = brainwt ~ vore, data = ggplot2::msleep),
        effsize = "omega",
        partial = TRUE
      )

    testthat::expect_equal(df1$F.value, df2$F.value, tolerance = 0.0001)
    testthat::expect_equal(df3$p.value, df4$p.value, tolerance = 0.0001)
    testthat::expect_equal(df1$df1, df3$df1, tolerance = 0.0001)
    testthat::expect_equal(df3$df2, df4$df2, tolerance = 0.0001)
    testthat::expect_identical(
      c(names(df1)[6], names(df2)[6], names(df3)[6], names(df4)[6]),
      rep("estimate", 4)
    )
  }
)
