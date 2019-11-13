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

    # testing dimensions
    testthat::expect_equal(dim(df1), c(12L, 16L))
    testthat::expect_equal(dim(df2), c(9L, 16L))
    testthat::expect_equal(dim(df3), c(24L, 16L))
    testthat::expect_equal(dim(df4), c(16L, 16L))

    # testing few values
    testthat::expect_equal(df1$mean[7], 4.26, tolerance = 0.001)
    testthat::expect_equal(df2$mean[9], 5.552, tolerance = 0.001)
    testthat::expect_equal(df3$mean[12], 366.8773, tolerance = 0.001)
    testthat::expect_equal(df4$mean[11], 0.1611111, tolerance = 0.001)
  }
)

# grouped_summary with factor measures --------------------------------

testthat::test_that(
  desc = "grouped_summary with factor measures",
  code = {
    set.seed(123)

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
    testthat::expect_equal(dim(df3), c(16L, 9L))
    testthat::expect_equal(dim(df4), c(8L, 9L))
    testthat::expect_equal(dim(df5), c(32L, 3L))

    # testing few values
    testthat::expect_identical(df3$n[12], 3L)
    testthat::expect_identical(df4$n[4], 32L)

    # testing counts
    testthat::expect_identical(
      df5$factor.level,
      c(
        "Pan", "Vul", "Aci", "Cal", "Car", "Cet", "Cin", "Did", "Spe",
        "Equ", "Apl", "Bos", "Rod", "Art", "Per", "Hyr", "Ept", "Myo",
        "Pri", "Sca", "Chi", "Cin", "Mon", "Sor", "Aot", "Bla", "Cer",
        "Con", "Pri", "Sor", "Rod", "Afr"
      )
    )

    testthat::expect_equal(df5$count, c(
      3L, 2L, 1L, 1L, 12L, 3L, 1L, 1L, 3L, 2L, 1L, 1L, 16L, 5L, 3L,
      2L, 1L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 10L, 3L,
      2L, 1L
    ))
  }
)
