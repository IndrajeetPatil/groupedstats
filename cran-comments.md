## Test environments
* local Windows install, R 3.6.0
* ubuntu 14.04 (on travis-ci), R 3.6.0
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

## Comments

  - Maintenance release that adds three new functions.
  - 1 NOTE: `"Missing or unexported object: 'skimr::skim_to_wide'"` This is
    deliberate behavior. The new version of `skimr 2.0` will be submitted to
    `CRAN` soon and will remove `skimr::skim_to_wide()` function. 
