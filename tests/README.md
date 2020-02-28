Tests and Coverage
================
28 February, 2020 09:07:58

  - [Coverage](#coverage)
  - [Unit Tests](#unit-tests)

This output is created by
[covrpage](https://github.com/metrumresearchgroup/covrpage).

## Coverage

Coverage summary is created using the
[covr](https://github.com/r-lib/covr) package.

| Object                                           | Coverage (%) |
| :----------------------------------------------- | :----------: |
| groupedstats                                     |    29.69     |
| [R/grouped\_aov.R](../R/grouped_aov.R)           |     0.00     |
| [R/grouped\_glm.R](../R/grouped_glm.R)           |     0.00     |
| [R/grouped\_lm.R](../R/grouped_lm.R)             |     0.00     |
| [R/grouped\_lmer.R](../R/grouped_lmer.R)         |     0.00     |
| [R/grouped\_slr.R](../R/grouped_slr.R)           |     0.00     |
| [R/grouped\_ttest.R](../R/grouped_ttest.R)       |     0.00     |
| [R/grouped\_wilcox.R](../R/grouped_wilcox.R)     |     0.00     |
| [R/grouped\_glmer.R](../R/grouped_glmer.R)       |    68.97     |
| [R/lm\_effsize\_ci.R](../R/lm_effsize_ci.R)      |    84.48     |
| [R/grouped\_p\_value.R](../R/grouped_p_value.R)  |    100.00    |
| [R/grouped\_proptest.R](../R/grouped_proptest.R) |    100.00    |
| [R/grouped\_summary.R](../R/grouped_summary.R)   |    100.00    |

<br>

## Unit Tests

Unit Test summary is created using the
[testthat](https://github.com/r-lib/testthat) package.

| file                                                         |  n |  time | error | failed | skipped | warning | icon |
| :----------------------------------------------------------- | -: | ----: | ----: | -----: | ------: | ------: | :--- |
| [test-grouped\_glm.R](testthat/test-grouped_glm.R)           |  2 |  0.01 |     0 |      0 |       2 |       0 | \+   |
| [test-grouped\_glmer.R](testthat/test-grouped_glmer.R)       |  4 |  5.77 |     0 |      0 |       0 |       0 |      |
| [test-grouped\_lm.R](testthat/test-grouped_lm.R)             |  1 |  0.00 |     0 |      0 |       1 |       0 | \+   |
| [test-grouped\_p\_value.R](testthat/test-grouped_p_value.R)  |  6 |  0.19 |     0 |      0 |       0 |       0 |      |
| [test-grouped\_proptest.R](testthat/test-grouped_proptest.R) | 19 |  0.36 |     0 |      0 |       0 |       0 |      |
| [test-grouped\_summary.R](testthat/test-grouped_summary.R)   | 19 |  2.56 |     0 |      0 |       0 |       0 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R)      | 56 | 11.84 |     0 |      0 |       1 |       0 | \+   |

<details open>

<summary> Show Detailed Test Results </summary>

| file                                                              | context           |                      test                      | status  |  n | time | icon |
| :---------------------------------------------------------------- | :---------------- | :--------------------------------------------: | :------ | -: | ---: | :--- |
| [test-grouped\_glm.R](testthat/test-grouped_glm.R#L9)             | grouped\_glm      |               grouped\_glm works               | SKIPPED |  1 | 0.01 | \+   |
| [test-grouped\_glm.R](testthat/test-grouped_glm.R#L79)            | grouped\_glm      |               grouped\_glm works               | SKIPPED |  1 | 0.00 | \+   |
| [test-grouped\_glmer.R](testthat/test-grouped_glmer.R#L40)        | grouped\_glmer    |              grouped\_glmer works              | PASS    |  4 | 5.77 |      |
| [test-grouped\_lm.R](testthat/test-grouped_lm.R#L10)              | grouped\_lm       |               grouped\_lm works                | SKIPPED |  1 | 0.00 | \+   |
| [test-grouped\_p\_value.R](testthat/test-grouped_p_value.R#L19)   | grouped\_p\_value |            grouped\_p\_value works             | PASS    |  6 | 0.19 |      |
| [test-grouped\_proptest.R](testthat/test-grouped_proptest.R#L32)  | grouped\_proptest |     grouped\_proptest works - without NAs      | PASS    | 11 | 0.26 |      |
| [test-grouped\_proptest.R](testthat/test-grouped_proptest.R#L83)  | grouped\_proptest |       grouped\_proptest works - with NAs       | PASS    |  8 | 0.10 |      |
| [test-grouped\_summary.R](testthat/test-grouped_summary.R#L45)    | grouped\_summary  |     grouped\_summary with numeric measures     | PASS    | 11 | 1.84 |      |
| [test-grouped\_summary.R](testthat/test-grouped_summary.R#L111)   | grouped\_summary  |     grouped\_summary with factor measures      | PASS    |  8 | 0.72 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L66_L69)   | lm\_effsize\_ci   |  lm\_effsize\_ci works (eta, partial = FALSE)  | PASS    | 13 | 5.43 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L188_L191) | lm\_effsize\_ci   |  lm\_effsize\_ci works (eta, partial = TRUE)   | PASS    | 10 | 0.36 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L291_L294) | lm\_effsize\_ci   | lm\_effsize\_ci works (omega, partial = FALSE) | PASS    | 10 | 0.50 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L404_L407) | lm\_effsize\_ci   | lm\_effsize\_ci works (omega, partial = TRUE)  | PASS    | 10 | 1.63 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L505)      | lm\_effsize\_ci   |       lm\_effsize\_ci works with ezANOVA       | PASS    | 12 | 3.92 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L532)      | lm\_effsize\_ci   |        lm\_effsize\_standardizer works         | SKIPPED |  1 | 0.00 | \+   |

| Failed | Warning | Skipped |
| :----- | :------ | :------ |
| \!     | \-      | \+      |

</details>

<details>

<summary> Session Info </summary>

| Field    | Value                            |
| :------- | :------------------------------- |
| Version  | R version 3.6.2 (2019-12-12)     |
| Platform | x86\_64-w64-mingw32/x64 (64-bit) |
| Running  | Windows 10 x64 (build 16299)     |
| Language | English\_United States           |
| Timezone | Europe/Berlin                    |

| Package  | Version |
| :------- | :------ |
| testthat | 2.3.1   |
| covr     | 3.4.0   |
| covrpage | 0.0.70  |

</details>

<!--- Final Status : skipped/warning --->
