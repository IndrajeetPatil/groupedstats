Tests and Coverage
================
10 August, 2019 00:13:36

  - [Coverage](#coverage)
  - [Unit Tests](#unit-tests)

This output is created by
[covrpage](https://github.com/metrumresearchgroup/covrpage).

## Coverage

Coverage summary is created using the
[covr](https://github.com/r-lib/covr) package.

| Object                                             | Coverage (%) |
| :------------------------------------------------- | :----------: |
| groupedstats                                       |    22.29     |
| [R/grouped\_aov.R](../R/grouped_aov.R)             |     0.00     |
| [R/grouped\_glm.R](../R/grouped_glm.R)             |     0.00     |
| [R/grouped\_glmer.R](../R/grouped_glmer.R)         |     0.00     |
| [R/grouped\_lm.R](../R/grouped_lm.R)               |     0.00     |
| [R/grouped\_lmer.R](../R/grouped_lmer.R)           |     0.00     |
| [R/grouped\_robustslr.R](../R/grouped_robustslr.R) |     0.00     |
| [R/grouped\_slr.R](../R/grouped_slr.R)             |     0.00     |
| [R/grouped\_ttest.R](../R/grouped_ttest.R)         |     0.00     |
| [R/grouped\_wilcox.R](../R/grouped_wilcox.R)       |     0.00     |
| [R/set\_cwd.R](../R/set_cwd.R)                     |     0.00     |
| [R/lm\_effsize\_ci.R](../R/lm_effsize_ci.R)        |    84.21     |
| [R/utils\_formatting.R](../R/utils_formatting.R)   |    93.33     |
| [R/grouped\_summary.R](../R/grouped_summary.R)     |    98.97     |
| [R/grouped\_proptest.R](../R/grouped_proptest.R)   |    100.00    |

<br>

## Unit Tests

Unit Test summary is created using the
[testthat](https://github.com/r-lib/testthat) package.

| file                                                                        |  n | time | error | failed | skipped | warning | icon |
| :-------------------------------------------------------------------------- | -: | ---: | ----: | -----: | ------: | ------: | :--- |
| [test-grouped\_lm.R](testthat/test-grouped_lm.R)                            |  1 | 0.02 |     0 |      0 |       1 |       0 | \+   |
| [test-grouped\_proptest.R](testthat/test-grouped_proptest.R)                | 12 | 1.95 |     0 |      0 |       0 |       0 |      |
| [test-grouped\_summary.R](testthat/test-grouped_summary.R)                  | 18 | 5.74 |     0 |      0 |       0 |       0 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R)                     | 55 | 6.92 |     0 |      0 |       0 |       0 |      |
| [test-lm\_effsize\_standardizer.R](testthat/test-lm_effsize_standardizer.R) |  1 | 0.00 |     0 |      0 |       1 |       0 | \+   |
| [test-signif\_column.R](testthat/test-signif_column.R)                      |  9 | 0.01 |     0 |      0 |       0 |       0 |      |
| [test-specify\_decimal\_p.R](testthat/test-specify_decimal_p.R)             |  8 | 0.02 |     0 |      0 |       0 |       0 |      |

<details open>

<summary> Show Detailed Test Results </summary>

| file                                                                           | context                   | test                                           | status  |  n | time | icon |
| :----------------------------------------------------------------------------- | :------------------------ | :--------------------------------------------- | :------ | -: | ---: | :--- |
| [test-grouped\_lm.R](testthat/test-grouped_lm.R#L8)                            | grouped\_lm               | grouped\_lm works                              | SKIPPED |  1 | 0.02 | \+   |
| [test-grouped\_proptest.R](testthat/test-grouped_proptest.R#L31)               | grouped\_proptest         | grouped\_proptest works                        | PASS    | 12 | 1.95 |      |
| [test-grouped\_summary.R](testthat/test-grouped_summary.R#L45)                 | grouped\_summary          | grouped\_summary with numeric measures         | PASS    |  9 | 4.19 |      |
| [test-grouped\_summary.R](testthat/test-grouped_summary.R#L106)                | grouped\_summary          | grouped\_summary with factor measures          | PASS    |  9 | 1.55 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L65_L68)                | lm\_effsize\_ci           | lm\_effsize\_ci works (eta, partial = FALSE)   | PASS    | 13 | 3.70 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L186_L189)              | lm\_effsize\_ci           | lm\_effsize\_ci works (eta, partial = TRUE)    | PASS    | 10 | 0.22 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L288_L291)              | lm\_effsize\_ci           | lm\_effsize\_ci works (omega, partial = FALSE) | PASS    | 10 | 0.27 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L400_L403)              | lm\_effsize\_ci           | lm\_effsize\_ci works (omega, partial = TRUE)  | PASS    | 10 | 1.25 |      |
| [test-lm\_effsize\_ci.R](testthat/test-lm_effsize_ci.R#L499)                   | lm\_effsize\_ci           | lm\_effsize\_ci works with ezANOVA             | PASS    | 12 | 1.48 |      |
| [test-lm\_effsize\_standardizer.R](testthat/test-lm_effsize_standardizer.R#L8) | lm\_effsize\_standardizer | lm\_effsize\_standardizer works                | SKIPPED |  1 | 0.00 | \+   |
| [test-signif\_column.R](testthat/test-signif_column.R#L43)                     | signif column             | signif\_column works                           | PASS    |  9 | 0.01 |      |
| [test-specify\_decimal\_p.R](testthat/test-specify_decimal_p.R#L25)            | Specify decimals          | specify\_decimal\_p works                      | PASS    |  8 | 0.02 |      |

| Failed | Warning | Skipped |
| :----- | :------ | :------ |
| \!     | \-      | \+      |

</details>

<details>

<summary> Session Info </summary>

| Field    | Value                            |
| :------- | :------------------------------- |
| Version  | R version 3.6.1 (2019-07-05)     |
| Platform | x86\_64-w64-mingw32/x64 (64-bit) |
| Running  | Windows 10 x64 (build 16299)     |
| Language | English\_United States           |
| Timezone | America/New\_York                |

| Package  | Version |
| :------- | :------ |
| testthat | 2.2.1   |
| covr     | 3.3.0   |
| covrpage | 0.0.70  |

</details>

<!--- Final Status : skipped/warning --->
