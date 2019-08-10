context("grouped_glmer")

# grouped_glmer works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_glmer works",
  code = {

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

    testthat::expect_equal(
      df2$statistic,
      c(
        0.377118165511465,
        5.91607576315662,
        0.532769203261241,
        4.65993257801095,
        0.125675549586989,
        1.43176910615017,
        0.449251300412545,
        1.79964466188591,
        0.143322723968243,
        2.85319088274674,
        0.643501015905394,
        2.10266975724035,
        3.36735061721271,
        2.64396791010531,
        0.983452849047617,
        3.30109649206135,
        0.941649111964351,
        2.76404286124473,
        0.477573282035853,
        3.74305899039299,
        0.479500775424486,
        3.47763632125827,
        1.04197635474036,
        3.26648101867557
      ),
      tolerance = 0.001
    )
  }
)
