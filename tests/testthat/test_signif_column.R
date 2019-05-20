context("signif column")

test_that(
  desc = "signif_column works",
  code = {
    # for reproducibility
    set.seed(123)

    # with data = NULL
    df1 <-
      suppressWarnings(groupedstats::signif_column(
        p = c("a", "b"),
        messages = FALSE
      ))
    df2 <-
      groupedstats::signif_column(
        p = c("0.01", "0.001", "0.05", "0.0002"),
        messages = FALSE
      )

    # dataframe with p-values
    p.data <- cbind.data.frame(
      x = 1:5,
      y = 1,
      p.value = c(0.1, 0.5, 0.00001, 0.05, 0.01)
    )

    df3 <- groupedstats::signif_column(
      data = p.data, p = p.value,
      messages = FALSE
    )

    # testing
    set.seed(123)

    testthat::expect_identical(object = df1$p[[1]], expected = NA_real_)
    testthat::expect_identical(object = df1$significance[[1]], expected = NA_character_)
    testthat::expect_identical(object = df2$significance[[1]], expected = "*")
    testthat::expect_identical(object = df2$significance[[2]], expected = "**")
    testthat::expect_identical(object = df2$significance[[3]], expected = "ns")
    testthat::expect_identical(object = df2$significance[[4]], expected = "***")
    testthat::expect_equal(object = dim(df3)[2], expected = 4L)
  }
)
