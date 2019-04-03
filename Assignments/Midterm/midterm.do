clear all
set more off, perm
set type double, perm
set matsize 500, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Midterm
Evan Kramer
10/29/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
insheet using "Data/wdi.csv", clear

* Clean data
replace value = "" if value == ".."
destring value, replace
replace seriesname = "annual_gdp_growth" if seriesname == "GDP per capita growth (annual %)"
replace seriesname = "gross_fixed_capital" if seriesname == "Gross fixed capital formation (% of GDP)"
replace seriesname = "pop_growth_annual" if seriesname == "Population growth (annual %)"
replace seriesname = "trade_pct_gdp" if seriesname == "Trade (% of GDP)"
replace seriesname = "gov_exp_edu" if regexm(seriesname, "Government expenditure")

* Reshape wide
drop if seriesname == ""
reshape wide value, i(countryname time) j(seriesname) string

* Remove outliers 
//drop if (valuegross_fixed_capital >= 31 & valuegross_fixed_capital != .) | valuegross_fixed_capital < 10

* Time variable
egen t = fill(1, 2)
tsset t
gen t2 = t^2
///twoway connect annual_gdp_growth t

* Rename and label variables; generate independent variables
rename countryname country
encode country, gen(c)
foreach v in annual_gdp_growth gross_fixed_capital pop_growth_annual trade_pct_gdp gov_exp_edu {
	rename value`v' `v' 
	gen ln_`v' = ln(`v')
	gen ln_`v'2 = ln_`v'^2
	gen lns_`v' = sqrt(`v')
	*gen lns_`v' = ln(`v') / t2
	gen ln_`v'_t = ln_`v' * t
	gen ln_`v'_t2 = ln_`v' * t2
	gen ln_`v'_lag1 = l.ln_`v'
	gen ln_`v'_lag2 = l.ln_`v'_lag1
	gen ln_`v'_lag3 = l.ln_`v'_lag2
	gen ln_`v'_lag1_t = ln_`v'_lag1 * t
	gen ln_`v'_lag2_t = ln_`v'_lag2 * t
	gen ln_`v'_lag3_t = ln_`v'_lag3 * t
	gen ln_`v'_lag1_t2 = ln_`v'_lag1 * t2
	gen ln_`v'_lag2_t2 = ln_`v'_lag2 * t2
	gen ln_`v'_lag3_t2 = ln_`v'_lag3 * t2
}
la var annual_gdp_growth "GDP per capita growth (annual %)"
la var gross_fixed_capital "Gross fixed capital formation (% of GDP)"
la var pop_growth_annual "Population growth (annual %)"
la var trade_pct_gdp "Trade (% of GDP)"
la var gov_exp_edu "Government expenditure on education, tot"

* Dummy variables
gen dum_la = inlist(country, "Argentina", "Brazil", "Chile", "Colombia", "Ecuador", "El Salvador", "Nicaragua", "Panama", "Uruguay")
replace dum_la = 1 if country == "Venezuela, RB"
gen dum_eur = inlist(country, "Austria", "Belgium", "France", "Germany", "Italy", "Netherlands", "Norway", "Portugal", "Spain") 
replace dum_eur = 1 if country == "United Kingdom"
gen dum_gr = inrange(time, 2008, 2012)
gen dum_80s = inrange(time, 1980, 1989)
gen dum_90s = inrange(time, 1990, 1999)
gen dum_00s = inrange(time, 2000, 2009)
gen dum_10s = inrange(time, 2010, 2019)

* Tempfile
tempfile wide
save `wide', replace

* Initial regression
regress ln_annual_gdp_growth t2 ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp ln_gov_exp_edu

* Second run - lags
regress ln_annual_gdp_growth dum_eur t2 l.ln_gross_fixed_capital l.ln_pop_growth_annual l.ln_gov_exp_edu

* Third run - correct for non-normality
regress lns_annual_gdp_growth dum_eur t2 l.lns_gross_fixed_capital l.lns_pop_growth_annual l.lns_gov_exp_edu
predict r, resid
ovtest
hettest
durbina
sktest r
swilk r
//qnorm r
//kdensity r, normal

* Another way to correct for serial correlation
prais ln_annual_gdp_growth dum_eur t2 l.ln_gov_exp_edu, tol(1e-9) iterate(500) rhotype(dw) vce(robust)

* Alternative models 
regress ln_annual_gdp_growth t2 dum_eur ln_gov_exp_edu_lag3
ovtest
hettest
durbina

* Try as two models, one for each region, and include dummies for each decade
use `wide', clear
tsset t
keep if dum_eur == 1
regress ln_annual_gdp_growth l.ln_gov_exp_edu l.ln_gross_fixed_capital l.ln_pop_growth_annual l.ln_trade_pct_gdp t2 dum*s
ovtest 
hettest
predict res, resid
durbina
swilk res
sktest res
