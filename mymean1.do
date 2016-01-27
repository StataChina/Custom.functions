*! version 1.0.0 20Oct2015
capture program drop mymean1
program define mymean1, eclass // define the type of class to return values
	version 14
	
	syntax varlist
	
	
	quietly summarize `varlist'
	local sum 			= r(sum)
	local N				= r(N)
	matrix b			= (1/`N')*`sum'
	capture drop e2		// drop e2 if it exists
	generate double e2 	= (`varlist' - b[1,1])^2
	quietly summarize e2
	
	matrix V			= (1/((`N')*(`N'-1)))*r(sum)
	matrix colnames b	= `varlist'
	matrix colnames V	= `varlist'
	matrix rownames V	= `varlist'
	ereturn post b V	// move results to e(b) and e(V)
	ereturn display		// create standard output table
end
