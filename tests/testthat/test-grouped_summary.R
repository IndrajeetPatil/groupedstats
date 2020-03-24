# grouped_summary with numeric measures --------------------------------

testthat::test_that(
  desc = "grouped_summary with numeric measures",
  code = {
    testthat::skip_if(getRversion() < "3.6")
    set.seed(123)

    # without measures specified (without NA)
    df1 <- groupedstats::grouped_summary(
      data = iris,
      grouping.vars = Species
    )

    # with measures specified (without NA)
    df2 <- groupedstats::grouped_summary(
      data = iris,
      grouping.vars = Species,
      measures = Sepal.Length:Petal.Length
    )

    # without measures specified (without NA)
    df3 <- suppressWarnings(groupedstats::grouped_summary(
      data = ggplot2::msleep,
      grouping.vars = vore
    ))

    # with measures specified (without NA)
    df4 <- suppressWarnings(groupedstats::grouped_summary(
      data = ggplot2::msleep,
      grouping.vars = vore,
      measures = c(sleep_total:awake)
    ))

    # more than one group
    df5 <- groupedstats::grouped_summary(
      data = ggplot2::diamonds,
      grouping.vars = c(cut, clarity),
      measures = x
    )

    # testing dimensions
    testthat::expect_equal(dim(df1), c(12L, 16L))
    testthat::expect_equal(dim(df2), c(9L, 16L))
    testthat::expect_equal(dim(df3), c(30L, 16L))
    testthat::expect_equal(dim(df4), c(20L, 16L))
    testthat::expect_equal(dim(df5), c(40L, 17L))

    # testing few values
    testthat::expect_equal(df1$mean, c(
      5.006, 3.428, 1.462, 0.246, 5.936, 2.77, 4.26, 1.326, 6.588,
      2.974, 5.552, 2.026
    ), tolerance = 0.001)
    testthat::expect_identical(df2$skim_variable, c(
      "Sepal.Length", "Sepal.Width", "Petal.Length", "Sepal.Length",
      "Sepal.Width", "Petal.Length", "Sepal.Length", "Sepal.Width",
      "Petal.Length"
    ))
    testthat::expect_equal(df3$std.error[[1]],
      1.07116865041126,
      tolerance = 0.001
    )
    testthat::expect_equal(df2$mean[9], 5.552, tolerance = 0.001)
    testthat::expect_equal(df3$mean[12], 366.8773, tolerance = 0.001)
    testthat::expect_equal(df4$mean[11], 0.1611111, tolerance = 0.001)
  }
)

# grouped_summary with factor measures --------------------------------

testthat::test_that(
  desc = "grouped_summary with factor measures",
  code = {
    testthat::skip_if(getRversion() < "3.6")
    set.seed(123)

    # without measures specified (without NA)
    df3 <-
      groupedstats::grouped_summary(
        data = ggplot2::msleep,
        grouping.vars = vore,
        measures.type = "factor"
      )

    # with measures specified (without NA)
    df4 <-
      groupedstats::grouped_summary(
        data = ggplot2::msleep,
        grouping.vars = vore,
        measures = c(genus:order),
        measures.type = "factor"
      )

    # converting to long format
    df5 <-
      groupedstats::grouped_summary(
        data = ggplot2::msleep,
        grouping.vars = c(vore),
        measures = c(genus:order),
        measures.type = "factor",
        topcount.long = TRUE
      )

    # testing dimensions
    testthat::expect_equal(dim(df3), c(20L, 9L))
    testthat::expect_equal(dim(df4), c(10L, 9L))
    testthat::expect_equal(dim(df5), c(40L, 3L))

    # testing few values
    testthat::expect_identical(df3$n[12], 3L)
    testthat::expect_identical(df4$n[4], 32L)
  }
)


# with `variable` and `n` as a column name --------------------------------

testthat::test_that(
  desc = "with `variable` as a column name",
  code = {
    testthat::skip_if(getRversion() < "3.6")
    set.seed(123)

    df <- read.table(
      header = TRUE,
      text = "  hubei self other province
1 HuBei    7    10        5
2 HuBei    2     0        0
3 HuBei    0     0      -22
4 HuBei    2     2        9
5 HuBei   11    -1       -4
6 HuBei    0     0        3
"
    )

    # long form
    long_df <-
      tidyr::pivot_longer(df, 2:4, names_to = "variable", values_to = "y")

    # summary dataframe
    df_summary <- groupedstats::grouped_summary(long_df, variable, y)

    testthat::expect_equal(dim(df_summary), c(3L, 16L))

    df <- dplyr::rename(.data = mtcars, n = wt)
    testthat::expect_equal(
      grouped_summary(df, am, n),
      structure(
        list(
          am = c(0, 1),
          skim_type = c("numeric", "numeric"),
          skim_variable = c("n", "n"),
          missing = c(0L, 0L),
          complete = c(
            1,
            1
          ),
          mean = c(3.76889473684211, 2.411),
          sd = c(
            0.777400146838225,
            0.616981631277085
          ),
          min = c(2.465, 1.513),
          p25 = c(3.4375, 1.935),
          median = c(3.52, 2.32),
          p75 = c(3.8425, 2.78),
          max = c(
            5.424,
            3.57
          ),
          n = c(19L, 13L),
          std.error = c(0.178347825197974, 0.171119915968381),
          mean.conf.low = c(3.39419986005463, 2.03816173167651),
          mean.conf.high = c(
            4.14358961362958,
            2.78383826832349
          )
        ),
        row.names = c(NA, -2L),
        class = c(
          "tbl_df",
          "tbl", "data.frame"
        )
      )
    )
  }
)
