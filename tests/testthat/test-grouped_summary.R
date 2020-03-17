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
    testthat::expect_equal(dim(df3), c(24L, 16L))
    testthat::expect_equal(dim(df4), c(16L, 16L))
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
    testthat::expect_equal(df3$std.error,
      c(
        1.07116865041126, 0.588868972409539, 0.0145296632177839, 1.07287371943377,
        0.0342369038673148, 41.7699169307636, 0.862448682145597, 0.188209206241378,
        0.093574236670027, 0.862448682145597, 0.351511874903009, 219.924114575772,
        2.64775376498646, 0.962959846861055, 0.0242161051526754, 2.64775376498646,
        0.0155974036300918, 11.8013082351068, 0.659420598947128, 0.238763456962194,
        0.142760724430519, 0.659420598947128, 0.078726118581906, 5.52170402569428
      ),
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
        data = dplyr::mutate_if(ggplot2::msleep, is.character, as.factor),
        grouping.vars = vore,
        measures.type = "factor"
      )

    # with measures specified (without NA)
    df4 <-
      groupedstats::grouped_summary(
        data = dplyr::mutate_if(ggplot2::msleep, is.character, as.factor),
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
    testthat::expect_equal(dim(df3), c(16L, 9L))
    testthat::expect_equal(dim(df4), c(8L, 9L))
    testthat::expect_equal(dim(df5), c(32L, 3L))

    # testing few values
    testthat::expect_identical(df3$n[12], 3L)
    testthat::expect_identical(df4$n[4], 32L)

    # testing n and counts
    testthat::expect_equal(
      df3$n_unique,
      c(
        19L, 16L, 6L, 6L, 32L, 29L, 9L, 6L, 5L, 5L, 4L, 2L, 20L, 20L,
        8L, 2L
      )
    )
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


# with `variable` as a column name --------------------------------

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
  }
)
