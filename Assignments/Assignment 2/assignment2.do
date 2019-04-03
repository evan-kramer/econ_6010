clear all
set more off, perm
set type double, perm
set matsize 500, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Assignment 2
Evan Kramer
9/30/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
import delimited using "Data/salary.csv", clear

* Generate the graph for the dependent variable (i.e., salary) over time (10 points)
egen t = fill(1, 2)
gen t2 = t^2

* Determine which variables exhibit heteroskedasticity and outliers
/*
scatter salary t /// quadratic
scatter assets t /// quadratic
scatter profits t /// quadratic
scatter sales t
scatter totcomp t
scatter tenure t
scatter age t
*/
drop if tenure > 60 | salary > 11000 

* Instrumental variables
gen other_comp = totcomp - salary, after(totcomp)
gen start_age = age - tenure, after(age)
gen pct_of_life = tenure / age, after(start_age)
gen costs = sales - profits

* Generate salary dummies
gen sal_low = salary <= 4000
gen sal_med = salary > 4000 & salary <= 6000
gen sal_hi = salary > 6000

* Log scale
foreach v in salary other_comp tenure age start_age pct_of_life sales profits assets costs {
	gen ln_`v' = ln(`v')
}

* Generate interactions to account for effect of time on sales
foreach v in sales assets costs {
	gen ln_`v'_t = ln_`v' * t
}

* Generate the best-fit model that meets NIID assumptions
regress ln_salary ln_other_comp ln_tenure ln_profits ln_assets ln_sales ln_costs ln_age ln_start_age ln_pct_of_life sal_low sal_med t  
/// regress ln_salary ln_other_comp ln_tenure ln_profits ln_assets_t ln_costs_t sal_low sal_med
regress ln_salary ln_other_comp ln_tenure ln_profits ln_assets ln_costs sal_low sal_med
///regress ln_salary ln_other_comp ln_tenure ln_profits ln_assets ln_costs sal_low sal_med, robust
return list

* Test stability of model
hettest ln_salary
hettest ln_other_comp ln_tenure ln_profits ln_assets ln_costs sal_low sal_med

* Weighted least squares?
* Feasible GLS (ch.8, p. 287)
regress ln_salary ln_other_comp ln_tenure ln_profits ln_assets ln_costs sal_low sal_med
predict r1, resid
gen ln_u2 = ln(r1^2) /* log of squared residuals */
regress ln_u2 ln_other_comp ln_tenure ln_profits ln_assets ln_costs sal_low sal_med /* obtain fitted values by regressing log of squared residuals on regressors */
predict g, resid
gen hhat = exp(g)
* Multiply each variable by 1 / sqrt(hhat)
foreach v in ln_salary ln_other_comp ln_tenure ln_profits ln_assets ln_costs {
	gen p_`v' = `v' * (1 / sqrt(hhat))
}
regress p_ln_salary p_ln_other_comp p_ln_tenure p_ln_profits p_ln_assets p_ln_costs
regress p_ln_salary p_ln_other_comp p_ln_tenure p_ln_assets p_ln_costs
predict r_n, resid
rvfplot, yline(0) /* same as twoway scatter r1 t, sort yline(0) */

* Test model specifications
ovtest
hettest
sktest r_n
swilk r_n
tsset t
dwstat
durbina
kdensity r_n, normal

exit

* Another method for feasible GLS (ch.8, p. 287)
xtset t
xtgls ln_salary ln_other_comp ln_tenure ln_profits ln_assets ln_costs sal_low sal_med t, panels(heteroskedastic)

* Wooldridge example on Breush-Pagan test for heteroskedasticity
/*
use "Data/hprice1.dta", clear
regress price lotsize sqrft bdrms
hettest
predict r1, resid
gen r2 = r1^2
///br
regress r2 lotsize sqrft bdrms
foreach v in price lotsize sqrft bdrms {
	gen ln_`v' = ln(`v')
}
regress ln_price ln_lotsize ln_sqrft ln_bdrms
predict r3, resid
gen r4 = r3^2
regress r4 ln_lotsize ln_sqrft ln_bdrms

use "Data/SMOKE.dta", clear
regress cigs lincome lcigpric educ age agesq restaurn
hettest 
predict r1, resid
gen ln_u2 = ln(r1^2)
regress ln_u2 lincome lcigpric educ age agesq restaurn
predict g, resid
gen hhat = exp(g)
foreach v in cigs lincome lcigpric educ age agesq restaurn {
	gen p_`v' = `v' * (1 / sqrt(hhat))
}
regress p_cigs p_lincome p_lcigpric p_educ p_age p_agesq p_restaurn 
predict r2, resid
hettest
ovtest
hettest
sktest r2
swilk r2
*tsset t
*dwstat
durbina
kdensity r2, normal
*/

