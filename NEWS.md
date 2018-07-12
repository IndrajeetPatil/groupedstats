# groupedstats 0.0.1.9000

MAJOR CHANGES
  - New functions added: `grouped_lm()`, `grouped_lmer()`.

MINOR CHANGES
  - For numeric variables, `grouped_summary` now also outputs standard error of
    mean and 95% confidence intervals for the mean.
  
BUG FUXES
  - Some functions were not working if the grouping variable was called `"group"`. Fixed that.
  
# groupedstats 0.0.1

* First version of the package.
