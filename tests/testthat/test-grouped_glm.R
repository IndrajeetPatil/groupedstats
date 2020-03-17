# grouped_glm works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_glm works",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    # getting tidy output of results
    set.seed(123)
    df1 <-
      groupedstats::grouped_glm(
        data = groupedstats::Titanic_full,
        formula = Survived ~ Sex,
        grouping.vars = Class,
        family = stats::binomial(link = "logit")
      )

    # getting model summary
    set.seed(123)
    df2 <-
      groupedstats::grouped_glm(
        data = groupedstats::Titanic_full,
        formula = Survived ~ Sex,
        grouping.vars = Class,
        family = stats::binomial(link = "logit"),
        output = "glance"
      )

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1), c(8L, 9L))
    testthat::expect_equal(dim(df2), c(4L, 9L))
  }
)


# grouped_glm works (> 1 group) ----------------------------------------------

testthat::test_that(
  desc = "grouped_glm works",
  code = {
    testthat::skip_if(getRversion() < "3.6")
    testthat::skip_on_cran()

    # getting tidy output of results
    set.seed(123)
    df1 <-
      suppressWarnings(groupedstats::grouped_glm(
        data = groupedstats::Titanic_full,
        formula = Survived ~ Class,
        grouping.vars = c(Age, Sex),
        family = stats::binomial(link = "logit"),
        output = "tidy"
      ))

    # getting tidy output of results
    set.seed(123)
    df2 <-
      suppressWarnings(groupedstats::grouped_glm(
        data = groupedstats::Titanic_full,
        formula = Survived ~ Class,
        grouping.vars = c(Age, Sex),
        family = stats::binomial(link = "logit"),
        output = "augment",
        augment.args = list(se_fit = TRUE)
      ))

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1)[[1]], 14L)
    testthat::expect_equal(dim(df2)[[1]], 2201L)
  }
)
