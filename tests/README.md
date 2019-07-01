Tests and Coverage
================
01 July, 2019 10:16:30

  - [Coverage](#coverage)
  - [Unit Tests](#unit-tests)

This output is created by
[covrpage](https://github.com/metrumresearchgroup/covrpage).

## Coverage

Coverage summary is created using the
[covr](https://github.com/r-lib/covr) package.

| Object                                              | Coverage (%) |
| :-------------------------------------------------- | :----------: |
| groupedstats                                        |     3.66     |
| [R/grouped\_aov.R](../R/grouped_aov.R)              |     0.00     |
| [R/grouped\_glm.R](../R/grouped_glm.R)              |     0.00     |
| [R/grouped\_glmer.R](../R/grouped_glmer.R)          |     0.00     |
| [R/grouped\_lm.R](../R/grouped_lm.R)                |     0.00     |
| [R/grouped\_lmer.R](../R/grouped_lmer.R)            |     0.00     |
| [R/grouped\_proptest.R](../R/grouped_proptest.R)    |     0.00     |
| [R/grouped\_robustslr.R](../R/grouped_robustslr.R)  |     0.00     |
| [R/grouped\_slr.R](../R/grouped_slr.R)              |     0.00     |
| [R/grouped\_summary.R](../R/grouped_summary.R)      |     0.00     |
| [R/grouped\_ttest.R](../R/grouped_ttest.R)          |     0.00     |
| [R/grouped\_wilcox.R](../R/grouped_wilcox.R)        |     0.00     |
| [R/lm\_effsize\_ci.R](../R/lm_effsize_ci.R)         |     0.00     |
| [R/set\_cwd.R](../R/set_cwd.R)                      |     0.00     |
| [R/signif\_column.R](../R/signif_column.R)          |    73.53     |
| [R/specify\_decimal\_p.R](../R/specify_decimal_p.R) |    92.86     |

<br>

## Unit Tests

Unit Test summary is created using the
[testthat](https://github.com/r-lib/testthat) package.

| file                                                             | n | time | error | failed | skipped | warning | icon |
| :--------------------------------------------------------------- | -: | ---: | ----: | -----: | ------: | ------: | :--- |
| [test\_grouped\_summary.R](testthat/test_grouped_summary.R)      | 2 | 0.00 |     0 |      0 |       2 |       0 | \+   |
| [test\_lm\_effsize\_ci.R](testthat/test_lm_effsize_ci.R)         | 5 | 0.02 |     0 |      0 |       5 |       0 | \+   |
| [test\_signif\_column.R](testthat/test_signif_column.R)          | 7 | 0.04 |     0 |      0 |       0 |       0 |      |
| [test\_specify\_decimal\_p.R](testthat/test_specify_decimal_p.R) | 8 | 0.00 |     0 |      0 |       0 |       0 |      |

<details open>

<summary> Show Detailed Test Results </summary>

| file                                                                 | context          | test                                           | status  | n | time | icon |
| :------------------------------------------------------------------- | :--------------- | :--------------------------------------------- | :------ | -: | ---: | :--- |
| [test\_grouped\_summary.R](testthat/test_grouped_summary.R#L8)       | grouped\_summary | grouped\_summary with numeric measures         | SKIPPED | 1 | 0.00 | \+   |
| [test\_grouped\_summary.R](testthat/test_grouped_summary.R#L66)      | grouped\_summary | grouped\_summary with factor measures          | SKIPPED | 1 | 0.00 | \+   |
| [test\_lm\_effsize\_ci.R](testthat/test_lm_effsize_ci.R#L8)          | lm\_effsize\_ci  | lm\_effsize\_ci works (eta, partial = FALSE)   | SKIPPED | 1 | 0.02 | \+   |
| [test\_lm\_effsize\_ci.R](testthat/test_lm_effsize_ci.R#L131)        | lm\_effsize\_ci  | lm\_effsize\_ci works (eta, partial = TRUE)    | SKIPPED | 1 | 0.00 | \+   |
| [test\_lm\_effsize\_ci.R](testthat/test_lm_effsize_ci.R#L232)        | lm\_effsize\_ci  | lm\_effsize\_ci works (omega, partial = FALSE) | SKIPPED | 1 | 0.00 | \+   |
| [test\_lm\_effsize\_ci.R](testthat/test_lm_effsize_ci.R#L346)        | lm\_effsize\_ci  | lm\_effsize\_ci works (omega, partial = TRUE)  | SKIPPED | 1 | 0.00 | \+   |
| [test\_lm\_effsize\_ci.R](testthat/test_lm_effsize_ci.R#L459)        | lm\_effsize\_ci  | lm\_effsize\_ci works with ezANOVA             | SKIPPED | 1 | 0.00 | \+   |
| [test\_signif\_column.R](testthat/test_signif_column.R#L36)          | signif column    | signif\_column works                           | PASS    | 7 | 0.04 |      |
| [test\_specify\_decimal\_p.R](testthat/test_specify_decimal_p.R#L23) | Specify decimals | specify\_decimal\_p works                      | PASS    | 8 | 0.00 |      |

| Failed | Warning | Skipped |
| :----- | :------ | :------ |
| \!     | \-      | \+      |

</details>

<details>

<summary> Session Info </summary>

| Field    | Value                            |
| :------- | :------------------------------- |
| Version  | R version 3.6.0 (2019-04-26)     |
| Platform | x86\_64-w64-mingw32/x64 (64-bit) |
| Running  | Windows 10 x64 (build 16299)     |
| Language | English\_United States           |
| Timezone | America/New\_York                |

| Package  | Version |
| :------- | :------ |
| testthat | 2.1.1   |
| covr     | 3.2.1   |
| covrpage | 0.0.70  |

</details>

<!--- Final Status : skipped/warning --->
