context("Specify decimals")

# specify_decimal_p works --------------------------------------------------

test_that(
  desc = "specify_decimal_p works",
  code = {

    # for reproducibility
    set.seed(123)

    # creating objects to test
    string1 <- specify_decimal_p(x = .00001234)
    string2 <- specify_decimal_p(x = .00001234, p.value = TRUE)
    string3 <- specify_decimal_p(x = .00001234, p.value = TRUE, k = 8)
    string4 <- specify_decimal_p(x = 0.001, k = 4, p.value = TRUE)
    string5 <- groupedstats::specify_decimal_p(x = 0.0001, k = 4, p.value = TRUE)
    string6 <- groupedstats::specify_decimal_p(x = 0.0001, k = 3, p.value = TRUE)
    string7 <- groupedstats::specify_decimal_p(x = 0.0001, k = 3, p.value = FALSE)

    # testing
    set.seed(123)

    # tests
    testthat::expect_match(object = string1, regexp = "0.000")
    testthat::expect_match(object = string2, regexp = "< 0.001")
    testthat::expect_match(object = string3, regexp = "1.234e-05")
    testthat::expect_error(object = specify_decimal_p("123"))
    testthat::expect_match(object = string4, regexp = "0.0010")
    testthat::expect_match(object = string5, regexp = "1e-04")
    testthat::expect_match(object = string6, regexp = "< 0.001")
    testthat::expect_match(object = string7, regexp = "0.000")
  }
)
