#Dobson Umkehr code things to fix before it can be published

## Not in order - update each when fixed.

1. Retrieve profiles in log space needs to be fixed.
2. L curve diagnostics needs to be coded in correctly.
3. Evening and morning measurements needs to be coded in properly.
4. Needs netcdf format functionality, as well as original text format.
5. Code in extra output - all layers, as well as Umkehr layers.
6. Speed up nvaluezs. - Fixed: [more efficient code can be found here](https://bitbucket.org/kstone4/umkehr_algorithm/commits/c04cc59768e944cfbcfc8402cb52889dd72499a9)
7. Try to speed up zenithpaths
8. Cloudy flag switch needs to be implemented.
9. Potential for multiple scattering needs to be coded in.
10. Potential for stray light needs to be coded in.
11. zenith paths gtan in iteration 2 may not be implemented properly, should be in phi2 as well as ds2.

