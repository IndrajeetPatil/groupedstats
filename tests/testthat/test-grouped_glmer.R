context("grouped_glmer")

# grouped_glmer works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_glmer works",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    # categorical outcome; binomial family
    set.seed(123)
    df1 <- suppressWarnings(groupedstats::grouped_glmer(
      formula = Survived ~ Age + (Age | Class),
      family = stats::binomial(link = "probit"),
      data = groupedstats::Titanic_full,
      grouping.vars = Sex,
      output = "glance"
    ))

    # continuous outcome; gaussian family
    library(gapminder)
    set.seed(123)
    df2 <- suppressWarnings(groupedstats::grouped_glmer(
      data = dplyr::sample_frac(gapminder, size = 0.3),
      formula = scale(lifeExp) ~ scale(gdpPercap) + (gdpPercap | continent),
      family = stats::gaussian(),
      control = lme4::lmerControl(
        optimizer = "bobyqa",
        restart_edge = TRUE,
        boundary.tol = 1e-7,
        calc.derivs = FALSE,
        optCtrl = list(maxfun = 2e9)
      ),
      grouping.vars = c(year),
      output = "tidy",
      tidy.args = list(effects = "fixed")
    ))

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1), c(2L, 7L))
    testthat::expect_equal(dim(df2), c(24L, 6L))

    # testing random values
    testthat::expect_equal(df1$df.residual, c(465L, 1726L))
    testthat::expect_equal(df1$deviance, c(400.2542, 1697.9914), tolerance = 0.001)
  }
)
