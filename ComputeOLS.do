* Estimate OLS using matrices from Stata Blog
* URL: http://blog.stata.com/2015/11/

sysuse auto, clear

* What are the variables in the model
* price is dep var, mpg trunk are indep vars
matrix accum zpz = price mpg trunk

* Show th matrix, note that a constant is added by default
matrix list zpz

* Extract out the submatrices for (x'x)^-1 and x'y
matrix xpx = zpz[2..4, 2..4] //extracting rows / cols 2 through 4
matrix xpy = zpz[2..4, 1]    //extracting rows 2 -4 and first column

matrix list xpx
matrix list xpy

* Calculate beta-hat using formula beta-hat = (x'x)^-1(x'y)
* First, invert the (x'x) matrix
matrix xpxi	= syminv(xpx)
matrix b = xpxi * xpy
matrix list b

matrix b = b'
matrix list b

* Calculate the predicted values using the score command
matrix score double xbhat1 = b  // computes linear combination of coefs
list xbhat1 in 1/4

* Estimate the variance-covariance of the estimator
g double res	= (price - xbhat1)
g double res2	= res^2
sum res2
return list

local N 	= r(N)
local sum 	= r(sum)
local s2 	= `sum'/(`N' - 3)
matrix V 	= (`s2')*xpxi

* Verify that results match canned routines
reg price mpg trunk

matrix list e(b) // check coefficients
matrix list e(V) // check estimated VCE from canned routine
matrix list V	 // check hand calculated matrix

* Hand calculate robust standard errors using matrix accum
matrix accum M 	= mpg trunk [iweight = res2]
matrix V2         = (`N'/(`N'-3))*xpxi*M*xpxi  //recall xpxi is inverted x'x matrix
regress price mpg trunk, robust

matrix list e(V)
matrix list V2
* 

* Hand calculate cluster-robust standard errors using matrix opaccum 
* clusters are the repair record categories
g cvar = cond( missing(rep78), 6, rep78)
tab cvar
local Nc = r(r)

sort cvar
matrix opaccum M2 = mpg trunk , group(cvar) opvar(res)

matrix V3 = ((`N'-1)/(`N'-3))*(`Nc'/(`Nc'-1))*xpxi*M2*xpxi  //account for within-group error correlation

reg price mpg trunk, vce(cluster cvar)

matrix list e(V)
matrix list V3
