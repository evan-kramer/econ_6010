clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010
Evan Kramer
9/6/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Week 3
* Read in data
import delimited using "Data/poverty.csv", clear

* Generate time variable and drop observations without GNP
egen t = fill(1, 2) /* same as gen t = _n*/
gen t2 = t^2
gen lexpt = (lexpm + lexpf) / 2 /* generate total life expectancy */
drop if gnp == . /* 6 obs */

* Plot versus time
*twoway connect gnp t, sort yline(0)

* Regress GNP on all other variables (birth/death rate, infant mortality, (fe)male life expectancy
regress gnp birthrt deathrt infmort lexpm lexpf
regress gnp birthrt infmort t lexpt

* What about difference between birth and death rate?
gen net_pop_change = birthrt - deathrt
regress gnp lexpf t deathrt infmort

/* 
* What about the natural log of GNP?
foreach v in gnp birthrt deathrt infmort lexpm lexpf {
	gen ln_`v' = ln(`v')
}
regress ln_gnp ln_birthrt ln_deathrt ln_infmort ln_lexpm ln_lexpf
*/ 

* Set time variable
tsset t 

* Test model's fit
ovtest /* omitted variables */
hettest /* heteroskedasticity */
dwstat /* Durbin-Watson statistic */
sktest infmort /* skewness/kurtosis test for normality */
kdensity infmort, normal /* kernel density estimate */

* Create the best fit model
