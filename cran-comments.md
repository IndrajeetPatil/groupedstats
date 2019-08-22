## Test environments
* local Windows install, R 3.6.0
* ubuntu 14.04 (on travis-ci), R 3.6.0
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

## Comments

  - Minor code refactoring.
  - This leads to breakage of one dependency `ggstatsplot` which I maintain. I
    will submit a new version of `ggstatsplot` as soon as `groupedstats` makes
    it to `CRAN`.
