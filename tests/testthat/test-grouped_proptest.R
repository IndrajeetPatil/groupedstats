context("grouped_proptest")

# grouped_proptest() works - without NA --------------------------------

testthat::test_that(
  desc = "grouped_proptest works - without NAs",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    set.seed(123)
    df1 <- suppressWarnings(groupedstats::grouped_proptest(
      data = mtcars,
      grouping.vars = cyl,
      measure = am
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
    testthat::expect_equal(
      df1$statistic,
      c(2.27272727272727, 0.142857142857143, 7.14285714285714),
      tolerance = 0.001
    )
    testthat::expect_equal(
      df1$p.value,
      c(0.131668016022815, 0.705456986111273, 0.00752631516645789),
      tolerance = 0.001
    )
    testthat::expect_identical(df1$significance, c("ns", "ns", "**"))

    testthat::expect_equal(df2$statistic[5], 28.44444, tolerance = 0.001)
    testthat::expect_equal(df2$p.value[2], 0.1538342, tolerance = 0.001)

    testthat::expect_equal(df3$statistic[22], 58.44444, tolerance = 0.001)
    testthat::expect_equal(df3$p.value[49], 0.7357589, tolerance = 0.001)
    testthat::expect_identical(df3$Ideal[8], "40.00%")
  }
)


# grouped_proptest() works - with NA ------------------------------------

testthat::test_that(
  desc = "grouped_proptest works - with NAs",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    set.seed(123)
    df1 <-
      suppressWarnings(groupedstats::grouped_proptest(
        data = ggplot2::msleep,
        grouping.vars = vore,
        measure = conservation
      ))

    set.seed(123)
    df2 <-
      suppressWarnings(groupedstats::grouped_proptest(
        data = ggplot2::mpg,
        grouping.vars = c(cyl, drv),
        measure = fl
      ))

    # testing dimensions
    testthat::expect_equal(dim(df1), c(5L, 13L))
    testthat::expect_equal(dim(df2), c(9L, 12L))

    # testing random values
    testthat::expect_equal(
      df1$statistic,
      c(
        6.57142857142857,
        13.6923076923077,
        0.333333333333333,
        5.44444444444444,
        NA
      ),
      tolerance = 0.001
    )
    testthat::expect_equal(
      df1$p.value,
      c(
        0.254513522084723,
        0.0176866932128162,
        0.563702861650773,
        0.0196306572572907,
        NA
      ),
      tolerance = 0.001
    )
    testthat::expect_identical(df1$significance, c("ns", "*", "ns", "*", NA))

    testthat::expect_equal(
      df2$statistic,
      c(
        2.1304347826087,
        66.551724137931,
        NA,
        26.6875,
        35.4883720930233,
        NA,
        65.1666666666667,
        NA,
        10.2857142857143
      ),
      tolerance = 0.001
    )
    testthat::expect_equal(
      df2$p.value,
      c(
        0.144399792213071,
        2.33550613453558e-14,
        NA,
        1.60281355683532e-06,
        1.96697080606916e-08,
        NA,
        4.62070538371468e-14,
        NA,
        0.00584097734319525
      ),
      tolerance = 0.001
    )
    testthat::expect_identical(df2$d, c(NA, "5.17%", NA, "3.12%", NA, NA, "2.08%", NA, NA))
  }
)
