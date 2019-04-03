clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Week 4
Evan Kramer
9/13/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"
import delimited using "Data/poverty.csv", clear

* Drop missing GNP observations and generate time variable
drop if gnp == .
egen t = fill(1,2)

* Generate natural logs and dummy variables for each region
foreach v in birthrt deathrt infmort lexpm lexpf gnp t {
	gen ln_`v' = ln(`v')
}

foreach n of numlist 1/6 {
	gen dummy_region_`n' = region == `n'
}

* Generate instrumental variables
gen ln_death = ln_infmort + ln_deathrt
gen ln_life_exp = ln_lexpm + ln_lexpf

* Build model
regress ln_gnp ln_death ln_life_exp dummy_region_5 dummy_region_4 dummy_region_3

* Tests
predict r1, resid
twoway connect r1 t, sort yline(0)
ovtest
hettest
sktest r1
swilk r1
dwstat
tsset t
kdensity r1, normal
