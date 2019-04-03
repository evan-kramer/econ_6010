clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Week 6
Evan Kramer
9/27/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"
import delimited using "Data/salary.csv", clear

* Generate time variable and view data
egen t = fill(1,2)
gen t2 = t^2
///scatter salary t

* Remove outliers? 
drop if tenure > 60 
drop if salary > 11000 

* Generate instrumental variables
gen other_comp = totcomp - salary
gen costs = sales - profits

* Generate salary dummies
gen sal_low = salary <= 4000
gen sal_med = salary > 4000 & salary <= 6000
gen sal_hi = salary > 6000

* Generate natural logs and dummy variables for each region
foreach v in salary totcomp tenure age sales profits assets other_comp costs {
	gen ln_`v' = ln(`v')
}

* Generate interactions to account for effect of time on sales
foreach v in sales assets costs {
	gen ln_`v'_t = ln_`v' * t
}

* Build model
regress ln_salary ln_other_comp ln_tenure ln_sales_t ln_costs_t ln_assets_t sal_low sal_hi



exit

* Tests
tsset t
predict r1, resid
twoway connect r1 t, sort yline(0)
ovtest
hettest
sktest r1
swilk r1
dwstat
durbina
kdensity r1, normal
