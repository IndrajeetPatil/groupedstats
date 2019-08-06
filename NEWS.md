# groupedstats 0.0.7.9000

BREAKING CHANGES

  - `signif_column` no longer works with vectors and expects dataframe (`data`
    argument can no longer be `NULL`, i.e.). This is to remain consistent with
    rest of the functions in this package.

MAJOR CHANGES

  - Flags in `README` that this package is retired and future releases will
    focus only on maintenance and bug fixes. 
  - Code refactoring of all utility functions.

# groupedstats 0.0.7

  - Maintenance release. The only change is that the package relies on
   `broomExtra` instead of `broom` and `broom.mixed.`

# groupedstats 0.0.6
 
NEW FUNCTIONS

  - New re-exported functions: `grouped_tidy`, `grouped_glance`,
    `grouped_augment`. These provide the most general form of `grouped_`
    versions of generic functions from `broom` package family. They can be used
    to carry out grouped analysis for any function that has a `data` argument.

# groupedstats 0.0.5

  - Maintenance release: Makes `groupedstats` compatible with upcoming releases
    of `skimr 2.0` and `dplyr 0.8.0`.

# groupedstats 0.0.4

MAJOR CHANGES

  - New functions exported: `set_cwd()`
  - `specify_decimal_p` has been modified because it produced incorrect results
    when `k < 3` and `p.value = TRUE` (e.g., `0.002` was printed as `< 0.001`).
  - `groupedstats` now depends on `R 3.5.0`. This is because some of its
    dependencies require `3.5.0` to work (e.g., `broom.mixed`).

# groupedstats 0.0.3

MAJOR CHANGES

  - New functions exported: `lm_effsize_ci()`, `signif_column()`,
  `specify_decimal_p()`.

# groupedstats 0.0.2

MAJOR CHANGES

  - New functions added: `grouped_lm()`, `grouped_aov()`, `grouped_lmer()`,
   `grouped_glmer()`.
  - To be consistent with the rest of the regression model functions,
    `grouped_glm` now takes a `formula` argument rather than `dep.vars` and
    `indep.vars` arguments.
  - The package no longer **exports** tidy eval functions; it's not part of the
    tidyverse.

MINOR CHANGES

  - For numeric variables, `grouped_summary` now also outputs standard error of
    mean and 95% confidence intervals for the mean.
  - Added datasets (`Titanic_full`, `movies_long`).
  
BUG FUXES

  - Some functions were not working if the grouping variable was called `"group"`. Fixed that.
  
# groupedstats 0.0.1

* First version of the package.
