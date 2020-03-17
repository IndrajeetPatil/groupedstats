# grouped_lmer works --------------------------------------------------------

testthat::test_that(
  desc = "grouped_lmer works",
  code = {
    testthat::skip_if(getRversion() < "3.6")

    library(gapminder)
    set.seed(123)
    df1 <-
      suppressMessages(suppressWarnings(groupedstats::grouped_lmer(
        data = gapminder,
        formula = scale(lifeExp) ~ scale(gdpPercap) + (gdpPercap | continent),
        grouping.vars = year,
        REML = FALSE,
        tidy.args = list(effects = "fixed", conf.int = TRUE, conf.level = 0.95),
        output = "tidy"
      )))

    # testing dimensions of dataframe
    testthat::expect_equal(dim(df1)[[1]], 24L)
  }
)
