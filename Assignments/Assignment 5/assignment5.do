clear all
set more off, perm
set type double, perm
set matsize 500, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Assignment 5
Evan Kramer
11/15/2018
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

* Treat as panel data 
rename countryname country
encode country, gen(c)
xtset c time

* Generate independent variables
foreach v in annual_gdp_growth gross_fixed_capital pop_growth_annual trade_pct_gdp gov_exp_edu {
	rename value`v' `v'
	gen ln_`v' = ln(`v')
	gen sqrt_`v' = sqrt(`v')
	gen ln_`v'_lag1 = l.ln_`v'
}

* Label variables
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

* Switch for regions
*keep if dum_la == 1
keep if dum_eur == 1

* Determine whether to run fixed effects or random effects
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp ln_gov_exp_edu, fe //robust
estimates store fe
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp ln_gov_exp_edu, re //robust
estimates store re
hausman fe re

* Latin America
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp ln_gov_exp_edu, fe robust
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp, fe robust

* Europe
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp ln_gov_exp_edu, fe robust
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_gov_exp_edu, fe robust

* Plots
//twoway scatter ln_gov_exp_edu time
