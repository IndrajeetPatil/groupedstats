# groupedstats 0.0.1.9000

MAJOR CHANGES
  - New functions added: `grouped_lm()`, `grouped_lmer()`, `grouped_glmer()`.
  - The package no longer **exports** tidy eval functions; it's not part of the tidyverse.

MINOR CHANGES
  - For numeric variables, `grouped_summary` now also outputs standard error of
    mean and 95% confidence intervals for the mean.
  - Added datasets (`Titanic_full`, `movies_long`).
  
BUG FUXES
  - Some functions were not working if the grouping variable was called `"group"`. Fixed that.
  
# groupedstats 0.0.1

* First version of the package.
