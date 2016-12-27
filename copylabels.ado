*! version 1.0  23dec2016
*Tim Essam, USAID GeoCenter (via Nick Cox)

version 14.1
capture program drop copylabels

program define copylabels
  foreach v of var * {
          local l`v' : variable label `v'
              if `"`l`v''"' == "" {
              local l`v' "`v'"
          }
  }
end
