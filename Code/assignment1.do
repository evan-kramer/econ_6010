clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Assignment 1
Evan Kramer
9/23/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
import delimited using "Data/salary.csv", clear


* Generate the graph for the dependent variable (i.e., salary) over time (10 points)
egen t = fill(1, 2)
///twoway scatter salary t, ytitle("Salary") xtitle("Time") title("Salary as a Function of Time")
regress salary t

* Generate the best-fit model (50 points)
* Explain reasoning if 1) used dummy variables, 2) used instrumental variables, 3) used time trend
* Instrumental variables
gen start_age = age - tenure, after(age)
gen other_comp = totcomp - salary, after(totcomp)
gen prof_by_assets = profits / assets
gen prof_by_sales = profits / sales
gen sales_by_assets = sales / assets
gen age30_39 = inlist(age, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39)

* Dummy variables for age and sales
foreach n of numlist 4/8 {
	local n2 = `n' - 1
	gen age`n'0_`n'9 = inlist(age, `n'0, `n'1, `n'2, `n'3, `n'4, `n'5, `n'6, `n'7, `n'8, `n'9), after(age`n2'0_`n2'9)
}
gen sales_hi = sales >= 50000 & sales != ., after(sales)
gen sales_med = sales >= 20000 & sales < 50000, after(sales_hi)
gen sales_lo = sales < 20000

* Log scale
foreach v in salary totcomp other_comp tenure age start_age sales profits assets ///
	prof_by_assets prof_by_sales sales_by_assets t {
	gen ln_`v' = ln(`v'), after(`v')
}

* Fit model
regress ln_salary ln_other_comp ln_totcomp ln_tenure ln_profits ln_assets ln_age ln_t
return list
///regress ln_salary ln_other_comp ln_totcomp ln_tenure ln_profits ln_assets ln_age sales_hi sales_med sales_lo
rvfplot, yline(0)
predict r1, resid

exit

twoway scatter r1 t, sort yline(0)
ovtest
hettest
sktest r1
swilk r1
dwstat
tsset t
kdensity r1, normal

* Discuss the results, including adjusted R-squared, coefficients, significance for ALL the IVs (20 points)
* Discuss the residuals' normal independent distribution and show graphically (20 points)
* Set time variable
tsset t 

* Test model's fit
ovtest /* omitted variables */
hettest /* heteroskedasticity */
dwstat /* Durbin-Watson statistic */
sktest ln_salary /* skewness/kurtosis test for normality */
kdensity ln_salary, normal /* kernel density estimate */
