context("grouped_summary")

# grouped_summary with numeric measures --------------------------------

testthat::test_that(
  desc = "grouped_summary with numeric measures",
  code = {

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

    # two groups
    set.seed(123)
    df5 <- suppressWarnings(groupedstats::grouped_summary(
      data = dplyr::sample_frac(forcats::gss_cat, 0.1),
      grouping.vars = c(marital, rincome),
      measures = c(age, tvhours)
    ))

    # testing dimensions
    testthat::expect_equal(dim(df1), c(12L, 16L))
    testthat::expect_equal(dim(df2), c(9L, 16L))
    testthat::expect_equal(dim(df3), c(24L, 16L))
    testthat::expect_equal(dim(df4), c(16L, 16L))
    testthat::expect_equal(dim(df5), c(152L, 17L))

    # testing few values
    testthat::expect_equal(df1$mean[7], 5.94, tolerance = 0.001)
    testthat::expect_equal(df2$mean[9], 2.97, tolerance = 0.001)
    testthat::expect_equal(df3$mean[12], 9.51, tolerance = 0.001)
    testthat::expect_equal(df4$mean[11], 3.52, tolerance = 0.001)
  }
)

# grouped_summary with factor measures --------------------------------

testthat::test_that(
  desc = "grouped_summary with factor measures",
  code = {

    set.seed(123)

    # without measures specified (without NA)
    df1 <- groupedstats::grouped_summary(
      data = forcats::gss_cat,
      grouping.vars = marital,
      measures.type = "factor"
    )

    # with measures specified (without NA)
    df2 <- groupedstats::grouped_summary(
      data = forcats::gss_cat,
      grouping.vars = c(marital, race),
      measures.type = "factor",
      measures = c(relig)
    )

    # without measures specified (without NA)
    df3 <- groupedstats::grouped_summary(
      data = dplyr::mutate_if(ggplot2::msleep, is.character, as.factor),
      grouping.vars = vore,
      measures.type = "factor"
    )

    # with measures specified (without NA)
    df4 <- groupedstats::grouped_summary(
      data = dplyr::mutate_if(ggplot2::msleep, is.character, as.factor),
      grouping.vars = vore,
      measures = c(genus:order),
      measures.type = "factor"
    )

    # converting to long format
    df5 <- groupedstats::grouped_summary(
      data = ggplot2::msleep,
      grouping.vars = c(vore),
      measures = c(genus:order),
      measures.type = "factor",
      topcount.long = TRUE
    )

    # testing dimensions
    testthat::expect_equal(dim(df1), c(30L, 9L))
    testthat::expect_equal(dim(df2), c(18L, 10L))
    testthat::expect_equal(dim(df3), c(16L, 9L))
    testthat::expect_equal(dim(df4), c(8L, 9L))
    testthat::expect_equal(dim(df5), c(32L, 4L))

    # testing few values
    testthat::expect_identical(df1$n[7], "5416")
    testthat::expect_identical(df2$n[9], "437")
    testthat::expect_identical(df3$n[12], "5")
    testthat::expect_identical(df4$n[4], "32")
  }
)
