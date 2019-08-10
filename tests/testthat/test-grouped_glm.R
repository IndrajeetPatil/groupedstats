context("grouped_glm")

# grouped_glm works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_glm works",
  code = {

    # getting tidy output of results
    set.seed(123)
    df1 <- groupedstats::grouped_glm(
      data = groupedstats::Titanic_full,
      formula = Survived ~ Sex,
      grouping.vars = Class,
      family = stats::binomial(link = "logit")
    )

    # getting model summary
    set.seed(123)
    df2 <- groupedstats::grouped_glm(
      data = groupedstats::Titanic_full,
      formula = Survived ~ Sex,
      grouping.vars = Class,
      family = stats::binomial(link = "logit"),
      output = "glance"
    )

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1), c(8L, 9L))
    testthat::expect_equal(dim(df2), c(4L, 9L))

    # testing random values
    testthat::expect_identical(
      df1$significance,
      c("***", "***", "***", "***", "ns", "***", "**", "***")
    )
    testthat::expect_equal(
      df1$std.error,
      c(
        0.507040404056601,
        0.53074813223895,
        0.296099310015913,
        0.366289886347662,
        0.14333519505157,
        0.185138910403373,
        0.61913815072164,
        0.624526149861306
      ),
      tolerance = 0.001
    )

    testthat::expect_equal(df2$df.residual, c(323L, 283L, 704L, 883L))
    testthat::expect_equal(df2$nobs, c(325L, 285L, 706L, 885L))
    testthat::expect_equal(
      df2$null.deviance,
      c(
        430.143606108449,
        386.627328032038,
        797.296095842663,
        974.488337501298
      ),
      tolerance = 0.001
    )
  }
)


# grouped_glm works (> 1 group) ----------------------------------------------

testthat::test_that(
  desc = "grouped_glm works",
  code = {
    testthat::skip_on_cran()

    # getting tidy output of results
    set.seed(123)
    df1 <- suppressWarnings(groupedstats::grouped_glm(
      data = groupedstats::Titanic_full,
      formula = Survived ~ Class,
      grouping.vars = c(Age, Sex),
      family = stats::binomial(link = "logit"),
      output = "tidy"
    ))

    # getting tidy output of results
    set.seed(123)
    df2 <- suppressWarnings(groupedstats::grouped_glm(
      data = groupedstats::Titanic_full,
      formula = Survived ~ Class,
      grouping.vars = c(Age, Sex),
      family = stats::binomial(link = "logit"),
      output = "augment",
      augment.args = list(se_fit = TRUE)
    ))

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1), c(14L, 10L))
    testthat::expect_equal(dim(df2), c(2201L, 11L))

    # testing random values
    testthat::expect_equal(df1$p.value[8], 0.003893803, tolerance = 0.001)
  }
)
