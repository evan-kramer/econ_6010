clear all
set more off, perm
set type double, perm
set matsize 500, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Assignment 3
Evan Kramer
10/16/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
import excel using "Data/invest.xls", clear firstrow case(lower)

* Generate and set time variable
egen t = fill(1, 2)
tsset firm year
tsset t 

* Instrumental variables; de-trend data; take natural log of each variable
gen o = f - c
foreach v in i f c o {
	gen ln_`v' = ln(l.`v' * sqrt(year))
}

* Label variables
la var i "Investments"
la var f "Real Value of the Firm"
la var c "Real Value of the Firm's Capital Stock" 
la var o "Non-Stock Value"

* Fixed/random effects regression 
/*
xtset firm year, delta(1)
xtreg ln_f ln_i ln_o, fe /* robust */
estimates store fixed
xtreg ln_f ln_i ln_o, re /* robust */
estimates store random
hausman fixed random
xtreg ln_f ln_i ln_o, fe robust 
xtreg ln_f ln_i ln_o, re robust 
*/

* Check model stability 
regress ln_f ln_i 
ovtest // model has omitted variables
hettest // model appears stable 

* Fix model misspecification

* Dummies
gen d_123 = inlist(firm, 1, 2, 3)
gen d_468 = inlist(firm, 4, 6, 8)
gen d_5790 = inlist(firm, 5, 7, 9, 0)
gen d_ww2 = inrange(year, 1939, 1945)
gen d_kw = inrange(year, 1950, 1953)
gen d_gd = inrange(year, 1935, 1941)

* Test regression with dummies included
regress ln_f ln_i ln_c d_*
ovtest // model still has omitted variables 
hettest // data are homoskedastic

* Remove non-significant independent variables
regress ln_f ln_i ln_c d_123 d_468 d_gd

* Test model specifications
ovtest 
hettest
///rvfplot, yline(0) /* same as twoway scatter r1 t, sort yline(0) */
predict residuals, resid
sktest residuals
swilk residuals
///kdensity residuals, normal
///durbina

exit
* Book example
use "Data/SMOKE.dta", clear
regress cigs lincome lcigpric educ age agesq restaurn
hettest 
predict residuals, resid
gen ln_resid_sq = ln(residuals^2)
regress ln_resid_sq lincome lcigpric educ age agesq restaurn
predict g 
gen hhat = exp(g)
foreach v in cigs lincome lcigpric educ age agesq restaurn {
	gen p_`v' = `v' * 1 / sqrt(hhat)
}
regress p_cigs p_lincome p_lcigpric p_educ p_age p_agesq p_restaurn 
* R2 should be .1134
