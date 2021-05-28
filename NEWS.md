# groupedstats 2.1.0

  - Gets rid of a `NOTE` in CRAN's daily checks.
  
  - `groupedstats` now depends on `R 4.1.0`.

# groupedstats 2.0.1

  - Resubmitting package to address script breakage complaints from the users.

# groupedstats 2.0.0

  - Removes all re-exported functions and removes `ipmisc` from dependencies.

# groupedstats 1.0.1

  - Fixes failing tests and warnings with the upcoming release of `dplyr
    1.0.0`.

  - Removes datasets since all of them are already present in `ggstatsplot`.

# groupedstats 1.0.0

  - Relies on `effectsize` package instead of `sjstats` to compute eta and omega
    squared effect sizes in `lm_effsize_ci` function. This is a breaking change
    because the effect size names are slightly different (e.g., what `sjstats`
    stored in a column `etasq` is not renamed to `eta.sq`).

# groupedstats 0.2.2

  - Adapts to upcoming releases of `lme4` and `dplyr 1.0.0`

  - `grouped_summary` no longer removes `NA`s in a grouping variable.

# groupedstats 0.2.1

  - `grouped_summary` function failed when the dataframe contained a column
    named `variable` (#24). This is fixed.

  - Makes package compatible with the new releases of `rlang` and `tidyselect`.

# groupedstats 0.2.0

  - This is a maintenance release that gets rid of some of the internal
    functions by relying on `ipmisc` package.

# groupedstats 0.1.1

BREAKING CHANGES

  - The R package `robust` was recently orphaned. Because of this,
    `grouped_robustslr` has been removed.

# groupedstats 0.1.0

BREAKING CHANGES

  - To be consistent with other packages that `groupedstats` relies on or
    supports the confidence intervals columns for `grouped_summary` have been
    renamed to `mean.conf.high` and `mean.conf.low`.

  - To be consistent with the rest of the functions, `grouped_lmer` and
    `grouped_glmer` follow the same syntax as `grouped_lm`.

MINOR CHANGES

  - `grouped_summary` can now work with labeled data (#14).

  - `grouped_summary` outputs might differ slightly with `skimr 2.0`.

# groupedstats 0.0.9

MAJOR CHANGES

  - Major refactoring of all generalized regression model functions using
    `broomExtra` generic functions.

# groupedstats 0.0.8

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

  - Some functions were not working if the grouping variable was called
    `"group"`. Fixed that.

# groupedstats 0.0.1

* First version of the package.

