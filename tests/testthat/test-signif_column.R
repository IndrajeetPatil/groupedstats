context("signif column")

# signif_column works ---------------------------------------------------

test_that(
  desc = "signif_column works",
  code = {
    # for reproducibility
    set.seed(123)

    # with data = NULL
    data1 <- cbind.data.frame(p = c("a", "b"))
    df1 <-
      suppressWarnings(groupedstats::signif_column(
        data = data1,
        p = p,
        messages = FALSE
      ))

    data2 <- cbind.data.frame(x = c("0.01", "0.001", "0.05", "0.0002"))
    df2 <-
      suppressWarnings(groupedstats::signif_column(
        data = data2,
        p = x,
        messages = TRUE
      ))

    # dataframe with p-values
    p.data <- cbind.data.frame(
      x = 1:5,
      y = 1,
      p.value = c(0.1, 0.5, 0.00001, 0.05, 0.01)
    )

    df3 <- groupedstats::signif_column(
      data = p.data,
      p = p.value,
      messages = FALSE
    )

    # testing
    set.seed(123)
    testthat::expect_identical(df1$significance, rep(NA_character_, 2))
    testthat::expect_identical(df1$significance, rep(NA_character_, 2))
    testthat::expect_identical(df2$significance, rep(NA_character_, 4))
    testthat::expect_identical(names(df1), c("p", "significance"))
    testthat::expect_identical(names(df2), c("x", "significance"))
    testthat::expect_identical(names(df3), c("x", "y", "p.value", "significance"))
    testthat::expect_equal(dim(df1), c(2L, 2L))
    testthat::expect_equal(dim(df2), c(4L, 2L))
    testthat::expect_equal(dim(df3), c(5L, 4L))
  }
)
