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
