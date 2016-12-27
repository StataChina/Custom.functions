*! version 1.0  23dec2016
*Tim Essam, USAID GeoCenter (via Nick Cox)

version 9.0
capture program drop attachlabels

program define attachlabels
  foreach v of var * {
          label var `v' "`l`v''"
  }
end
