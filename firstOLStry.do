* First OLS command

* Count the number of parameters in a list
local count : word count a b c 
display "count contains `count'"

* Token - an element in a list
* Using the gettoken command
local mylist y x1 x2

display "mylist contains `mylist'"

* Use gettoken to store first element of mylist in another local
gettoken first : mylist
display "first contains `first'"

* Use gettoken to grab remaining elements and put them in a new list
gettoken first left : mylist
display "first contains `first'"
display "left contains `left'"

* Increase the value of a local macro
local p = 1
local p = `p' + 3
display "p is now `p'"

* If the increment value is 1, then you can use ++ (or --)
local p = 1
local ++p
display "p is now `p'"


* Implement a version of OLS using these tips
*! version 1.0.0 27Jan2016
program define timRegress, eclass
		version 14
		
		syntax varlist
		display "The syntax command puts the vars specified by the "
		display "    user into the local macro varlist"
		display "    varlist contains `varlist'"
		
		matrix accum zpz = `varlist' //create matrix for inverting
		display "matrix accum forms Z'Z"
		matrix list zpz
		
		local p : word count `varlist'
		local p = `p' + 1
		
		matrix xpx					= zpz[2..`p', 2..`p']  //matrices are hard-coded globals
		matrix xpy					= zpz[2..`p', 1]
		matrix xpxi					= syminv(xpx)
		matrix b					= (xpxi * xpy)'
		
		matrix score double xbhat 	= b
		g double res				= (`depvar' - xbhat)
		g double res2				= res^2
		
		summarize res2
		local N						= r(N)
		local sum					= r(sum)
		local s2					= `sum' / (`N'-(`p'-1))
		matrix V					= `s2'*xpxi
		
		ereturn post b V
		ereturn local 			cmd "timRegress"
		ereturn display
end

* Implement a version of OLS using these tips
*! version 1.0.0 27Jan2016
capture program drop timRegress2
program define timRegress2, eclass
		version 14 /// makes matrix temporary
		
		syntax varlist
		gettoken depvar : varlist
		
		tempname zpz xpx xpy xpxi b V
		tempvar xbhat res res2
		
        quietly matrix accum `zpz' = `varlist'
        local p : word count `varlist'
        local p = `p' + 1
		
        matrix `xpx'                = `zpz'[2..`p', 2..`p']
        matrix `xpy'                = `zpz'[2..`p', 1]
        matrix `xpxi'               = syminv(`xpx')
        matrix `b'                  = (`xpxi'*`xpy')'
        quietly matrix score double `xbhat' = `b'
        
		generate double `res'       = (`depvar' - `xbhat')
        generate double `res2'      = (`res')^2
        
		quietly summarize `res2'
        local N                     = r(N)
        local sum                   = r(sum)
        local s2                    = `sum'/(`N'-(`p'-1))
        matrix `V'                  = `s2'*`xpxi'
        
		ereturn post `b' `V'
        ereturn local         cmd   "myregress2"
        ereturn display
end
